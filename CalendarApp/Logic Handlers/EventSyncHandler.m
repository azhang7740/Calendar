//
//  EventSyncHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/22/22.
//

#import "EventSyncHandler.h"
#import "ParseEventHandler.h"
#import "CoreDataEventHandler.h"

#import "ParseChangeHandler.h"
#import "LocalChangeHandler.h"
#import "CalendarApp-Swift.h"

@interface EventSyncHandler () <NetworkChangeDelegate, SyncChangesDelegate>

@property (nonatomic) id<EventHandler> parseEventHandler;
@property (nonatomic) id<EventHandler> coreDataEventHandler;
@property (nonatomic) id<RemoteChangeHandler> parseChangeHandler;
@property (weak, nonatomic) id<LocalChangeSyncDelegate> delegate;
@property (nonatomic) LocalChangeHandler *localChangeHandler;

@property (nonatomic) NetworkHandler *networkHandler;
@property (nonatomic) BOOL isSynced;
@property (nonatomic) NSUserDefaults *userData;

@end

@implementation EventSyncHandler

- (instancetype)init:(id<LocalChangeSyncDelegate>)localChangeDelegate {
    if ((self = [super init])) {
        self.parseEventHandler = [[ParseEventHandler alloc] init];
        self.parseChangeHandler = [[ParseChangeHandler alloc] init];
        self.coreDataEventHandler = [[CoreDataEventHandler alloc] init];
        self.localChangeHandler = [[LocalChangeHandler alloc] init];
        self.delegate = localChangeDelegate;
        self.userData = NSUserDefaults.standardUserDefaults;
        
        self.networkHandler = [[NetworkHandler alloc] init];
        self.networkHandler.delegate = self;
        [self.networkHandler startMonitoring];
        
        if (!self.networkHandler.isOnline) {
            [self.delegate displayMessage:@"You're currently offline. All changes will be saved locally."];
        }
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
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone systemTimeZone]];
        NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
        dayComponent.day = -30;
        lastUpdated = [calendar dateByAddingComponents:dayComponent toDate:[NSDate date] options:0];
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
    if (self.isSynced) {
        self.isSynced = false;
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate displayMessage:@"You're currently offline. All changes will be saved locally."];
        });
    }
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
    if (self.networkHandler.isOnline) {
        RemoteChangeBuilder *builder = [[RemoteChangeBuilder alloc]
                                        initWithEventUUID:eventID
                                        updateDate:[NSDate date]];
        RemoteChange *deleteChange = [builder buildDeleteChangeFromEventID];
        [self syncDeleteToParseWithEvent:[eventID UUIDString]
                            remoteChange:deleteChange];
    } else {
        Event *deletingEvent = [(CoreDataEventHandler *)self.coreDataEventHandler queryEventFromID:eventID];
        if (deletingEvent) {
            [self.localChangeHandler saveNewLocalChange:deletingEvent updatedEvent:nil];
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

- (void)syncNewEventToParseWithEvent:(Event *)event
                        remoteChange:(RemoteChange *)newChange {
    [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
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
                      remoteChange:(RemoteChange *)newChange {
    [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
    [self.parseEventHandler deleteEvent:eventID completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            [self.parseChangeHandler partiallyDeleteRevisionHistory:newChange.eventID
                                                       remoteChange:newChange
                                                         completion:^(BOOL success, NSString * _Nullable error) {
                if (!success) {
                    // TODO: save as local change?
                }
            }];
        }
    }];
}

- (void)syncUpdateToParseWithEvent:(Event *)event {
    [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
    [self.parseEventHandler updateEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        }
    }];
}

- (void)syncRemoteChangeToParseWithRemoteChange:(RemoteChange *)newChange {
    [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
    [self.parseChangeHandler addNewParseChange:newChange
                                    completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            // TODO: save as local change?
        }
    }];
}

- (void)createdEventOnRemoteWithEventID:(NSUUID * _Nonnull)eventID {
    [(ParseEventHandler *)self.parseEventHandler queryEventFromID:eventID
                                                       completion:^(BOOL success,
                                                                    Event * _Nullable event,
                                                                    NSString * _Nullable error) {
        if (!success) {
            // TODO: error handling
        } else {
            [self.coreDataEventHandler uploadWithEvent:event completion:^(BOOL success,
                                                                          NSString * _Nullable error) {
                if (!success) {
                    // TODO: error handling
                } else {
                    [self.delegate didCreateEvent:event];
                }
            }];
        }
    }];
}

- (void)deletedEventOnRemoteWithEventID:(NSUUID * _Nonnull)eventID {
    Event *deletingEvent = [(CoreDataEventHandler *)self.coreDataEventHandler queryEventFromID:eventID];
    if (!deletingEvent) {
        return;
    }
    [self.delegate didDeleteEvent:deletingEvent];
    [self.coreDataEventHandler deleteEvent:[eventID UUIDString] completion:^(BOOL success,
                                                                             NSString * _Nullable error) {
        if (!success) {
            // TODO: error handling
        }
    }];
}

- (void)updatedEventOnRemoteWithEvent:(Event * _Nonnull)event {
    Event *originalEvent = [(CoreDataEventHandler *)self.coreDataEventHandler queryEventFromID:event.objectUUID];
    if (!originalEvent) {
        return;
    }
    [self.coreDataEventHandler updateEvent:event completion:^(BOOL success,
                                                              NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            [self.delegate didUpdateEvent:originalEvent newEvent:event];
        }
    }];
}

@end
