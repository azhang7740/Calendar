//
//  ParseEventHandler.h
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import <Foundation/Foundation.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ParseEventHandlerDelegate

- (void)successfullyQueriedWithEvents:(NSMutableArray<Event *> *)events;
- (void)failedRequestWithMessage:(NSString *)errorMessage;

@end

@interface ParseEventHandler : NSObject

@property (weak, nonatomic) id<ParseEventHandlerDelegate> delegate;

- (void)uploadToParseWithEvent:(Event *)newEvent;
- (NSArray<Event *> *)queryUserEventsAfterDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
