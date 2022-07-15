//
//  ScheduleViewController.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/14/22.
//

#import "ScheduleViewController.h"
#import "CalendarApp-Swift.h"

@interface ScheduleViewController ()

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
}

@end
