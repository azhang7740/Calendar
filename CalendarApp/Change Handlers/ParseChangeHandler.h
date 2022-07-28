//
//  ParseChangeHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RecentRevisionHistory;
@class RemoteChange;

typedef void (^ChangeQueryCompletion)(BOOL success,
                                      NSMutableArray <RecentRevisionHistory *> * _Nullable revisionHistories,
                                      NSString * _Nullable error);
typedef void (^ChangeActionCompletion)(BOOL success,
                                      NSString * _Nullable error);

@interface ParseChangeHandler : NSObject

- (void)queryChangesAfterUpdateDate:(NSDate *)date
                         completion:(ChangeQueryCompletion)completion;
- (void)deleteRevisionHistory:(NSUUID *)eventID
                   completion:(ChangeActionCompletion)completion;
- (void)deleteParseChange:(NSString *)changeID
               completion:(ChangeActionCompletion)completion;
- (void)addNewParseChange:(RemoteChange *)remoteChange
               completion:(ChangeActionCompletion)completion;

@end

NS_ASSUME_NONNULL_END
