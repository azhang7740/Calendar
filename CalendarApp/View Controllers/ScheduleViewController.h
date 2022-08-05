//
//  ScheduleViewController.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/14/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class NotificationReceiveHandler;

@interface ScheduleViewController : UIViewController

@property (nonatomic) NotificationReceiveHandler *receiveHandler;

@end

NS_ASSUME_NONNULL_END
