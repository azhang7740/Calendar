//
//  EventSyncHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/22/22.
//

#import "EventSyncHandler.h"
#import "ParseEventHandler.h"
#import "ParseChangeHandler.h"
#import "AppDelegate.h"
#import "CalendarApp-Swift.h"

@interface EventSyncHandler () <NetworkChangeDelegate>

@property (nonatomic) id<EventHandler> parseEventHandler;
@property (nonatomic) ParseChangeHandler *parseChangeHandler;
@property (nonatomic) NetworkHandler *networkHandler;
@property (nonatomic) BOOL isSynced;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSUserDefaults *userData;

@end

@implementation EventSyncHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.context = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
        self.parseEventHandler = [[ParseEventHandler alloc] init];
        self.parseChangeHandler = [[ParseChangeHandler alloc] init];
        self.userData = NSUserDefaults.standardUserDefaults;
        
        self.networkHandler = [[NetworkHandler alloc] init];
        self.networkHandler.delegate = self;
        [self.networkHandler startMonitoring];
    }
    return self;
}

- (void)didChangeOnline {
    if (self.isSynced) {
        return;
    }
    self.isSynced = true;
    NSDate *lastUpdated = [self.userData objectForKey:@"lastUpdated"];
    if (!lastUpdated) {
        // TODO: prompt user to query all and sync with all existing remote events
        [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
        [self.userData synchronize];
        return;
    }
    [self.parseChangeHandler queryChangesAfterUpdateDate:lastUpdated
                                              completion:^(BOOL success,
                                                           NSMutableArray <RecentRevisionHistory *> * _Nullable revisionHistories,
                                                           NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            NSArray<LocalChange *> *localChanges = [self.context executeFetchRequest:LocalChange.fetchRequest error:nil];

            SyncConflictHandler *conflictHandler = [[SyncConflictHandler alloc] init];
            NSArray<LocalChange *> *keptChanges = [conflictHandler getChangesToSyncWithRevisionHistories:revisionHistories localChanges:localChanges];
            [self syncLocalChanges:keptChanges];
            [self deleteAllLocalChanges];
            [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
        }
    }];
}

- (void)deleteAllLocalChanges {
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:LocalChange.fetchRequest];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.persistentStoreCoordinator;
    [persistentStoreCoordinator executeRequest:delete withContext:self.context error:nil];
}

- (void)syncLocalChanges:(NSArray<LocalChange *> *)localChanges {
    for (LocalChange *change in localChanges) {
        [self syncEventToParse:change.oldEvent updatedEvent:change.updatedEvent];
    }
}

- (void)didChangeOffline {
    self.isSynced = false;
}

- (void)syncEventToParse:(Event *)oldEvent
            updatedEvent:(Event *)newEvent {
    RemoteChange *newChange = [[RemoteChange alloc] init];
    newChange.oldEvent = oldEvent;
    newChange.updatedEvent = newEvent;
    newChange.timestamp = [NSDate date];
    
    if (newChange.changeType == ChangeTypeCreate) {
        [self syncNewEventToParse:newEvent
                     remoteChange:newChange];
    } else if (newChange.changeType == ChangeTypeDelete) {
        [self syncDeleteToParse:oldEvent
                   remoteChange:newChange];
    } else {
        [self syncUpdateToParse:newEvent
                   remoteChange:newChange];
    }
}

- (void)didChangeEvent:(Event *)oldEvent
          updatedEvent:(Event *)newEvent {
    if (self.networkHandler.isOnline) {
        [self syncEventToParse:oldEvent updatedEvent:newEvent];
    } else {
        [self saveNewLocalChange:oldEvent updatedEvent:newEvent];
    }
}

- (void)saveNewLocalChange:(Event *)oldEvent
              updatedEvent:(Event *)newEvent {
    if (!newEvent) {
        [self didOfflineDelete:oldEvent completion:^(Event *oldEvent) {
            [self saveLocalChange:oldEvent updatedEvent:nil];
        }];
    } else if (oldEvent) {
        oldEvent = ([self didOfflineUpdate:newEvent]) ? nil : oldEvent;
        [self saveLocalChange:oldEvent updatedEvent:newEvent];
    } else {
        [self saveLocalChange:oldEvent updatedEvent:newEvent];
    }
    
    [self.context save:nil];
}

- (void)saveLocalChange:(Event *)oldEvent
                    updatedEvent:(Event *)newEvent {
    LocalChange *localChange = [[LocalChange alloc] initWithContext:self.context];
    localChange.timestamp = [NSDate date];
    localChange.oldEvent = (oldEvent) ? [[Event alloc] initWithOriginalEvent:oldEvent] : nil;
    localChange.updatedEvent = (newEvent) ? [[Event alloc] initWithOriginalEvent:newEvent] : nil;
    localChange.eventUUID = (oldEvent) ? oldEvent.objectUUID : newEvent.objectUUID;
}

- (void)didOfflineDelete:(Event *)event
              completion:(void (^ _Nonnull)(Event *oldEvent))completion {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalChange"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventUUID == %@", event.objectUUID];
    NSArray<LocalChange *> *matchingChanges = [self.context executeFetchRequest:request error:nil];
    for (LocalChange *localChange in matchingChanges) {
        [self.context deleteObject:localChange];
    }
    completion(event);
}

- (BOOL)didOfflineUpdate:(Event *)event {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalChange"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventUUID == %@", event.objectUUID];
    NSArray<LocalChange *> *matchingChanges = [self.context executeFetchRequest:request error:nil];
    if (matchingChanges.count == 1 && !matchingChanges[0].oldEvent) {
        [self.context deleteObject:matchingChanges[0]];
        return true;
    }
    return false;
}

- (void)syncNewEventToParse:(Event *)event
               remoteChange:(RemoteChange *)newChange {
    [self.parseEventHandler uploadWithEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            [self.parseChangeHandler addNewRevisionHistory:newChange.objectUUID
                                                    change:newChange
                                                completion:^(BOOL success, NSString * _Nullable error) {
                if (!success) {
                    // TODO: save as local change?
                }
            }];
        }
    }];
}

- (void)syncDeleteToParse:(Event *)event
             remoteChange:(RemoteChange *)newChange{
    [self.parseEventHandler deleteEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            [self.parseChangeHandler deleteRevisionHistory:newChange.objectUUID
                                                completion:^(BOOL success, NSString * _Nullable error) {
                if (!success) {
                    // TODO: save as local change?
                }
            }];
        }
    }];
}

- (void)syncUpdateToParse:(Event *)event
             remoteChange:(RemoteChange *)newChange{
    [self.parseEventHandler updateEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            [self.parseChangeHandler addNewParseChange:newChange
                                            completion:^(BOOL success, NSString * _Nullable error) {
                if (!success) {
                    // TODO: save as local change?
                }
            }];
        }
    }];
}

@end
