//
//  FetchEventHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/25/22.
//

#import "FetchEventHandler.h"
#import "CoreDataEventHandler.h"
#import "ParseEventHandler.h"
#import "EventSyncHandler.h"
#import "CoreDataEventHandler.h"

@interface FetchEventHandler ()

@property (nonatomic) EventSyncHandler *eventSyncHandler;
@property (nonatomic) CoreDataEventHandler *cdEventHandler;

@end

@implementation FetchEventHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.eventSyncHandler = [[EventSyncHandler alloc] init];
        self.cdEventHandler = [[CoreDataEventHandler alloc] init];
    }
    return self;
}

- (void)deleteEvent:(nonnull Event *)event
         completion:(nonnull RemoteEventChangeCompletion)completion {
    [self.cdEventHandler deleteEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        
    }];
}

- (void)queryEventsOnDate:(nonnull NSDate *)date
               completion:(nonnull EventQueryCompletion)completion {
    
}

- (void)updateEvent:(nonnull Event *)event
         completion:(nonnull RemoteEventChangeCompletion)completion {
    
}

- (void)uploadWithEvent:(nonnull Event *)newEvent
             completion:(nonnull RemoteEventChangeCompletion)completion {
    
}

@end
