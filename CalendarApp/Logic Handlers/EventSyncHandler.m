//
//  EventSyncHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/22/22.
//

#import "EventSyncHandler.h"
#import "CoreDataEventHandler.h"
#import "ParseEventHandler.h"

@interface EventSyncHandler () <NetworkChangeDelegate>

@property (nonatomic) CoreDataEventHandler *cdEventHandler;
@property (nonatomic) ParseEventHandler *parseEventHandler;
@property (nonatomic) NetworkHandler *networkHandler;

@end

@implementation EventSyncHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.cdEventHandler = [[CoreDataEventHandler alloc] init];
        self.parseEventHandler = [[ParseEventHandler alloc] init];
        
        self.networkHandler = [[NetworkHandler alloc] init];
        [self.networkHandler startMonitoring];
    }
    return self;
}

- (void)didChangeOnline {
    // TODO: Sync
}

- (void)didChangeEvent:(Event *)event
                action:(ChangeType)action {
    if (self.networkHandler.isOnline) {
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
        }
    } else {
        
    }
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
