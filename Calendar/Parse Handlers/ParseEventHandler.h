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

- (void)successfullyUploadedEvent:(Event *)event
                          forDate:(NSDate *)date;
- (void)successfullyQueriedWithEvents:(NSMutableArray<Event *> *)events
                              forDate:(NSDate *)date;
- (void)failedRequestWithMessage:(NSString *)errorMessage;

@end

@interface ParseEventHandler : NSObject

@property (weak, nonatomic) id<ParseEventHandlerDelegate> delegate;

- (void)uploadToParseWithEvent:(Event *)newEvent;
- (NSArray<Event *> *)queryUserEventsOnDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
