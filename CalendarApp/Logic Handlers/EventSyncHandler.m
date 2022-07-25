//
//  EventSyncHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/22/22.
//

#import "EventSyncHandler.h"
#import "CoreDataEventHandler.h"
#import "ParseEventHandler.h"
#import "CalendarApp-Swift.h"

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
        
        self.isOnline = false;
        self.networkHandler = [[NetworkHandler alloc] init];
        [self.networkHandler startMonitoring];
        self.networkHandler.delegate = self;
    }
    return self;
}

- (void)didChangeOnline {
    self.isOnline = true;
}

- (void)didChangeOffline {
    self.isOnline = false;
}

@end
