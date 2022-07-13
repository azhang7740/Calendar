//
//  DateLogicHandler.m
//  Calendar
//
//  Created by Angelina Zhang on 7/12/22.
//

#import "DateLogicHandler.h"

@interface DateLogicHandler ()

@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSDate *today;
@property (nonatomic) NSMutableArray<NSDate *> *dates;
@property (nonatomic) NSMutableArray<NSMutableArray<Event *> *> *events;

@end

@implementation DateLogicHandler

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

- (int)getItemIndexWithDate:(NSDate *)date {
    NSDateComponents *differenceComponents = [self.calendar components:(NSCalendarUnitDay)
                                                              fromDate:self.dates[0]
                                                                toDate:date
                                                               options:0];
    return (int)[differenceComponents day];
}

- (void)addNewEventsWithArray:(NSMutableArray<Event *> *)events
                      forDate:(NSDate *)date {
    int index = [self getItemIndexWithDate:date];
    
    if (index >= 0 && index < self.dates.count) {
        self.events[index] = events;
    }
}

- (void)addNewEvent:(Event *)event
            forDate:(NSDate *)date {
    int index = [self getItemIndexWithDate:event.startDate];
    
    if (index >= 0 && index < self.dates.count) {
        [self.events[index] addObject:event];
    }
}

- (BOOL)eventsAreEmptyForIndex:(int)index {
    return self.events[index].count == 0;
}

- (NSMutableArray<Event *> *)getEventsForIndex:(int)index {
    return self.events[index];
}

- (NSDate *)getDateForIndex:(int)index {
    return self.dates[index];
}

- (int)scrollToItemAfterPrependingDates {
    if (self.dates.count > 15) {
        return 8;
    }
    return 7;
}

- (int)getNumberOfElements {
    return (int)self.dates.count;
}

- (int)getNumberOfEventsForDate:(NSDate *)date {
    int index = [self getItemIndexWithDate:date];
    if (index >= 0 && index < self.dates.count) {
        return self.events[index].count;
    }
    return -1;
}

@end
