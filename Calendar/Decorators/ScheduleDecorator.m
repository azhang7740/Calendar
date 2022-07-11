//
//  ScheduleDecorator.m
//  Calendar
//
//  Created by Angelina Zhang on 7/9/22.
//

#import "ScheduleDecorator.h"

@implementation ScheduleDecorator

- (void)decorateBaseScheduleWithDate:(NSDate *)date
                         contentView:(ScheduleScrollView *)view{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocalizedDateFormatFromTemplate:@"EEEE, MMM d, yyyy"];
    view.dateLabel.text = [dateFormatter stringFromDate:date];
}

- (NSString *)getTimeStringWithIndex:(int)index {
    NSString *baseTimeString = @":00";
    NSString *hourTimeString;
    NSString *finalTimeString;
    if (index % 12 == 0) {
        hourTimeString = [NSString stringWithFormat:@"%d", 12];
    } else {
        hourTimeString = [NSString stringWithFormat:@"%d", (index % 12)];
    }
    
    BOOL isFirstHalfOfDay = (index / 12) == 0;
    if (isFirstHalfOfDay) {
        finalTimeString = [[hourTimeString stringByAppendingString:baseTimeString]
                           stringByAppendingString:@"am"];
    } else {
        finalTimeString = [[hourTimeString stringByAppendingString:baseTimeString]
                           stringByAppendingString:@"pm"];
    }
    return finalTimeString;
}

@end
