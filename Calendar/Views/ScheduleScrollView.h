//
//  ScheduleScrollView.h
//  Calendar
//
//  Created by Angelina Zhang on 7/9/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleScrollView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIView *scrollView;

@end

NS_ASSUME_NONNULL_END
