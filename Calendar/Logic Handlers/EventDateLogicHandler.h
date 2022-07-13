//
//  DateLogicHandler.h
//  Calendar
//
//  Created by Angelina Zhang on 7/12/22.
//

#import <Foundation/Foundation.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventDateLogicHandler : NSObject

- (instancetype)init;
- (void)appendDatesWithCount:(int)count;
- (void)prependDatesWithCount:(int)count;

- (NSIndexPath * _Nullable)getItemIndexWithDate:(NSDate *)date;
- (void)addNewEventsWithArray:(NSMutableArray<Event *> *)events
                      forDate:(NSDate *)date;
- (void)addNewEvent:(Event *)event
            forDate:(NSDate *)date;

- (BOOL)eventsAreEmptyForIndexPath:(NSIndexPath *)indexPath;
- (NSMutableArray<Event *> *)getEventsForIndexPath:(NSIndexPath *)indexPath;
- (NSDate *)getDateForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)scrollToItemAfterPrependingDates;
- (int)getNumberOfElements;
- (int)getNumberOfEventsForDate:(NSDate *)date;
- (Event * _Nullable)getEventFromId:(NSUUID *)eventId
                          withIndex:(NSArray<NSIndexPath *> *)visibleIndexPaths;

@end

NS_ASSUME_NONNULL_END
