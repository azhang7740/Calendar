//
//  DailyScheduleView.h
//  Calendar
//
//  Created by Angelina Zhang on 7/8/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleView : UIView

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UITableView *scheduleTableView;

@end

NS_ASSUME_NONNULL_END
