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

@interface EventSyncHandler () <NetworkChangeDelegate, SyncChangesDelegate>

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
                                                           NSMutableArray <NSArray<RemoteChange *> *> * _Nullable revisionHistories,
                                                           NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            SyncConflictHandler *conflictHandler = [[SyncConflictHandler alloc] initWithHistories:revisionHistories];
            conflictHandler.delegate = self;
            [conflictHandler syncChanges];
            [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
        }
    }];
}

- (void)didChangeOffline {
    self.isSynced = false;
}

- (void)syncEventToParse:(Event *)oldEvent
            updatedEvent:(Event *)newEvent {
    RemoteChangeBuilder *builder = [[RemoteChangeBuilder alloc] initWithFirstEvent:oldEvent
                                                                      updatedEvent:newEvent
                                                                        updateDate:[NSDate date]];
    NSArray<RemoteChange *> *remoteChanges = [builder buildRemoteChanges];
    
    if (remoteChanges.count == 1 && remoteChanges[0].changeType == ChangeTypeCreate) {
        [self syncNewEventToParseWithEvent:newEvent
                              remoteChange:remoteChanges[0]];
    } else {
        [self syncUpdateToParseWithEvent:newEvent];
        for (RemoteChange *change in remoteChanges) {
            [self syncRemoteChangeToParseWithRemoteChange:change];
        }
    }
}

- (void)didDeleteEvent:(NSUUID *)eventID {
    RemoteChangeBuilder *builder = [[RemoteChangeBuilder alloc]
                                    initWithEventUUID:eventID
                                    updateDate:[NSDate date]];
    RemoteChange *deleteChange = [builder buildDeleteChangeFromEventID];
    [self syncDeleteToParseWithEvent:[eventID UUIDString]
                        remoteChange:deleteChange];
}

- (void)didChangeEvent:(Event *)oldEvent
          updatedEvent:(Event *)newEvent {
    if (self.networkHandler.isOnline) {
        [self syncEventToParse:oldEvent updatedEvent:newEvent];
    } else {
        [self.localChangeHandler saveNewLocalChange:oldEvent updatedEvent:newEvent];
    }
}

- (void)syncNewEventToParseWithEvent:(Event *)event
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

- (void)syncDeleteToParseWithEvent:(NSString *)eventID
                      remoteChange:(RemoteChange *)newChange{
    [self.parseEventHandler deleteEvent:eventID completion:^(BOOL success, NSString * _Nullable error) {
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

- (void)syncUpdateToParseWithEvent:(Event *)event {
    [self.parseEventHandler updateEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        }
    }];
}

- (void)syncRemoteChangeToParseWithRemoteChange:(RemoteChange *)newChange {
    [self.parseChangeHandler addNewParseChange:newChange
                                    completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: save as local change?
        }
    }];
}

- (void)createdEventOnRemoteWithEventID:(NSUUID * _Nonnull)eventID {
    
}

- (void)deletedEventOnRemoteWithEventID:(NSUUID * _Nonnull)eventID {
    
}

- (void)updatedEventOnRemoteWithEvent:(Event * _Nonnull)event {
    
}

@end
