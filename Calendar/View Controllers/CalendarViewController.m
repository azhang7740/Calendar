//
//  CalendarViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "CalendarViewController.h"
#import "ComposeViewController.h"

#import "ScheduleView.h"
#import "ScheduleCell.h"

#import "FSCalendar/FSCalendar.h"
#import "ParseEventHandler.h"

@interface CalendarViewController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet FSCalendar *calendarDisplay;
@property (weak, nonatomic) IBOutlet ScheduleView *scheduleView;
@property (nonatomic) ParseEventHandler *parseHandler;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parseHandler = [[ParseEventHandler alloc] init];
    self.scheduleView.scheduleTableView.delegate = self;
    self.scheduleView.scheduleTableView.dataSource = self;
    
    UINib *nib = [UINib nibWithNibName:@"ScheduleCell" bundle:nil];
    [self.scheduleView.scheduleTableView registerNib:nib forCellReuseIdentifier:@"ScheduleCellId"];
    self.scheduleView.scheduleTableView.rowHeight = 200;
    [self.scheduleView.scheduleTableView reloadData];
}

- (IBAction)onTapCompose:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compose" bundle:[NSBundle mainBundle]];
    UINavigationController *composeNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ComposeNavigation"];
    ComposeViewController *composeView = (ComposeViewController *)composeNavigationController.topViewController;
    composeView.delegate = self;
    [self presentViewController:composeNavigationController animated:YES completion:nil];
}

- (void)didTapCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapCreateWithEvent:(nonnull Event *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.parseHandler uploadToParseWithEvent:event];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCellId"
                                                         forIndexPath:indexPath];
    cell.eventTitleLabel.text = @"HI";
    cell.timeLabel.text = @"1:00am";
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 24;
}

@end
