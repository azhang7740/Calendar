//
//  NSDate+NSDate_Midnight.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import "NSDate+Midnight.h"

@implementation NSDate (Midnight)

- (NSDate *)midnight {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *startOfDay = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:self options:0];
    return startOfDay;
}

- (NSDate *)nextDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    return [calendar dateByAddingComponents:dayComponent toDate:self.midnight options:0];
}

@end
