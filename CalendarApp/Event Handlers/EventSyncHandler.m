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

@interface EventSyncHandler ()

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

@end
