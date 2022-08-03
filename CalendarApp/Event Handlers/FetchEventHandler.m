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
#import "EKEventHandler.h"

@interface FetchEventHandler ()

@property (nonatomic) EventSyncHandler *eventSyncHandler;
@property (nonatomic) EKEventHandler *eventKitEventHandler;
@property (nonatomic) CoreDataEventHandler *coreDataEventHandler;
@property BOOL eventKitAccess;

@end

@implementation FetchEventHandler

- (instancetype)init:(id<LocalChangeSyncDelegate>)localChangeDelegate
remoteChangeDelegate:(id<RemoteEventUpdates>)remoteEventUpdatesDelegate {
    if ((self = [super init])) {
        self.eventSyncHandler = [[EventSyncHandler alloc] init:localChangeDelegate];
        self.coreDataEventHandler = [[CoreDataEventHandler alloc] init];
        self.eventKitEventHandler = [[EKEventHandler alloc] init];
        self.eventKitEventHandler.delegate = remoteEventUpdatesDelegate;
        self.eventKitAccess = false;
        [self.eventKitEventHandler requestAccessToCalendarWithCompletion:^(BOOL success, NSString * _Nullable error) {
            if (success) {
                self.eventKitAccess = true;
            }
        }];
    }
    return self;
}

- (void)deleteEvent:(nonnull NSString *)eventID
         completion:(nonnull RemoteEventChangeCompletion)completion {
    NSUUID *eventUUID;
    if ((eventUUID = [[NSUUID alloc] initWithUUIDString:eventID])) {
        [self.eventSyncHandler didDeleteEvent:eventUUID];
        [self.coreDataEventHandler deleteEvent:eventID completion:^(BOOL success, NSString * _Nullable error) {
            if (!success) {
                completion(false, error);
            } else {
                completion (true, nil);
            }
        }];
    } else if (self.eventKitAccess) {
        [self.eventKitEventHandler deleteEvent:eventID completion:^(BOOL success, NSString * _Nullable error) {
            if (!success) {
                completion (false, error);
            } else {
                completion (true, nil);
            }
        }];
    }
}

- (void)queryEventsOnDate:(nonnull NSDate *)date
               completion:(nonnull EventQueryCompletion)completion {
    [self.coreDataEventHandler queryEventsOnDate:date completion:^(BOOL success, NSMutableArray<Event *> * _Nullable events, NSDate * _Nullable fetchedDate, NSString * _Nullable error) {
        if (!success) {
            completion(false, nil, nil, error);
        } else if (self.eventKitAccess) {
            [self.eventKitEventHandler queryEventsOnDate:date completion:^(BOOL succeeded,
                                                                           NSMutableArray<Event *> * _Nullable eventKitEvents,
                                                                           NSDate * _Nullable eventKitFetchedDate,
                                                                           NSString * _Nullable eventKitError) {
                if (!succeeded) {
                    completion(false, nil, nil, eventKitError);
                } else {
                    NSMutableArray<Event *> *allEvents = [[NSMutableArray alloc] initWithArray:eventKitEvents];
                    [allEvents addObjectsFromArray:events];
                    completion (true, allEvents, fetchedDate, nil);
                }
            }];
        } else {
            completion(true, events, fetchedDate, nil);
        }
    }];
}

- (void)updateEvent:(nonnull Event *)event
         completion:(nonnull RemoteEventChangeCompletion)completion {
    if (event.ekEventID == nil) {
        Event *oldEvent = [[Event alloc] initWithOriginalEvent:event];
        [self.coreDataEventHandler updateEvent:event completion:^(BOOL success, NSString * _Nullable error) {
            if (!success) {
                completion(false, error);
            } else {
                completion (true, nil);
                [self.eventSyncHandler didChangeEvent:oldEvent updatedEvent:event];
            }
        }];
    } else if (self.eventKitAccess) {
        [self.eventKitEventHandler updateEvent:event completion:^(BOOL success, NSString * _Nullable error) {
            if (!success) {
                completion(false, error);
            } else {
                completion (true, nil);
            }
        }];
    }
}

- (void)updateEvent:(Event *)oldEvent
           newEvent:(Event *)updatedEvent
         completion:(RemoteEventChangeCompletion)completion {
    if (updatedEvent.ekEventID == nil) {
        [self.coreDataEventHandler updateEvent:updatedEvent completion:^(BOOL success, NSString * _Nullable error) {
            if (!success) {
                completion(false, error);
            } else {
                completion (true, nil);
                [self.eventSyncHandler didChangeEvent:oldEvent updatedEvent:updatedEvent];
            }
        }];
    } else if (self.eventKitAccess) {
        [self.eventKitEventHandler updateEvent:updatedEvent completion:^(BOOL success, NSString * _Nullable error) {
            if (!success) {
                completion(false, error);
            } else {
                completion (true, nil);
            }
        }];
    }
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
