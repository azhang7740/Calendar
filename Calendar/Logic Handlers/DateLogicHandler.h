//
//  DateLogicHandler.h
//  Calendar
//
//  Created by Angelina Zhang on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface DateLogicHandler : NSObject

- (instancetype)init;
- (void)appendDatesWithCount:(int)count;
- (void)prependDatesWithCount:(int)count;

- (int)getItemIndexWithDate:(NSDate *)date;
- (void)addNewEventsWithArray:(NSMutableArray<Event *> *)events
                      forDate:(NSDate *)date;
- (void)addNewEvent:(Event *)event
            forDate:(NSDate *)date;

- (BOOL)eventsAreEmptyForIndex:(int)index;
- (NSMutableArray<Event *> *)getEventsForIndex:(int)index;
- (NSDate *)getDateForIndex:(int)index;
- (int)scrollToItemAfterPrependingDates;
- (int)getNumberOfElements;
- (int)getNumberOfEventsForDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
