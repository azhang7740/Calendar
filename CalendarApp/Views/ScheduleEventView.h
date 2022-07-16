//
//  ScheduleEventView.h
//  Calendar
//
//  Created by Angelina Zhang on 7/11/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleEventView : UIView

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (nonatomic) NSUUID *eventId;

@end

NS_ASSUME_NONNULL_END
