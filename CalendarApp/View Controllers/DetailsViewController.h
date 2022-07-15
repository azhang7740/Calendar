//
//  DetailsViewController.h
//  Calendar
//
//  Created by Angelina Zhang on 7/13/22.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "ParseEventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@protocol DetailsViewControllerDelegate

- (void)didTapClose;
- (void)didDeleteEvent:(Event *)event;

@end

@interface DetailsViewController : UIViewController

@property (weak, nonatomic) id<DetailsViewControllerDelegate> delegate;
@property (nonatomic) Event *event;

@end

NS_ASSUME_NONNULL_END
