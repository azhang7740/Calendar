//
//  ParseEventHandler.m
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import "ParseEventHandler.h"
#import "ParseEventBuilder.h"

@implementation ParseEventHandler

- (NSString *)getCurrentUsername {
    return [PFUser currentUser].username;
}

- (void)uploadToParseWithEvent:(Event *)newEvent
                    completion:(void (^_Nonnull)(Event *parseEvent, NSDate *date, NSString * _Nullable error))completion {
    ParseEvent *newParseEvent = [[ParseEvent alloc] init];
    newParseEvent.objectUUID = [newEvent.objectUUID UUIDString];
    newParseEvent.eventTitle = newEvent.eventTitle;
    newParseEvent.author = [PFUser currentUser];
    
    newParseEvent.eventDescription = newEvent.eventDescription;
    newParseEvent.location = newEvent.location;
    newParseEvent.startDate = newEvent.startDate;
    newParseEvent.endDate = newEvent.endDate;
    
    [newParseEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendar setTimeZone:[NSTimeZone systemTimeZone]];
        NSDate *midnightDate = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:newEvent.startDate options:0];
        if (succeeded) {
            newEvent.parseObjectId = newParseEvent.objectId;
            completion(newEvent, midnightDate, nil);
        } else {
            completion(newEvent, midnightDate, @"Failed to upload to Parse.");
        }
    }];
}

- (void)queryUserEventsOnDate:(NSDate *)date
                   completion:(void(^_Nonnull)(NSMutableArray<Event *> * _Nullable events, NSDate *date, NSString * _Nullable error))completion {
    PFUser *currentUser = [PFUser currentUser];
    ParseEventBuilder *builder = [[ParseEventBuilder alloc] init];
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    query.limit = 20;

    [query orderByAscending:@"startDate"];
    [query includeKey:@"author"];
    [query includeKey:@"createdAt"];
    [query includeKey:@"updatedAt"];
    [query whereKey:@"author" equalTo:currentUser];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *midnightDate = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    [query whereKey:@"startDate" greaterThan:midnightDate];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    NSDate *nextDate = [calendar dateByAddingComponents:dayComponent toDate:midnightDate options:0];
    [query whereKey:@"startDate" lessThan:nextDate];

    [query findObjectsInBackgroundWithBlock:^(NSArray<ParseEvent *> *parseEvents, NSError *error) {
        if (parseEvents) {
            NSMutableArray<Event *> *queriedEvents = [builder getEventsFromParseEventArray:parseEvents];
            completion(queriedEvents, date, nil);
        } else {
            completion(nil, date, @"Failed to query posts.");
        }
    }];
}

- (void)updateParseObjectWithEvent:(Event *)event
                        completion:(void (^)(NSString * _Nullable))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:event.parseObjectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            completion(@"Could not find the event.");
        } else {
            object[@"eventTitle"] = event.eventTitle;
            object[@"eventDescription"] = event.eventDescription;
            object[@"location"] = event.location;
            object[@"startDate"] = event.startDate;
            object[@"endDate"] = event.endDate;
            event.updatedAt = [NSDate date];
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    completion(@"Could not upload to Parse successfully.");
                } else {
                    completion(nil);
                }
            }];
        }
    }];
}

- (void)deleteParseObjectWithEvent:(Event *)event
                        completion:(void (^_Nonnull)(NSString * _Nullable error))completion {
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query getObjectInBackgroundWithId:event.parseObjectId block:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            completion(@"Could not find the event.");
        } else {
            [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (!succeeded) {
                    completion(@"Could not delete from Parse successfully.");
                } else {
                    completion(nil);
                }
            }];
        }
    }];
}

@end
