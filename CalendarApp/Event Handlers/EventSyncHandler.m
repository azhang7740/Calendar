//
//  EventSyncHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/22/22.
//

#import "EventSyncHandler.h"
#import "CoreDataEventHandler.h"
#import "ParseEventHandler.h"

@interface EventSyncHandler ()

@property (nonatomic) CoreDataEventHandler *cdEventHandler;
@property (nonatomic) ParseEventHandler *parseEventHandler;

@end

@implementation EventSyncHandler

- (instancetype)init {
    if (self = [super init]) {
        self.cdEventHandler = [[CoreDataEventHandler alloc] init];
        self.parseEventHandler = [[ParseEventHandler alloc] init];
    }
    return self;
}

@end
