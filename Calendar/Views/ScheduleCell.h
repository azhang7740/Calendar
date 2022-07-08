//
//  EventCell.h
//  Calendar
//
//  Created by Angelina Zhang on 7/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIView *titleLabelView;
@property (weak, nonatomic) IBOutlet UIView *eventBodyView;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@end

NS_ASSUME_NONNULL_END
