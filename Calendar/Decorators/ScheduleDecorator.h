//
//  ScheduleDecorator.h
//  Calendar
//
//  Created by Angelina Zhang on 7/9/22.
//

#import <Foundation/Foundation.h>
#import "ScheduleScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleDecorator : NSObject

- (void)decorateBaseScheduleWithDate:(NSDate *)date
                         contentView:(ScheduleScrollView *)view;

@end

NS_ASSUME_NONNULL_END
