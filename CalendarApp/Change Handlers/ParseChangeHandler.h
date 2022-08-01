//
//  ParseChangeHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class RemoteChange;

typedef void (^ChangeQueryCompletion)(BOOL success,
                                      NSMutableArray <NSArray<RemoteChange *> *> * _Nullable revisionHistories,
                                      NSString * _Nullable error);
typedef void (^ChangeActionCompletion)(BOOL success,
                                      NSString * _Nullable error);

@protocol RemoteChangeHandler

- (void)queryChangesAfterUpdateDate:(NSDate *)date
                         completion:(ChangeQueryCompletion)completion;
- (void)deleteRevisionHistory:(NSUUID *)eventID
                   completion:(ChangeActionCompletion)completion;
- (void)deleteParseChange:(NSString *)changeID
               completion:(ChangeActionCompletion)completion;
- (void)addNewRevisionHistory:(NSUUID *)eventID
                       change:(RemoteChange *)change
                   completion:(ChangeActionCompletion)completion;
- (void)addNewParseChange:(RemoteChange *)remoteChange
               completion:(ChangeActionCompletion)completion;

@end

@interface ParseChangeHandler : NSObject <RemoteChangeHandler>

@end

NS_ASSUME_NONNULL_END
