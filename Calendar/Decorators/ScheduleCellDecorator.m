//
//  ScheduleCellDecorator.m
//  Calendar
//
//  Created by Angelina Zhang on 7/8/22.
//

#import "ScheduleCellDecorator.h"

@interface ScheduleCellDecorator ()

@property (nonatomic) NSDateFormatter *dateFormatter;

@end

@implementation ScheduleCellDecorator

- (instancetype)init {
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setLocalizedDateFormatFromTemplate:@"EEEE, MMM d, yyyy"];
        
    }
    return self;
}

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
