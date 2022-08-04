//
//  ComposeScrollView.h
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ComposeScrollView : UIScrollView

@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet UITextField *locationTextField;
@property (weak, nonatomic) IBOutlet UITextView *descriptionTextView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *chooseCalendarSegment;
@property (weak, nonatomic) IBOutlet UISwitch *allDaySwitch;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descriptionLabelTopConstraint;
@property (weak, nonatomic) IBOutlet UISwitch *reminderSwitch;
@property (weak, nonatomic) IBOutlet UILabel *alertTimeLabel;
@property (weak, nonatomic) IBOutlet UIDatePicker *alertTimePicker;

@end

NS_ASSUME_NONNULL_END
