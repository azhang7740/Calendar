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

@interface ScheduleViewController () <ScheduleSubViewControllerDelegate, DetailsViewControllerDelegate, ComposeViewControllerDelegate>

@property (nonatomic) ScheduleSubViewController* scheduleView;
@property (nonatomic) AuthenticationHandler *authenticationHandler;
@property (nonatomic) ParseEventHandler *parseHandler;

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scheduleView = [[ScheduleSubViewController alloc] init];
    [self addChildViewController:self.scheduleView];
    [self.view addSubview:self.scheduleView.view];
    
    [self.scheduleView didMoveToParentViewController:self];
    self.scheduleView.view.frame = self.view.bounds;
    self.scheduleView.controllerDelegate = self;
    
    self.authenticationHandler = [[AuthenticationHandler alloc] init];
    self.parseHandler = self.scheduleView.parseEventHandler;
}

- (void)failedRequestWithMessage:(NSString *)errorMessage {
    // TODO: error handling
}


- (void)didTapEvent:(Event *)event {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Details" bundle:[NSBundle mainBundle]];
    UINavigationController *detailsNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"DetailsNavigation"];
    DetailsViewController *detailsView = (DetailsViewController *)detailsNavigationController.topViewController;
    detailsView.event = event;
    detailsView.delegate = self;
    [self presentViewController:detailsNavigationController animated:YES completion:nil];
}

- (void)didLongPressEvent:(Event *)event {
    
}

- (void)didTapClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didDeleteEvent:(Event *)event {
    
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

- (void)didTapCreateWithEvent:(Event *)event {
    
}

@end
