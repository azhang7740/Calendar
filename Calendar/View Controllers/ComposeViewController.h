//
//  ComposeViewController.h
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import <UIKit/UIKit.h>
#import "Event.h"

NS_ASSUME_NONNULL_BEGIN

@protocol ComposeViewControllerDelegate

- (void)didTapCancel;
- (void)didTapCreateWithEvent:(Event *)event;

@end

@interface ComposeViewController : UIViewController

@property (nonatomic, weak) id<ComposeViewControllerDelegate> delegate;
@property (nonatomic) NSString *currentUserName;

@end

NS_ASSUME_NONNULL_END
