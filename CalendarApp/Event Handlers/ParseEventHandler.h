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

typedef void (^SingleEventQueryCompltion)(BOOL success,
                                          Event * _Nullable event,
                                          NSString * _Nullable error);

@interface ParseEventHandler : NSObject <EventHandler>

- (NSString *)getCurrentUsername;
- (void)queryEventFromID:(NSUUID *)eventID
              completion:(SingleEventQueryCompltion)completion;

@end

NS_ASSUME_NONNULL_END
