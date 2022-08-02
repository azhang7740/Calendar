//
//  FetchEventHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/25/22.
//

#import <Foundation/Foundation.h>
#import "EventHandler.h"
#import "LocalChangeSyncDelegate.h"

NS_ASSUME_NONNULL_BEGIN

@interface FetchEventHandler : NSObject <EventHandler>

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

- (instancetype)init:(id<LocalChangeSyncDelegate>)delegate;

- (void)updateEvent:(Event *)oldEvent
           newEvent:(Event *)updatedEvent
         completion:(RemoteEventChangeCompletion)completion;

@end

NS_ASSUME_NONNULL_END
