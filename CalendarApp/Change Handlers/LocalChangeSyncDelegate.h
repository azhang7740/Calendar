//
//  LocalChangeSyncDelegate.h
//  CalendarApp
//
//  Created by Angelina Zhang on 8/1/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class Event;

@protocol LocalChangeSyncDelegate

- (void)didDeleteEvent:(Event *)event;
- (void)didUpdateEvent:(Event *)oldEvent
              newEvent:(Event *)updatedEvent;
- (void)didCreateEvent:(Event *)newEvent;

@end

NS_ASSUME_NONNULL_END
