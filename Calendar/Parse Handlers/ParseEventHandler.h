//
//  ParseEventHandler.h
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseEventHandler : NSObject

- (void)uploadToParseWithEvent:(Event *)newEvent;
- (NSArray<Event *> *)queryUserEvents;

@end

NS_ASSUME_NONNULL_END
