//
//  EventSyncHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/22/22.
//

#import "EventSyncHandler.h"
#import "ParseEventHandler.h"

#import "ParseChangeHandler.h"
#import "LocalChangeHandler.h"
#import "CalendarApp-Swift.h"

@interface EventSyncHandler () <NetworkChangeDelegate>

@property (nonatomic) id<EventHandler> parseEventHandler;
@property (nonatomic) id<RemoteChangeHandler> parseChangeHandler;
@property (nonatomic) LocalChangeHandler *localChangeHandler;

@property (nonatomic) NetworkHandler *networkHandler;
@property (nonatomic) BOOL isSynced;
@property (nonatomic) NSUserDefaults *userData;

@end

@implementation EventSyncHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.parseEventHandler = [[ParseEventHandler alloc] init];
        self.parseChangeHandler = [[ParseChangeHandler alloc] init];
        self.localChangeHandler = [[LocalChangeHandler alloc] init];
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
            NSArray<LocalChange *> *localChanges = [self.localChangeHandler fetchAllLocalChanges];

            SyncConflictHandler *conflictHandler = [[SyncConflictHandler alloc] initWithHistories:revisionHistories];
            [conflictHandler getChangesToSyncWithRevisionHistories:revisionHistories localChanges:localChanges];
//            [self syncLocalChanges:keptChanges];
            [self.localChangeHandler deleteAllLocalChanges];
            [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
        }
    }];
}

- (void)didChangeOffline {
    self.isSynced = false;
}

//- (void)syncLocalChanges:(NSArray<LocalChange *> *)localChanges {
//    for (LocalChange *change in localChanges) {
//        [self syncEventToParse:change.oldEvent updatedEvent:change.updatedEvent];
//    }
//}

- (void)syncEventToParse:(Event *)oldEvent
            updatedEvent:(Event *)newEvent {
    RemoteChangeBuilder *builder = [[RemoteChangeBuilder alloc] initWithFirstEvent:oldEvent
                                                                      updatedEvent:newEvent
                                                                        updateDate:[NSDate date]];
    NSArray<RemoteChange *> *remoteChanges = [builder buildRemoteChanges];
    
    if (remoteChanges.count == 1 && remoteChanges[0].changeType == ChangeTypeCreate) {
        [self syncNewEventToParse:newEvent
                     remoteChange:remoteChanges[0]];
    } else if (remoteChanges.count == 1 && remoteChanges[0].changeType == ChangeTypeDelete) {
        [self syncDeleteToParse:oldEvent
                   remoteChange:remoteChanges[0]];
    } else {
        [self syncUpdateToParse:newEvent];
        for (RemoteChange *change in remoteChanges) {
            [self syncRemoteChangeToParse:change];
        }
    }
}

- (void)didChangeEvent:(Event *)oldEvent
          updatedEvent:(Event *)newEvent {
    if (self.networkHandler.isOnline) {
        [self syncEventToParse:oldEvent updatedEvent:newEvent];
    } else {
        [self.localChangeHandler saveNewLocalChange:oldEvent updatedEvent:newEvent];
    }
}

- (void)syncNewEventToParse:(Event *)event
               remoteChange:(RemoteChange *)newChange {
    [self.parseEventHandler uploadWithEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            [self.parseChangeHandler addNewRevisionHistory:newChange.eventID
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
            [self.parseChangeHandler deleteRevisionHistory:newChange.eventID
                                                completion:^(BOOL success, NSString * _Nullable error) {
                if (!success) {
                    // TODO: save as local change?
                }
            }];
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

- (void)syncRemoteChangeToParse:(RemoteChange *)newChange {
    [self.parseChangeHandler addNewParseChange:newChange
                                    completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: save as local change?
        }
    }];
}

@end
