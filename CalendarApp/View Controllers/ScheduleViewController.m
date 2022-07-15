//
//  ScheduleViewController.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/14/22.
//

#import "ScheduleViewController.h"
#import "DetailsViewController.h"
#import "CalendarApp-Swift.h"

@interface ScheduleViewController () <ScheduleSubViewControllerDelegate, DetailsViewControllerDelegate>

@property (nonatomic) ScheduleSubViewController* scheduleView;

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

@end
