//
//  CoreDataEventBuilder.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/21/22.
//

#import "CoreDataEventBuilder.h"

@implementation CoreDataEventBuilder

- (Event *)getEventFromCoreDataEvent:(CoreDataEvent *)coreDataEvent {
    Event *canonicalEvent = [[Event alloc] init];
    return canonicalEvent;
}

- (NSMutableArray<Event *> *)getEventsFromCoreDataEventArray:(NSArray<CoreDataEvent *> *)coreDataEvents {
    NSMutableArray<Event *> *canonicalEvents = [[NSMutableArray alloc] init];
    for (CoreDataEvent *event in coreDataEvents) {
        [canonicalEvents addObject:[self getEventFromCoreDataEvent:event]];
    }
    return canonicalEvents;
}

@end
