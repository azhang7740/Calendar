//
//  ParseEventBuilder.m
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import "ParseEventBuilder.h"

@implementation ParseEventBuilder

+ (Event *)getEventFromParseEvent:(ParseEvent *)parseEvent {
    Event *canonicalEvent = [[Event alloc] init];
    if (!parseEvent.objectId ||
        !parseEvent.author ||
        !parseEvent.createdAt ||
        !parseEvent.updatedAt) {
        return nil;
    }
    canonicalEvent.parseObjectId = parseEvent.objectId;
    canonicalEvent.authorUsername = parseEvent.author.username;
    canonicalEvent.createdAt = parseEvent.createdAt;
    canonicalEvent.updatedAt = parseEvent.updatedAt;
    
    if (!parseEvent.eventTitle ||
        [parseEvent.eventTitle isEqual:[NSNull null]] ||
        parseEvent.eventTitle.length == 0) {
        return nil;
    }
    canonicalEvent.eventTitle = parseEvent.eventTitle;
    canonicalEvent.eventDescription = parseEvent.eventDescription;
    canonicalEvent.location = parseEvent.location;
    
    if (!parseEvent.startDate ||
        !parseEvent.endDate ||
        [parseEvent.startDate compare:parseEvent.endDate] != NSOrderedAscending) {
        return nil;
    }
    canonicalEvent.startDate = parseEvent.startDate;
    canonicalEvent.endDate = parseEvent.endDate;
    
    return canonicalEvent;
}

+ (NSMutableArray<Event *> *)getEventsFromParseEventArray:(NSArray<ParseEvent *> *)parseEvents {
    NSMutableArray<Event *> *canonicalEvents = [[NSMutableArray alloc] init];
    for (int i = 0; i < canonicalEvents.count; i++) {
        [canonicalEvents addObject:[self getEventFromParseEvent:parseEvents[i]]];
    }
    return canonicalEvents;
}

@end
