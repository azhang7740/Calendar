//
//  ScheduleCellDecorator.m
//  Calendar
//
//  Created by Angelina Zhang on 7/8/22.
//

#import "ScheduleCellDecorator.h"

@implementation ScheduleCellDecorator

- (void)decorateCell:(ScheduleCell *)cell
           indexPath:(NSIndexPath *)indexPath
              events:(NSArray<Event *> *)events
            pageDate:(NSDate *)date {
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    cell.timeLabel.text = [self getTimeStringWithIndexPath:indexPath];
}

- (NSString *)getTimeStringWithIndexPath:(NSIndexPath *)indexPath {
    NSString *baseTimeString = @":00";
    NSString *hourTimeString;
    NSString *finalTimeString;
    if (indexPath.row % 12 == 0) {
        hourTimeString = [NSString stringWithFormat:@"%d", 12];
    } else {
        hourTimeString = [NSString stringWithFormat:@"%ld", (indexPath.row % 12)];
    }
    
    BOOL isFirstHalfOfDay = (indexPath.row / 12) == 0;
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
