//
//  ScheduleViewController.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/14/22.
//

#import "ScheduleViewController.h"
#import "CalendarApp-Swift.h"

@interface ScheduleViewController ()

@end

@implementation ScheduleViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    ScheduleSubViewController *scheduleView = [[ScheduleSubViewController alloc] init];
    [self addChildViewController:scheduleView];
    [self.view addSubview:scheduleView.view];
    
    [scheduleView didMoveToParentViewController:self];
    scheduleView.view.frame = self.view.bounds;
}

@end
