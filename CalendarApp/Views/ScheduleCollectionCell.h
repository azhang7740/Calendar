//
//  ScheduleCollectionCell.h
//  Calendar
//
//  Created by Angelina Zhang on 7/11/22.
//

#import <UIKit/UIKit.h>
#import "ScheduleScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface ScheduleCollectionCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet ScheduleScrollView *scheduleView;

@end

NS_ASSUME_NONNULL_END
