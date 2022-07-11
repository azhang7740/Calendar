//
//  ScheduleDecorator.m
//  Calendar
//
//  Created by Angelina Zhang on 7/9/22.
//

#import "ScheduleDecorator.h"
#import "ScheduleHour.h"
#import "ScheduleEventView.h"

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

- (void)addEvents:(NSArray<Event *> *)newEvents
      contentView:(ScheduleScrollView *)view {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    for (Event *event in newEvents) {
        ScheduleEventView *eventView = [ScheduleEventView new];
        eventView.eventTitleLabel.text = event.eventTitle;
        eventView.translatesAutoresizingMaskIntoConstraints = false;
        [view.scrollView addSubview:eventView];
        
        NSDateComponents *startComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                                                        fromDate:event.startDate];
        NSDateComponents *durationComponents = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute)
                                                      fromDate:event.startDate toDate:event.endDate options:0];
        
        [[eventView.leadingAnchor constraintEqualToAnchor:view.scrollView.leadingAnchor
                                                 constant:100] setActive:true];
        [[eventView.trailingAnchor constraintEqualToAnchor:view.scrollView.trailingAnchor] setActive:true];
        
        int hourHeight = view.scrollView.frame.size.height / 24;
        int distanceFromTop = (int)[startComponents hour] * hourHeight +
                              (int)(((double)[startComponents minute] / 60) * hourHeight);
        int eventHeight = (int)[durationComponents hour] * hourHeight +
                          (int)(((double)[durationComponents minute] / 60) * hourHeight);
        
        [[eventView.topAnchor constraintEqualToAnchor:view.scrollView.topAnchor
                                             constant:distanceFromTop] setActive:true];
        [[eventView.heightAnchor constraintEqualToConstant:eventHeight] setActive:true];
    }
}

- (NSString *)getTimeStringWithIndex:(int)index {
    NSString *hourTimeString;
    NSString *finalTimeString;
    if (index % 12 == 0) {
        hourTimeString = [NSString stringWithFormat:@"%d", 12];
    } else {
        hourTimeString = [NSString stringWithFormat:@"%d", (index % 12)];
    }
    
    BOOL isFirstHalfOfDay = (index / 12) == 0;
    if (isFirstHalfOfDay) {
        finalTimeString = [hourTimeString stringByAppendingString:@"am"];
    } else {
        finalTimeString = [hourTimeString stringByAppendingString:@"pm"];
    }
    return finalTimeString;
}

@end
