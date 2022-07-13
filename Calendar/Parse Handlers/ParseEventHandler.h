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

- (NSString *)getCurrentUsername;
- (void)queryUserEventsOnDate:(NSDate *)date
               withCompletion:(void(^_Nonnull)(NSMutableArray<Event *> * _Nullable events, NSDate *date, NSString * _Nullable error))completion;

- (void)uploadToParseWithEvent:(Event *)newEvent
                withCompletion:(void (^_Nonnull)(Event *event, NSDate *date, NSString * _Nullable error))completion;
- (void)updateParseObjectWithEvent:(Event *)event
                    withCompletion:(void (^_Nonnull)(NSString * _Nullable error))completion;
- (void)deleteParseObjectWithEvent:(Event *)event
                    withCompletion:(void (^_Nonnull)(NSString * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
