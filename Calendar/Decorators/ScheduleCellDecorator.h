//
//  ScheduleCellDecorator.h
//  Calendar
//
//  Created by Angelina Zhang on 7/8/22.
//

#import <Foundation/Foundation.h>
#import "ScheduleCell.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleCellDecorator : NSObject

- (instancetype)init;
- (void)decorateCell:(ScheduleCell *)cell
           indexPath:(NSIndexPath *)indexPath
              events:(NSArray<Event *> *)events
            pageDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
