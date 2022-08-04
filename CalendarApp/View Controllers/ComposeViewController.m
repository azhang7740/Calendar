//
//  ComposeViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "ComposeViewController.h"
#import "ComposeScrollView.h"
#import "NSDate+Midnight.h"

@interface ComposeViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet ComposeScrollView *composeView;
@property (weak, nonatomic) IBOutlet UIButton *createUpdateButton;
@property (nonatomic) NotificationHandler *notificationHandler;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.notificationHandler = [[NotificationHandler alloc] init];
    if (self.event) {
        [self setViewEvent];
    } else {
        [self setViewDate];
    }
    
    if ([self.composeView.descriptionTextView.text  isEqual:@""]) {
        self.composeView.descriptionTextView.text = @"Type here...";
        self.composeView.descriptionTextView.textColor = UIColor.lightGrayColor;
    }
    
    self.composeView.descriptionTextView.delegate = self;
    
    self.composeView.errorLabel.text = @"";
}

- (void)setViewDate {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.hour = 1;
    if (!self.date) {
        self.date = [NSDate date];
    }
    self.composeView.startDatePicker.date = self.date;
    self.composeView.endDatePicker.date = [calendar dateByAddingComponents:dayComponent toDate:self.date options:0];
}

- (void)setViewEvent {
    [self.composeView.chooseCalendarSegment setEnabled:false];
    if (self.event.ekEventID) {
        [self.composeView.chooseCalendarSegment setSelectedSegmentIndex:1];
    }
    
    NSDate *reminderDate = [self.notificationHandler checkReminderForEvent:self.event.objectUUID];
    if (reminderDate) {
        [self.composeView.reminderSwitch setOn:true];
        [self.composeView.alertTimePicker setDate:reminderDate];
    } else {
        [self.composeView.alertTimePicker setHidden:true];
        [self.composeView.alertTimeLabel setHidden:true];
        [self.composeView.descriptionLabelTopConstraint setConstant:20];
    }
    
    self.composeView.titleTextField.text = self.event.eventTitle;
    self.composeView.startDatePicker.date = self.event.startDate;
    self.composeView.endDatePicker.date = self.event.endDate;
    
    self.composeView.locationTextField.text = self.event.location;
    self.composeView.descriptionTextView.text = self.event.eventDescription;
    [self.composeView.allDaySwitch setOn:self.event.isAllDay];
    
    [self.createUpdateButton setTitle:@"Update" forState:UIControlStateNormal];
}

- (Event *)createEventFromView {
    if (![self inputIsValid]) {
        return nil;
    }
    Event *newEvent = [[Event alloc] init];
    newEvent.objectUUID = [NSUUID UUID];
    newEvent.createdAt = [NSDate date];
    [self setEventFields:newEvent];
    
    return newEvent;
}

- (Event *)updateEventFromView {
    [self setEventFields:self.event];
    return self.event;
}

- (void)setEventFields:(Event *)newEvent {
    newEvent.eventTitle = self.composeView.titleTextField.text;
    
    newEvent.authorUsername = self.currentUserName;
    newEvent.location = self.composeView.locationTextField.text;
    newEvent.startDate = self.composeView.startDatePicker.date;
    newEvent.endDate = self.composeView.endDatePicker.date;
    newEvent.updatedAt = [NSDate date];
    newEvent.isAllDay = self.composeView.allDaySwitch.isOn;
    
    if (self.composeView.descriptionTextView.textColor
        == UIColor.lightGrayColor) {
        newEvent.eventDescription = @"";
    } else {
        newEvent.eventDescription = self.composeView.descriptionTextView.text;
    }
}

- (BOOL)inputIsValid {
    if (self.composeView.titleTextField.text.length == 0) {
        [self displayErrorMessage:@"Title field is empty."];
        return false;
    }
    
    if ([self.composeView.startDatePicker.date compare:
         self.composeView.endDatePicker.date] != NSOrderedAscending) {
        [self displayErrorMessage:@"End date should be after start date."];
        return false;
    }
    
    return true;
}

- (void)displayErrorMessage:(NSString *)message {
    self.composeView.errorLabel.text = message;
}

- (IBAction)onTapCancel:(id)sender {
    [self.delegate didTapCancel];
}

- (IBAction)onTapCreate:(id)sender {
    BOOL isEKEvent = self.composeView.chooseCalendarSegment.selectedSegmentIndex == 1;
    if ([self.createUpdateButton.titleLabel.text isEqual:@"Create"]){
        Event *newEvent = [self createEventFromView];
        if (newEvent) {
            [self.delegate didTapChangeEvent:nil
                                    newEvent:newEvent
                             isEventKitEvent:isEKEvent];
        }
    } else if (self.event && [self.createUpdateButton.titleLabel.text isEqual:@"Update"]){
        Event *oldEvent = [[Event alloc] initWithOriginalEvent:self.event];
        Event *updatedEvent = [self updateEventFromView];
        [self.delegate didTapChangeEvent:oldEvent
                                newEvent:updatedEvent
                         isEventKitEvent:isEKEvent];
    }
}

- (IBAction)onTapOutside:(id)sender {
    [self.view endEditing:true];
}

- (IBAction)onChangeAllDaySwitch:(id)sender {
    if (self.composeView.allDaySwitch.isOn) {
        [self.composeView.startDatePicker setDatePickerMode:UIDatePickerModeDate];
        [self.composeView.endDatePicker setDatePickerMode:UIDatePickerModeDate];
    } else {
        [self.composeView.startDatePicker setDatePickerMode:UIDatePickerModeDateAndTime];
        [self.composeView.endDatePicker setDatePickerMode:UIDatePickerModeDateAndTime];
    }
}

- (IBAction)onChangeReminderSwitch:(id)sender {
    if (self.composeView.reminderSwitch.isOn) {
        [self.composeView.alertTimePicker setHidden:false];
        [self.composeView.alertTimeLabel setHidden:false];
        [self.composeView.alertTimePicker setDate:self.event.startDate];
        [self.composeView.descriptionLabelTopConstraint setConstant:50];
    } else {
        [self.composeView.alertTimePicker setHidden:true];
        [self.composeView.alertTimeLabel setHidden:true];
        [self.composeView.descriptionLabelTopConstraint setConstant:20];
    }
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
