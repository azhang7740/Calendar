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

- (void)deleteEvent:(nonnull NSString *)eventID
         completion:(nonnull RemoteEventChangeCompletion)completion {
    [self.cdEventHandler deleteEvent:eventID completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            completion(false, error);
        } else {
            completion (true, nil);
        }
    }];
    
    [self.eventSyncHandler didDeleteEvent:[[NSUUID alloc] initWithUUIDString:eventID]];
}

- (void)queryEventsOnDate:(nonnull NSDate *)date
               completion:(nonnull EventQueryCompletion)completion {
    [self.cdEventHandler queryEventsOnDate:date completion:^(BOOL success, NSMutableArray<Event *> * _Nullable events, NSDate * _Nullable fetchedDate, NSString * _Nullable error) {
        if (!success) {
            completion(false, nil, nil, error);
        } else {
            completion (true, events, fetchedDate, nil);
        }
    }];
}

- (void)updateEvent:(nonnull Event *)event
         completion:(nonnull RemoteEventChangeCompletion)completion {
    [self.cdEventHandler updateEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            completion(false, error);
        } else {
            completion (true, nil);
        }
    }];
    
    [self.eventSyncHandler didChangeEvent:event action:ChangeTypeUpdate];
}

- (void)uploadWithEvent:(nonnull Event *)newEvent
             completion:(nonnull RemoteEventChangeCompletion)completion {
    [self.eventSyncHandler didChangeEvent:newEvent action:ChangeTypeCreate];
    [self.cdEventHandler uploadWithEvent:newEvent completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            completion(false, error);
        } else {
            completion (true, nil);
        }
    }];
}

@end
