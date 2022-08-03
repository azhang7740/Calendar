//
//  NSDate+NSDate_Midnight.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDate (Midnight)

@property (readonly, nonatomic) NSDate *midnight;
@property (readonly, nonatomic) NSDate *nextDate;

@end

NS_ASSUME_NONNULL_END
