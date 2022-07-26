//
//  EventSyncHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/22/22.
//

#import "EventSyncHandler.h"
#import "CoreDataEventHandler.h"
#import "ParseEventHandler.h"
#import "AppDelegate.h"
#import "CalendarApp-Swift.h"

@interface EventSyncHandler () <NetworkChangeDelegate>

@property (nonatomic) ParseEventHandler *parseEventHandler;
@property (nonatomic) CoreDataEventHandler *cdEventHandler;
@property (nonatomic) NetworkHandler *networkHandler;
@property (nonatomic) BOOL isSynced;

@property (nonatomic) NSManagedObjectContext *context;
@property (nonatomic) NSUserDefaults *userData;
@property (nonatomic) SyncConflictHandler *conflictHandler;

@end

@implementation EventSyncHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.context = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
        self.parseEventHandler = [[ParseEventHandler alloc] init];
        self.cdEventHandler = [[CoreDataEventHandler alloc] init];
        self.userData = NSUserDefaults.standardUserDefaults;
        
        self.conflictHandler = [[SyncConflictHandler alloc] init];
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
    if (![self.userData objectForKey:@"lastUpdated"]) {
        // TODO: prompt user to query all and sync with all existing remote events
        return;
    }
    [self.parseEventHandler queryEventsAfterUpdateDate:[self.userData objectForKey:@"lastUpdated"]
                                            completion:^(BOOL success,
                                                         NSMutableArray<Event *> * _Nullable events,
                                                         NSDate * _Nullable updatedDate,
                                                         NSString * _Nullable error) {
        if (!success) {
            // TODO: Error handling
        } else {
            NSArray<LocalChange *> *localChanges = [self.context executeFetchRequest:LocalChange.fetchRequest error:nil];
            NSArray<LocalChange *> *keptChanges = [self.conflictHandler resolveConflictsWithOnlineEvents:events offlineChanges:localChanges];
            [self syncLocalChanges:keptChanges];
            [self deleteAllLocalChanges];
            [self.userData setObject:[NSDate date] forKey:@"lastUpdated"];
            [self.userData synchronize];
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
        [self syncEventToParse:change.oldEvent updatedEvent:change.newEvent];
    }
}

- (void)didChangeOffline {
    self.isSynced = false;
}

- (void)syncEventToParse:(Event *)oldEvent
            updatedEvent:(Event *)newEvent {
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
