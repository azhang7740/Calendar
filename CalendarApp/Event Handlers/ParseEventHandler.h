//
//  ParseEventHandler.h
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "EventHandler.h"
#import "CalendarApp-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseEventHandler : NSObject <EventHandler>

- (NSString *)getCurrentUsername;

@end

NS_ASSUME_NONNULL_END
