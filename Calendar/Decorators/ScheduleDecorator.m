//
//  ScheduleDecorator.m
//  Calendar
//
//  Created by Angelina Zhang on 7/9/22.
//

#import "ScheduleDecorator.h"
#import "ScheduleHour.h"

@implementation ScheduleDecorator

- (void)decorateBaseScheduleWithDate:(NSDate *)date
                         contentView:(ScheduleScrollView *)view{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocalizedDateFormatFromTemplate:@"EEEE, MMM d, yyyy"];
    view.dateLabel.text = [dateFormatter stringFromDate:date];
    
    int height = view.scrollView.frame.size.height / 24;
    for (int index = 0; index < 24; index++) {
        ScheduleHour *hourView = [ScheduleHour new];
        hourView.timeLabel.text = [self getTimeStringWithIndex:index];
        hourView.translatesAutoresizingMaskIntoConstraints = false;
        [view.scrollView addSubview:hourView];
        [[hourView.widthAnchor constraintEqualToConstant:view.scrollView.frame.size.width] setActive:true];
        [[hourView.heightAnchor constraintEqualToConstant:height] setActive:true];
        [[hourView.topAnchor constraintEqualToAnchor:view.scrollView.topAnchor
                                            constant:height * index] setActive:true];
        [[hourView.centerXAnchor constraintEqualToAnchor:view.scrollView.centerXAnchor] setActive:true];
        
    }
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
