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
#import "ParseEventHandler.h"
#import "EKEventHandler.h"

@interface ScheduleViewController () <EventInteraction, DetailsViewControllerDelegate, ComposeViewControllerDelegate>

@property (nonatomic) DailyCalendarViewController* scheduleView;
@property (nonatomic) AuthenticationHandler *authenticationHandler;
@property (nonatomic) ParseEventHandler *parseHandler;
@property (nonatomic) EKEventHandler *ekEventHandler;

@property (nonatomic) NSMutableDictionary<NSDate *, NSMutableArray<Event *> *> *datesToEvents;
@property (nonatomic) NSMutableDictionary<NSUUID *, Event *> *objectIDToEvents;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduleView = [[DailyCalendarViewController alloc] init];
    self.scheduleView.controllerDelegate = self;
    self.parseHandler = [[ParseEventHandler alloc] init];
    self.ekEventHandler = [[EKEventHandler alloc] init];
    [self.ekEventHandler requestAccessToCalendarWithCompletion:^(BOOL success, NSString * _Nullable error) {
        if (error) {
            [self failedRequestWithMessage:error];
        }
    }];
    self.authenticationHandler = [[AuthenticationHandler alloc] init];
    self.datesToEvents = [[NSMutableDictionary alloc] init];
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
    if ([self.datesToEvents objectForKey:date]) {
        callback(self.datesToEvents[date], nil);
    } else {
        [self.parseHandler queryEventsOnDate:date
                                      completion:^(NSMutableArray<Event *> * _Nullable events, NSDate * _Nonnull date, NSString * _Nullable error) {
            if (error) {
                callback(nil, error);
            } else {
                self.datesToEvents[date] = events;
                for (Event *newEvent in events) {
                    self.objectIDToEvents[newEvent.objectUUID] = newEvent;
                }
                callback(events, nil);
            }
        }];
    }
}

- (void)didTapEvent:(NSUUID *)eventID {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Details" bundle:[NSBundle mainBundle]];
    UINavigationController *detailsNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"DetailsNavigation"];
    DetailsViewController *detailsView = (DetailsViewController *)detailsNavigationController.topViewController;
    detailsView.event = self.objectIDToEvents[eventID];
    detailsView.delegate = self;
    [self presentViewController:detailsNavigationController animated:YES completion:nil];
}

- (void)didLongPressEvent:(NSUUID *)eventID {

}

- (void)didLongPressTimeline:(NSDate *)date {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compose" bundle:[NSBundle mainBundle]];
    UINavigationController *composeNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ComposeNavigation"];
    ComposeViewController *composeView = (ComposeViewController *)composeNavigationController.topViewController;
    composeView.delegate = self;
    composeView.currentUserName = [self.parseHandler getCurrentUsername];
    composeView.date = date;
    [self presentViewController:composeNavigationController animated:YES completion:nil];
}

- (void)didTapClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didDeleteEvent:(Event *)event {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *midnight = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:event.startDate options:0];
    [self.datesToEvents[midnight] removeObject:event];
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.scheduleView deleteCalendarEvent:event :midnight];
}

- (void)didUpdateEvent:(Event *)event
          originalDate:(NSDate *)date {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *newMidnightStart = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:event.startDate options:0];
    NSDate *prevMidnightStart = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:event.startDate options:0];
    [self.scheduleView updateCalendarEvent:event :prevMidnightStart :newMidnightStart];
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
    composeView.currentUserName = [self.parseHandler getCurrentUsername];
    [self presentViewController:composeNavigationController animated:YES completion:nil];
}

- (void)didTapChangeEvent:(Event *)event
             originalDate:(NSDate *)date{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.parseHandler uploadWithEvent:event completion:^(Event * _Nonnull parseEvent, NSDate * _Nonnull date, NSString * _Nullable error) {
        if (error) {
            [self failedRequestWithMessage:error];
        } else {
            self.objectIDToEvents[parseEvent.objectUUID] = parseEvent;
            [self.datesToEvents[date] addObject:parseEvent];
            [self.scheduleView addEvent: parseEvent: date];
        }
    }];
}

@end
