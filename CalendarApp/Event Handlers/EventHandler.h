//
//  EventHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/19/22.
//

#import <Foundation/Foundation.h>
#import "CalendarApp-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EventHandler <NSObject>

@required
- (void)queryUserEventsOnDate:(NSDate *)date
                   completion:(void(^_Nonnull)(NSMutableArray<Event *> * _Nullable events,
                                               NSDate *date,
                                               NSString * _Nullable error))completion;
- (void)uploadWithEvent:(Event *)newEvent
             completion:(void (^_Nonnull)(Event *event, NSDate *date, NSString * _Nullable error))completion;
- (void)updateRemoteObjectWithEvent:(Event *)event
                         completion:(void (^_Nonnull)(NSString * _Nullable error))completion;
- (void)deleteRemoteObjectWithEvent:(Event *)event
                         completion:(void (^_Nonnull)(NSString * _Nullable error))completion;

@end

@protocol RemoteEventUpdates <NSObject>

@required
- (void)remoteEventsDidChange:(NSArray<Event *> *)events;

@end

NS_ASSUME_NONNULL_END
