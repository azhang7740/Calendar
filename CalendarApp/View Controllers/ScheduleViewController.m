//
//  ScheduleViewController.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/14/22.
//

#import "ScheduleViewController.h"
#import "DetailsViewController.h"
#import "ComposeViewController.h"

#import "CalendarApp-Swift.h"
#import "AuthenticationHandler.h"
#import "FetchEventHandler.h"
#import "NSDate+Midnight.h"

@interface ScheduleViewController () <EventInteraction, DetailsViewControllerDelegate,
ComposeViewControllerDelegate, LocalChangeSyncDelegate,
RemoteEventUpdates>

@property (nonatomic) DailyCalendarViewController* scheduleView;
@property (nonatomic) AuthenticationHandler *authenticationHandler;
@property (nonatomic) FetchEventHandler *eventHandler;
@property (nonatomic) NSMutableDictionary<NSUUID *, Event *> *objectIDToEvents;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *push;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightPush;
@property (weak, nonatomic) IBOutlet UILabel *errorMessageLabel;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduleView = [[DailyCalendarViewController alloc] init];
    self.scheduleView.controllerDelegate = self;
    self.eventHandler = [[FetchEventHandler alloc] init:self
                                   remoteChangeDelegate:self];
    self.authenticationHandler = [[AuthenticationHandler alloc] init];
    self.objectIDToEvents = [[NSMutableDictionary alloc] init];
    
    self.scheduleView.view.translatesAutoresizingMaskIntoConstraints = false;
    [self addChildViewController:self.scheduleView];
    [self.containerView addSubview:self.scheduleView.view];
    [self.scheduleView didMoveToParentViewController:self];
    [[self.scheduleView.view.topAnchor constraintEqualToAnchor:self.containerView.topAnchor constant:0] setActive:true];
    [[self.scheduleView.view.bottomAnchor constraintEqualToAnchor:self.containerView.bottomAnchor constant:0] setActive:true];
    [[self.scheduleView.view.rightAnchor constraintEqualToAnchor:self.containerView.rightAnchor constant:0] setActive:true];
    [[self.scheduleView.view.leftAnchor constraintEqualToAnchor:self.containerView.leftAnchor constant:0] setActive:true];
}

- (void)displayMessage:(NSString *)message {
    self.rightPush.constant = 0;
    self.errorMessageLabel.text = message;
    [self.view layoutIfNeeded];
    
    [UIView animateWithDuration:2
                     animations:^{
        self.push.constant = 70;
        [self.view layoutIfNeeded];
    }];
}

- (void)remoteEventsDidChange {
    self.scheduleView = [[DailyCalendarViewController alloc] init];
    self.scheduleView.controllerDelegate = self;
    self.objectIDToEvents = [[NSMutableDictionary alloc] init];
    
    [self addChildViewController:self.scheduleView];
    [self.view addSubview:self.scheduleView.view];
    [self.scheduleView didMoveToParentViewController:self];
    self.scheduleView.view.frame = self.view.bounds;
}

- (void)failedRequestWithMessage:(NSString *)errorMessage {
    [self displayMessage:errorMessage];
}

- (void)fetchEventsForDate:(NSDate *)date
                  callback:(void (^)(NSArray<Event *> * _Nullable, NSString * _Nullable))callback {
    [self.eventHandler queryEventsOnDate:date
                              completion:^(BOOL success, NSMutableArray<Event *> * _Nullable events, NSDate * _Nonnull date, NSString * _Nullable error) {
        if (error) {
            callback(nil, error);
        } else {
            for (Event *newEvent in events) {
                self.objectIDToEvents[newEvent.objectUUID] = newEvent;
            }
            callback(events, nil);
        }
    }];
}

- (void)didTapEvent:(NSUUID *)eventID {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Details" bundle:[NSBundle mainBundle]];
    UINavigationController *detailsNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"DetailsNavigation"];
    DetailsViewController *detailsView = (DetailsViewController *)detailsNavigationController.topViewController;
    detailsView.event = self.objectIDToEvents[eventID];
    detailsView.delegate = self;
    detailsView.eventHandler = self.eventHandler;
    [self presentViewController:detailsNavigationController animated:YES completion:nil];
}

- (void)didLongPressEvent:(NSUUID *)eventID {
    
}

- (void)didLongPressTimeline:(NSDate *)date {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compose" bundle:[NSBundle mainBundle]];
    UINavigationController *composeNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ComposeNavigation"];
    ComposeViewController *composeView = (ComposeViewController *)composeNavigationController.topViewController;
    composeView.delegate = self;
    composeView.date = date;
    [self presentViewController:composeNavigationController animated:YES completion:nil];
}

- (void)didTapClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didDeleteEventOnDetailView:(Event *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.scheduleView deleteCalendarEvent:event];
}

- (void)didDeleteEvent:(Event *)event {
    [self.scheduleView deleteCalendarEvent:event];
}

- (void)didUpdateEvent:(Event *)oldEvent
              newEvent:(Event *)updatedEvent {
    [self.scheduleView updateCalendarEvent:updatedEvent
                         originalStartDate:oldEvent.startDate.midnight
                           originalEndDate:oldEvent.startDate.midnight];
}

- (void)didCreateEvent:(Event *)newEvent {
    self.objectIDToEvents[newEvent.objectUUID] = newEvent;
    [self.scheduleView addEvent:newEvent];
}

- (void)didTapCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTapLogout:(id)sender {
    [self.authenticationHandler logoutWithCompletion:^(NSString * _Nullable error) {
        if (error) {
            [self failedRequestWithMessage:error];
        }
    }];
}

- (IBAction)onTapAdd:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compose" bundle:[NSBundle mainBundle]];
    UINavigationController *composeNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ComposeNavigation"];
    ComposeViewController *composeView = (ComposeViewController *)composeNavigationController.topViewController;
    composeView.delegate = self;
    [self presentViewController:composeNavigationController animated:YES completion:nil];
}

- (void)didTapChangeEvent:(Event *)oldEvent
                 newEvent:(Event *)updatedEvent {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.eventHandler uploadWithEvent:updatedEvent completion:^(BOOL success, NSString * _Nullable error) {
        if (error) {
            [self failedRequestWithMessage:error];
        } else {
            self.objectIDToEvents[updatedEvent.objectUUID] = updatedEvent;
            [self.scheduleView addEvent:updatedEvent];
        }
    }];
}

- (IBAction)didSwipeOnAlert:(id)sender {
    [self.view layoutIfNeeded];
    [UIView animateWithDuration:1
                     animations:^{
        self.rightPush.constant = 200;
        self.push.constant = 0;
        [self.view layoutIfNeeded];
    }];
}

@end
