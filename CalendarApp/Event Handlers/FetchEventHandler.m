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
@property (nonatomic) CoreDataEventHandler *coreDataEventHandler;

@end

@implementation FetchEventHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.eventSyncHandler = [[EventSyncHandler alloc] init];
        self.coreDataEventHandler = [[CoreDataEventHandler alloc] init];
    }
    return self;
}

- (void)deleteEvent:(nonnull Event *)event
         completion:(nonnull RemoteEventChangeCompletion)completion {
    [self.coreDataEventHandler deleteEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            completion(false, error);
        } else {
            completion (true, nil);
            [self.eventSyncHandler didChangeEvent:event updatedEvent:nil];
        }
    }];
}

- (void)queryEventsOnDate:(nonnull NSDate *)date
               completion:(nonnull EventQueryCompletion)completion {
    [self.coreDataEventHandler queryEventsOnDate:date completion:^(BOOL success, NSMutableArray<Event *> * _Nullable events, NSDate * _Nullable fetchedDate, NSString * _Nullable error) {
        if (!success) {
            completion(false, nil, nil, error);
        } else {
            completion (true, events, fetchedDate, nil);
        }
    }];
}

- (void)updateEvent:(nonnull Event *)event
         completion:(nonnull RemoteEventChangeCompletion)completion {
    Event *oldEvent = [[Event alloc] initWithOriginalEvent:event];
    [self.coreDataEventHandler updateEvent:event completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            completion(false, error);
        } else {
            completion (true, nil);
            [self.eventSyncHandler didChangeEvent:oldEvent updatedEvent:event];
        }
    }];
}

- (void)updateEvent:(Event *)oldEvent
           newEvent:(Event *)updatedEvent
         completion:(RemoteEventChangeCompletion)completion {
    [self.coreDataEventHandler updateEvent:updatedEvent completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            completion(false, error);
        } else {
            completion (true, nil);
            [self.eventSyncHandler didChangeEvent:oldEvent updatedEvent:updatedEvent];
        }
    }];
}

- (void)uploadWithEvent:(nonnull Event *)newEvent
             completion:(nonnull RemoteEventChangeCompletion)completion {
    [self.coreDataEventHandler uploadWithEvent:newEvent completion:^(BOOL success, NSString * _Nullable error) {
        if (!success) {
            completion(false, error);
        } else {
            completion (true, nil);
            [self.eventSyncHandler didChangeEvent:nil updatedEvent:newEvent];
        }
    }];
}

@end
