//
//  ScheduleCellDecorator.m
//  Calendar
//
//  Created by Angelina Zhang on 7/8/22.
//

#import "ScheduleCellDecorator.h"

@interface ScheduleCellDecorator ()

@property (nonatomic) NSDateFormatter *dateFormatter;
@property (nonatomic) NSCalendar *calendar;

@end

@implementation ScheduleCellDecorator


- (instancetype)init {
    self = [super init];
    if (self) {
        self.dateFormatter = [[NSDateFormatter alloc] init];
        [self.dateFormatter setLocalizedDateFormatFromTemplate:@"h:mm"];
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    }
    
    return self;
}

- (void)decorateCell:(ScheduleCell *)cell
           indexPath:(NSIndexPath *)indexPath
              events:(NSArray<Event *> *)events
            pageDate:(NSDate *)date {
    
}

- (NSString *)getTimeStringWithIndexPath:(NSIndexPath *)indexPath {
    
    return nil;
}

@end
