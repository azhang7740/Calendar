//
//  DateLogicHandler.m
//  Calendar
//
//  Created by Angelina Zhang on 7/12/22.
//

#import "EventDateLogicHandler.h"
#import <UIKit/UIKit.h>

@interface EventDateLogicHandler ()

@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSDate *today;
@property (nonatomic) NSMutableArray<NSDate *> *dates;
@property (nonatomic) NSMutableArray<NSMutableArray<Event *> *> *events;

@end

@implementation EventDateLogicHandler

- (instancetype)init {
    self = [super init];
    if (self) {
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [self.calendar setTimeZone:[NSTimeZone systemTimeZone]];
        
        self.today = [self.calendar dateBySettingHour:0
                                               minute:0
                                               second:0
                                               ofDate:[NSDate date]
                                              options:0];
        self.dates = [[NSMutableArray alloc] init];
        [self.dates addObject:self.today];
        self.events = [[NSMutableArray alloc] init];
        [self appendDatesWithCount:7];
    }
    
    return self;
}

- (void)appendDatesWithCount:(int)count {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    
    for (int i = 0; i < count; i++) {
        [self.dates addObject:[self.calendar dateByAddingComponents:dayComponent
                                                             toDate:self.dates[self.dates.count - 1]
                                                            options:0]];
        [self.events addObject:[[NSMutableArray alloc] init]];
    }
}

- (void)prependDatesWithCount:(int)count {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -1;
    
    for (int i = 0; i < count; i++) {
        [self.dates insertObject:[self.calendar dateByAddingComponents:dayComponent
                                                                toDate:self.dates[0]
                                                               options:0] atIndex:0];
        [self.events insertObject:[[NSMutableArray alloc] init] atIndex:0];
    }
}

- (NSIndexPath * _Nullable)getItemIndexWithDate:(NSDate *)date {
    NSDateComponents *differenceComponents = [self.calendar components:(NSCalendarUnitDay)
                                                              fromDate:self.dates[0]
                                                                toDate:date
                                                               options:0];
    if ([differenceComponents day] >= 0 && [differenceComponents day] < self.dates.count) {
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:[differenceComponents day] inSection:0];
        return newIndexPath;
    }
    return nil;
}

- (void)addNewEventsWithArray:(NSMutableArray<Event *> *)events
                      forDate:(NSDate *)date {
    int index = (int)[self getItemIndexWithDate:date].row;
    
    if (index >= 0 && index < self.dates.count) {
        self.events[index] = events;
    }
}

- (void)addNewEvent:(Event *)event
            forDate:(NSDate *)date {
    int index = (int)[self getItemIndexWithDate:event.startDate].row;
    
    if (index >= 0 && index < self.dates.count) {
        [self.events[index] addObject:event];
    }
}

- (BOOL)eventsAreEmptyForIndexPath:(NSIndexPath *)indexPath {
    return self.events[indexPath.row].count == 0;
}

- (NSMutableArray<Event *> *)getEventsForIndexPath:(NSIndexPath *)indexPath {
    return self.events[indexPath.row];
}

- (NSDate *)getDateForIndexPath:(NSIndexPath *)indexPath {
    return self.dates[indexPath.row];
}

- (NSIndexPath *)scrollToItemAfterPrependingDates {
    NSIndexPath *newIndexPath;
    if (self.dates.count > 15) {
        newIndexPath = [NSIndexPath indexPathForItem:8 inSection:0];
    } else {
        newIndexPath = [NSIndexPath indexPathForItem:7 inSection:0];
    }
    return newIndexPath;
}

- (int)getNumberOfElements {
    return (int)self.dates.count;
}

- (int)getNumberOfEventsForDate:(NSDate *)date {
    int index = (int)[self getItemIndexWithDate:date].row;
    if (index >= 0 && index < self.dates.count) {
        return (int)self.events[index].count;
    }
    return -1;
}

- (Event * _Nullable)getEventFromId:(NSUUID *)eventId
                          withIndex:(NSArray<NSIndexPath *> *)visibleIndexPaths {
    for (NSIndexPath *indexPath in visibleIndexPaths) {
        for (Event *event in self.events[indexPath.row]) {
            if (event.objectUUID == eventId) {
                return event;
            }
        }
    }
    return nil;
}

- (void)deleteEvent:(Event *)event {
    NSIndexPath *indexPath = [self getItemIndexWithDate:event.startDate];
    [self.events[indexPath.row] removeObject:event];
}

@end
