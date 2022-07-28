//
//  ParseChangeHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RecentRevisionHistory;

typedef void (^ChangeQueryCompletion)(BOOL success,
                                      RecentRevisionHistory * _Nullable revisionHistory,
                                      NSString * _Nullable error);

@interface ParseChangeHandler : NSObject

- (void)queryChangesAfterUpdateDate:(NSDate *)date
                         completion:(ChangeQueryCompletion)completion;

@end

NS_ASSUME_NONNULL_END
