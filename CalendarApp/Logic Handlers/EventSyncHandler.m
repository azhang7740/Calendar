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

@interface EventSyncHandler () <NetworkChangeDelegate>

@property (nonatomic) ParseEventHandler *parseEventHandler;
@property (nonatomic) CoreDataEventHandler *cdEventHandler;
@property (nonatomic) NetworkHandler *networkHandler;
@property (nonatomic) NSManagedObjectContext *context;

@end

@implementation EventSyncHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.context = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
        self.parseEventHandler = [[ParseEventHandler alloc] init];
        self.cdEventHandler = [[CoreDataEventHandler alloc] init];
        
        self.networkHandler = [[NetworkHandler alloc] init];
        [self.networkHandler startMonitoring];
    }
    return self;
}

- (void)didChangeOnline {
    NSArray<LocalChange *> *localChanges = [self.context executeFetchRequest:LocalChange.fetchRequest error:nil];
    for (LocalChange *change in localChanges) {
        Event *event = [self.cdEventHandler queryEventFromID:change.eventUUID];
        [self syncEventToParse:event action:change.changeType];
    }
}

- (void)syncEventToParse:(Event *)event
                  action:(ChangeType)action {
    switch (action) {
        case ChangeTypeCreate:
            [self syncNewEventToParse:event];
            break;
        case ChangeTypeDelete:
            [self syncDeleteToParse:event];
            break;
        case ChangeTypeUpdate:
            [self syncUpdateToParse:event];
            break;
        case ChangeTypeNoChange:
            break;
    }
}

- (void)didChangeEvent:(Event *)event
                action:(ChangeType)action {
    if (self.networkHandler.isOnline) {
        [self syncEventToParse:event action:action];
    } else {
        ChangeType prevChange = ChangeTypeNoChange;
        if (action == ChangeTypeDelete || action == ChangeTypeUpdate) {
            prevChange = [self removeLocalChangeWithUUID:event.objectUUID];
        }
        
        if (action == ChangeTypeUpdate && prevChange == ChangeTypeCreate) {
            [self addLocalChangeWithEvent:event action:ChangeTypeCreate];
        } else if (!(action == ChangeTypeDelete && prevChange == ChangeTypeCreate)){
            [self addLocalChangeWithEvent:event action:action];
        }
        [self.context save:nil];
    }
}

- (ChangeType)removeLocalChangeWithUUID:(NSUUID *)eventUUID {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalChange"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventUUID == %@", eventUUID];
    NSArray<LocalChange *> *localChanges = [self.context executeFetchRequest:request error:nil];
    ChangeType prevAction = ChangeTypeNoChange;
    if (localChanges.count != 0) {
        prevAction = localChanges[0].changeType;
        [self.context deleteObject:localChanges[0]];
    }
    return prevAction;
}

- (void)addLocalChangeWithEvent:(Event *)event
                         action:(ChangeType)action {
    LocalChange *localChange = [[LocalChange alloc] initWithContext:self.context];
    localChange.eventParseID = event.parseObjectId;
    localChange.eventUUID = event.objectUUID;
    localChange.changeType = action;
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
