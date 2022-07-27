//
//  ParseChangeHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>
#import "CalendarApp-Swift.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^ChangeQueryCompletion)(BOOL success, NSMutableArray<Event *> * _Nullable events, NSString * _Nullable error);

@interface ParseChangeHandler : NSObject

- (void)queryChangesAfterUpdateDate:(NSDate *)date
                         completion:(ChangeQueryCompletion)completion;

@end

NS_ASSUME_NONNULL_END
