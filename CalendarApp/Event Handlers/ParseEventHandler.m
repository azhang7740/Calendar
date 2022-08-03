//
//  ParseEventHandler.m
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import "ParseEventHandler.h"
#import "ParseEventBuilder.h"
#import "NSDate+Midnight.h"

@implementation ParseEventHandler

- (NSString *)getCurrentUsername {
    return [PFUser currentUser].username;
}

- (void)uploadWithEvent:(Event *)newEvent
             completion:(RemoteEventChangeCompletion)completion {
    ParseEvent *newParseEvent = [[ParseEvent alloc] init];
    Event *uploadEvent = [[Event alloc] initWithOriginalEvent:newEvent];
    newParseEvent.objectUUID = [uploadEvent.objectUUID UUIDString];
    newParseEvent.eventTitle = uploadEvent.eventTitle;
    newParseEvent.author = [PFUser currentUser];
    
    newParseEvent.eventDescription = uploadEvent.eventDescription;
    newParseEvent.location = uploadEvent.location;
    newParseEvent.startDate = uploadEvent.startDate;
    newParseEvent.endDate = uploadEvent.endDate;
    
    [newParseEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            completion(true, nil);
        } else {
            completion(true, @"Failed to upload to Parse.");
        }
    }];
}

- (void)queryEventsOnDate:(NSDate *)date
               completion:(EventQueryCompletion)completion {
    PFUser *currentUser = [PFUser currentUser];
    ParseEventBuilder *builder = [[ParseEventBuilder alloc] init];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(startDate >= %@ AND startDate <= %@) OR (startDate < %@ AND endDate > %@)", date.midnight, date.nextDate, date.midnight, date.midnight];
    PFQuery *query = [PFQuery queryWithClassName:@"Event" predicate:predicate];
    query.limit = 20;

    [query orderByAscending:@"startDate"];
    [query includeKey:@"author"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"updatedAt"];
    [query whereKey:@"author" equalTo:currentUser];

    [query findObjectsInBackgroundWithBlock:^(NSArray<ParseEvent *> *parseEvents, NSError *error) {
        if (parseEvents) {
            NSMutableArray<Event *> *queriedEvents = [builder getEventsFromParseEventArray:parseEvents];
            completion(true, queriedEvents, date.midnight, nil);
        } else {
            completion(false, nil, nil, @"Failed to query events.");
        }
    }];
}

- (void)updateEvent:(Event *)event
         completion:(RemoteEventChangeCompletion)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    Event *uploadEvent = [[Event alloc] initWithOriginalEvent:event];
    [query whereKey:@"objectUUID" equalTo:[uploadEvent.objectUUID UUIDString]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            completion(false, @"Could not find the event.");
        } else {
            object[@"eventTitle"] = uploadEvent.eventTitle;
            object[@"eventDescription"] = uploadEvent.eventDescription;
            object[@"location"] = uploadEvent.location;
            object[@"startDate"] = uploadEvent.startDate;
            object[@"endDate"] = uploadEvent.endDate;
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    completion(false, @"Could not upload to Parse successfully.");
                } else {
                    completion(true, nil);
                }
            }];
        }
    }];
}

- (void)deleteEvent:(NSString *)eventID
         completion:(RemoteEventChangeCompletion)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query whereKey:@"objectUUID" equalTo:eventID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            completion(false, @"Could not find the event.");
        } else {
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    completion(false, @"Could not delete from Parse successfully.");
                } else {
                    completion(true, nil);
                }
            }];
        }
    }];
}

- (void)queryEventFromID:(NSUUID *)eventID
              completion:(SingleEventQueryCompletion)completion {
    PFUser *currentUser = [PFUser currentUser];
    ParseEventBuilder *builder = [[ParseEventBuilder alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    
    [query orderByAscending:@"startDate"];
    [query includeKey:@"author"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"updatedAt"];
    [query whereKey:@"author" equalTo:currentUser];
    [query whereKey:@"objectUUID" equalTo:[eventID UUIDString]];

    [query getFirstObjectInBackgroundWithBlock:^(PFObject *parseEvent, NSError *error) {
        if (parseEvent) {
            Event *event = [builder getEventFromParseEvent:(ParseEvent *)parseEvent];
            completion(true, event, nil);
        } else {
            completion(false, nil, @"Failed to query events.");
        }
    }];
}

@end
