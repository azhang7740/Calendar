//
//  ScheduleDecorator.h
//  Calendar
//
//  Created by Angelina Zhang on 7/9/22.
//

#import <Foundation/Foundation.h>
#import "ScheduleScrollView.h"
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ScheduleDecoratorDelegate

- (void)didTapView:(NSUUID *)eventId;

@end

@interface ScheduleDecorator : NSObject

@property (weak, nonatomic) id<ScheduleDecoratorDelegate> delegate;

- (void)decorateBaseScheduleWithDate:(NSDate *)date
                         contentView:(ScheduleScrollView *)view;
- (void)addEvents:(NSArray<Event *> *)newEvents
      contentView:(ScheduleScrollView *)view;
- (void)addEvent:(Event *)newEvent
     contentView:(ScheduleScrollView *)view;

@end

NS_ASSUME_NONNULL_END
