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
    // create new revision history + changes
    if (!oldEvent) {
        [self syncNewEventToParse:newEvent];
    } else if (!newEvent) {
        [self syncDeleteToParse:oldEvent];
    } else {
        [self syncUpdateToParse:newEvent];
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
    LocalChange *localChange = [[LocalChange alloc] initWithContext:self.context];
    localChange.timestamp = [NSDate date];
    if (oldEvent) {
        localChange.oldEvent = [[Event alloc] initWithOriginalEvent:oldEvent];
    }
    if (newEvent) {
        localChange.updatedEvent = [[Event alloc] initWithOriginalEvent:newEvent];
    }
    [self.context save:nil];
}


- (void)syncNewEventToParse:(Event *)event {
    [self.parseEventHandler uploadWithEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        }
    }];
}

- (void)syncDeleteToParse:(Event *)event {
    [self.parseEventHandler deleteEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        }
    }];
}

- (void)syncUpdateToParse:(Event *)event {
    [self.parseEventHandler updateEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        }
    }];
}

@end
