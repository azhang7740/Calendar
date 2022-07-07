//
//  ParseEventHandler.m
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import "ParseEventHandler.h"
#import "ParseEvent.h"

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

        }
    }];
}

- (NSArray<Event *> *)queryUserEvents {
    NSArray<Event *> *events = [[NSArray alloc] init];
    return events;
}

@end
