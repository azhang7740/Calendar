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
                                      ComposeViewControllerDelegate, LocalChangeSyncDelegate>

@property (nonatomic) DailyCalendarViewController* scheduleView;
@property (nonatomic) AuthenticationHandler *authenticationHandler;
@property (nonatomic) FetchEventHandler *eventHandler;
@property (nonatomic) NSMutableDictionary<NSUUID *, Event *> *objectIDToEvents;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduleView = [[DailyCalendarViewController alloc] init];
    self.scheduleView.controllerDelegate = self;
    self.eventHandler = [[FetchEventHandler alloc] init:self];
    self.authenticationHandler = [[AuthenticationHandler alloc] init];
    self.objectIDToEvents = [[NSMutableDictionary alloc] init];
    
    [self addChildViewController:self.scheduleView];
    [self.view addSubview:self.scheduleView.view];
    [self.scheduleView didMoveToParentViewController:self];
    self.scheduleView.view.frame = self.view.bounds;
}

- (void)failedRequestWithMessage:(NSString *)errorMessage {
    // TODO: error handling
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

@end
