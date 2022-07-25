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

@interface FetchEventHandler ()

@property (nonatomic) EventSyncHandler *eventSyncHandler;

@end

@implementation FetchEventHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.eventSyncHandler = [[EventSyncHandler alloc] init];
    }
    return self;
}

- (void)deleteEvent:(nonnull Event *)event
         completion:(nonnull RemoteEventChangeCompletion)completion {
    
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
