//
//  ParseEventHandler.m
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import "ParseEventHandler.h"
#import "ParseEventBuilder.h"

@implementation ParseEventHandler

- (void)uploadToParseWithEvent:(Event *)newEvent {
    ParseEvent *newParseEvent = [[ParseEvent alloc] init];
    newParseEvent.objectUUID = [newEvent.objectUUID UUIDString];
    newParseEvent.eventTitle = newEvent.eventTitle;
    newParseEvent.author = [PFUser currentUser];
    
    newParseEvent.eventDescription = newEvent.eventDescription;
    newParseEvent.location = newEvent.location;
    newParseEvent.startDate = newEvent.startDate;
    newParseEvent.endDate = newEvent.endDate;
    
    [newParseEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!succeeded) {
            [self.delegate failedRequestWithMessage:@"Failed to upload to Parse."];
        }
    }];
}

- (NSArray<Event *> *)queryUserEventsOnDate:(NSDate *)date {
    NSArray<Event *> *events = [[NSArray alloc] init];
    
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
    NSDate *midnightDate = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    [query whereKey:@"startDate" greaterThan:midnightDate];
    
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    NSDate *nextDate = [calendar dateByAddingComponents:dayComponent toDate:midnightDate options:0];
    [query whereKey:@"startDate" lessThan:nextDate];

    [query findObjectsInBackgroundWithBlock:^(NSArray<ParseEvent *> *parseEvents, NSError *error) {
        if (parseEvents) {
            NSMutableArray<Event *> *queriedEvents = [builder getEventsFromParseEventArray:parseEvents];
            [self.delegate successfullyQueriedWithEvents:queriedEvents];
        } else {
            [self.delegate failedRequestWithMessage:@"Failed to query posts."];
        }
    }];
    
    
    return events;
}

@end
