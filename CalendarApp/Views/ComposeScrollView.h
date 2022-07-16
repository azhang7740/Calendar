//
//  ComposeScrollView.h
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComposeScrollView : UIScrollView

@property (nonatomic) IBOutlet UILabel *errorLabel;
@property (nonatomic) IBOutlet UITextField *titleTextField;
@property (nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (nonatomic) IBOutlet UITextField *locationTextField;
@property (nonatomic) IBOutlet UITextView *descriptionTextView;

@end

NS_ASSUME_NONNULL_END
