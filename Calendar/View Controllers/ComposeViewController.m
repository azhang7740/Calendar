//
//  ComposeViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "ComposeViewController.h"
#import "ComposeScrollView.h"

@interface ComposeViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet ComposeScrollView *composeView;
@property (nonatomic) UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *updateParseButton;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.event) {
        self.composeView.titleTextField.text = self.event.eventTitle;
        self.composeView.startDatePicker.date = self.event.startDate;
        self.composeView.endDatePicker.date = self.event.endDate;
        
        self.composeView.locationTextField.text = self.event.location;
        self.composeView.descriptionTextView.text = self.event.eventDescription;
        
        [self.updateParseButton setTitle:@"Update" forState:UIControlStateNormal];
    }
    
    if ([self.composeView.descriptionTextView.text  isEqual:@""]) {
        self.composeView.descriptionTextView.text = @"Type here...";
        self.composeView.descriptionTextView.textColor = UIColor.lightGrayColor;
    }
    
    self.composeView.descriptionTextView.delegate = self;
    
    self.composeView.errorLabel.text = @"";
}

- (Event *)createEventFromView {
    if (self.composeView.titleTextField.text.length == 0) {
        [self displayErrorMessage:@"Title field is empty."];
        return nil;
    }
    
    if ([self.composeView.startDatePicker.date compare:
         self.composeView.endDatePicker.date] != NSOrderedAscending) {
        [self displayErrorMessage:@"End date should be after start date."];
        return nil;
    }
    
    Event *newEvent = [[Event alloc] init];
    newEvent.eventTitle = self.composeView.titleTextField.text;
    newEvent.objectUUID = [NSUUID UUID];
    
    newEvent.authorUsername = self.currentUserName;
    newEvent.location = self.composeView.locationTextField.text;
    newEvent.startDate = self.composeView.startDatePicker.date;
    newEvent.endDate = self.composeView.endDatePicker.date;
    
    if (self.composeView.descriptionTextView.textColor
        == UIColor.lightGrayColor) {
        newEvent.eventDescription = @"";
    } else {
        newEvent.eventDescription = self.composeView.descriptionTextView.text;
    }
    
    return newEvent;
}

- (void)displayErrorMessage:(NSString *)message {
    self.composeView.errorLabel.text = message;
}

- (IBAction)onTapCancel:(id)sender {
    [self.delegate didTapCancel];
}

- (IBAction)onTapCreate:(id)sender {
    if ([self.updateParseButton.currentTitle isEqual:@"Create"]) {
        Event *newEvent = [self createEventFromView];
        if (newEvent) {
            [self.delegate didTapCreateWithEvent:newEvent];
        }
    } else {
        [self.delegate didTapCreateWithEvent:self.event];
    }
}

- (IBAction)onTapOutside:(id)sender {
    [self.view endEditing:true];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    BOOL isEmptyCaption = self.composeView.descriptionTextView.textColor == UIColor.lightGrayColor;
    if (isEmptyCaption) {
        self.composeView.descriptionTextView.text = nil;
        self.composeView.descriptionTextView.textColor = UIColor.blackColor;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    BOOL isEmptyCaption = [self.composeView.descriptionTextView.text length] == 0;
    if (isEmptyCaption) {
        self.composeView.descriptionTextView.text = @"Type here...";
        self.composeView.descriptionTextView.textColor = UIColor.lightGrayColor;
    }
}

@end
