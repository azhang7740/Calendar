//
//  EventHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/19/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Event;
typedef void (^EventQueryCompletion)(BOOL success,
                                     NSMutableArray<Event *> * _Nullable events,
                                     NSDate * _Nullable date,
                                     NSString * _Nullable error);
typedef void (^RemoteEventChangeCompletion)(BOOL success,
                                            NSString * _Nullable error);

@protocol EventHandler

- (void)queryEventsOnDate:(NSDate *)date
               completion:(EventQueryCompletion)completion;
- (void)uploadWithEvent:(Event *)newEvent
             completion:(RemoteEventChangeCompletion)completion;
- (void)updateEvent:(Event *)event
         completion:(RemoteEventChangeCompletion)completion;
- (void)deleteEvent:(Event *)event
         completion:(RemoteEventChangeCompletion)completion;

@end

@protocol RemoteEventUpdates <NSObject>

- (void)remoteEventsDidChange;

@end

NS_ASSUME_NONNULL_END
