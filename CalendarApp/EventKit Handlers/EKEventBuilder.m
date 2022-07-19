//
//  EKEventBuilder.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/19/22.
//

#import "EKEventBuilder.h"

@implementation EKEventBuilder

- (Event *)getEventFromEKEvent:(EKEvent *)ekEvent {
    Event *canonicalEvent = [[Event alloc] init];
    
    return canonicalEvent;
}

- (NSMutableArray<Event *> *)getEventsFromEKEventArray:(NSArray<EKEvent *> *)ekEvents {
    NSMutableArray<Event *> *canonicalEvents = [[NSMutableArray alloc] init];
    for (EKEvent *event in ekEvents) {
        [canonicalEvents addObject:[self getEventFromEKEvent:event]];
    }
    return canonicalEvents;
}

@end
