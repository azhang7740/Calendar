//
//  DetailsView.h
//  Calendar
//
//  Created by Angelina Zhang on 7/13/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DetailsViewDelegate

- (void)didTapClose;
- (void)didTapEdit;
- (void)didTapDelete;

@end

@interface DetailsView : UIView

@property (weak, nonatomic) id<DetailsViewDelegate> delegate;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UIImageView *timeIcon;

@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *locationIcon;

@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *descriptionIcon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionIconTopConstraint;

@end

NS_ASSUME_NONNULL_END
