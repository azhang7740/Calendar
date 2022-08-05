//
//  EKEventHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/19/22.
//

#import "EKEventHandler.h"
#import <Eventkit/EventKit.h>
#import "EKEventBuilder.h"
#import "NSDate+Midnight.h"

@interface EKEventHandler ()

@property (nonatomic) EKEventStore *eventStore;

@end

@implementation EKEventHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.eventStore = [[EKEventStore alloc] init];
    }
    return self;
}

- (void)requestAccessToCalendarWithCompletion:(void (^ _Nonnull)(BOOL success, NSString * _Nullable error))completion {
    if ([EKEventStore authorizationStatusForEntityType:EKEntityTypeEvent] == EKAuthorizationStatusAuthorized) {
        [self subscribeToNotifications];
        completion(true, nil);
        return;
    }
    [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError * _Nullable error) {
        if (error) {
            completion(granted, @"Something went wrong.");
        } else {
            if (granted) {
                [self subscribeToNotifications];
            }
            completion(granted, nil);
        }
    }];
}

- (void)subscribeToNotifications {
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(eventsDidChange)
                                               name:EKEventStoreChangedNotification
                                             object:self.eventStore];
}

- (void)eventsDidChange {
    [self.delegate remoteEventsDidChange];
}

- (void)deleteEvent:(nonnull NSString *)eventID
         completion:(RemoteEventChangeCompletion)completion {
    EKEvent *deletingEvent = [self.eventStore eventWithIdentifier:eventID];
    if (!deletingEvent) {
        completion(false, @"Event was not found in Apple calendar.");
    } else {
        BOOL success = [self.eventStore removeEvent:deletingEvent span:EKSpanThisEvent error:nil];
        if (success) {
            completion(true, nil);
        } else {
            completion(false, @"Event was not deleted successfully.");
        }
    }
}

- (void)queryEventsOnDate:(nonnull NSDate *)date
               completion:(EventQueryCompletion)completion {
    NSDate *midnight = date.midnight;
    NSDate *nextDate = date.nextDate;
    NSPredicate *predicate = [self.eventStore predicateForEventsWithStartDate:midnight
                                                                      endDate:nextDate
                                                                    calendars:nil];
    NSArray<EKEvent *> *events = [self.eventStore eventsMatchingPredicate:predicate];
    
    if (!events) {
        completion(false, [[NSMutableArray alloc] init], nil, @"Failed to retrieve calendar events.");
    } else {
        EKEventBuilder *builder = [[EKEventBuilder alloc] init];
        NSMutableArray<Event *> *newEvents = [builder getEventsFromEKEventArray:events];
        completion(true, newEvents, date.midnight, nil);
    }
}

- (void)updateEvent:(nonnull Event *)event
         completion:(RemoteEventChangeCompletion)completion {
    EKEvent *updatingEvent = [self.eventStore eventWithIdentifier:event.ekEventID];
    if (!updatingEvent) {
        completion(false, @"Event was not found in Apple calendar.");
    } else {
        [self updateEKEventFromEvent:event ekEvent:updatingEvent];
        BOOL success = [self.eventStore saveEvent:updatingEvent span:EKSpanThisEvent error:nil];
        if (success) {
            completion(true, nil);
        } else {
            completion(false, @"Event was not updated successfully.");
        }
    }
}

- (void)uploadWithEvent:(nonnull Event *)newEvent
             completion:(RemoteEventChangeCompletion)completion {
    EKEvent *newEKEvent = [EKEvent eventWithEventStore:self.eventStore];
    [self updateEKEventFromEvent:newEvent ekEvent:newEKEvent];
    BOOL success = [self.eventStore saveEvent:newEKEvent span:EKSpanThisEvent error:nil];
    if (success) {
        completion(true, nil);
    } else {
        completion(false, @"Error uploading event to Apple calendar.");
    }
}

- (void)updateEKEventFromEvent:(Event *)canonicalEvent
                       ekEvent:(EKEvent *)remoteEvent {
    remoteEvent.title = canonicalEvent.eventTitle;
    remoteEvent.notes = canonicalEvent.eventDescription;
    remoteEvent.location = canonicalEvent.location;
    remoteEvent.startDate = canonicalEvent.startDate;
    remoteEvent.endDate = canonicalEvent.endDate;
    [remoteEvent setAllDay:canonicalEvent.isAllDay];
    remoteEvent.calendar = [self.eventStore defaultCalendarForNewEvents];
}

@end
