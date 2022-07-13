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

@end

NS_ASSUME_NONNULL_END
