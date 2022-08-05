//
//  DetailsViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/13/22.
//

#import "DetailsViewController.h"
#import "DetailsView.h"
#import "ComposeViewController.h"
#import "FetchEventHandler.h"

@interface DetailsViewController () <DetailsViewDelegate, ComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet DetailsView *detailsView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailsView.delegate = self;
    [self updateDetailsView];
}

- (void)updateDetailsView {
    self.detailsView.eventTitleLabel.text = self.event.eventTitle;
    self.detailsView.timeLabel.text = [self getTimeString];
    
    if ([self.event.location isEqual:@""]) {
        [self.detailsView.locationIcon setHidden:true];
        [self.detailsView.locationLabel setHidden:true];
        
        [self.detailsView.descriptionLocationTopConstraint setConstant:0];
    } else {
        [self.detailsView.locationIcon setHidden:false];
        [self.detailsView.locationLabel setHidden:false];
        self.detailsView.locationLabel.text = self.event.location;
        
        [self.detailsView.descriptionLocationTopConstraint setConstant:50];
    }
    
    if ([self.event.eventDescription isEqual:@""]) {
        [self.detailsView.descriptionIcon setHidden:true];
        [self.detailsView.descriptionLabel setHidden:true];
    } else {
        [self.detailsView.descriptionIcon setHidden:false];
        [self.detailsView.descriptionLabel setHidden:false];
        
        self.detailsView.descriptionLabel.text = self.event.eventDescription;
    }
}

- (NSString *)getTimeString {
    NSString *finalString;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocalizedDateFormatFromTemplate:@"EE, MMM d, yyyy"];
    NSString *startDay = [dateFormatter stringFromDate:self.event.startDate];
    NSString *endDay = [dateFormatter stringFromDate:self.event.endDate];
    
    if (self.event.isAllDay) {
        return [startDay stringByAppendingString:@" (All day)"];
    }
    [dateFormatter setLocalizedDateFormatFromTemplate:@"h:mm"];
    NSString *startTime = [dateFormatter stringFromDate:self.event.startDate];
    NSString *endTime = [dateFormatter stringFromDate:self.event.endDate];
    NSString *startDateTime = [[startDay stringByAppendingString:@" "] stringByAppendingString:startTime];
    if ([startDay isEqual:endDay]) {
        finalString = [[startDateTime stringByAppendingString:@" - "]
                       stringByAppendingString:endTime];
    } else {
        NSString *endDateTime = [[endDay stringByAppendingString:@" "] stringByAppendingString:endTime];
        finalString = [[startDateTime stringByAppendingString:@" - "]
                       stringByAppendingString:endDateTime];
    }
    return finalString;
}

- (void)didTapClose {
    [self.delegate didTapClose];
}

- (void)didTapEdit {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compose" bundle:[NSBundle mainBundle]];
    UINavigationController *composeNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ComposeNavigation"];
    ComposeViewController *composeView = (ComposeViewController *)composeNavigationController.topViewController;
    composeView.delegate = self;
    composeView.event = self.event;
    [self presentViewController:composeNavigationController animated:YES completion:nil];
}

- (void)didTapDelete {
    NSString *eventID = (self.event.ekEventID) ? self.event.ekEventID : [self.event.objectUUID UUIDString];
    [self.eventHandler deleteEvent:eventID
                        completion:^(BOOL success, NSString * _Nullable error) {
        if (success) {
            [self.delegate didDeleteEventOnDetailView:self.event];
        } else {
            // TODO: error handling
        }
    }];
}

- (void)didTapCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapChangeEvent:(Event *)oldEvent
                 newEvent:(Event *)updatedEvent
          isEventKitEvent:(BOOL)isEventKit{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.eventHandler updateEvent:oldEvent
                          newEvent:updatedEvent
                        completion:^(BOOL success, NSString * _Nullable error) {
        if (success) {
            [self updateDetailsView];
            [self.delegate didUpdateEvent:oldEvent
                                 newEvent:updatedEvent];
        } else {
            // TODO: error handling
        }
    }];
}

@end
