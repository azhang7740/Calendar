//
//  DetailsViewController.h
//  Calendar
//
//  Created by Angelina Zhang on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "CalendarApp-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@class FetchEventHandler;

@protocol DetailsViewControllerDelegate

- (void)didTapClose;
- (void)didDeleteEventOnDetailView:(Event *)event;
- (void)didUpdateEvent:(Event *)oldEvent
              newEvent:(Event *)updatedEvent;

@end

@interface DetailsViewController : UIViewController

@property (weak, nonatomic) id<DetailsViewControllerDelegate> delegate;
@property (nonatomic) FetchEventHandler *eventHandler;
@property (nonatomic) Event *event;

@end

NS_ASSUME_NONNULL_END
