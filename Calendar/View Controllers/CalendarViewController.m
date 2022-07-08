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
#import "ScheduleCellDecorator.h"

#import "FSCalendar/FSCalendar.h"
#import "ParseEventHandler.h"

@interface CalendarViewController () <ComposeViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet FSCalendar *calendarDisplay;
@property (weak, nonatomic) IBOutlet ScheduleView *scheduleView;

@property (nonatomic) ParseEventHandler *parseHandler;
@property (nonatomic) ScheduleCellDecorator *scheduleCellDecorator;
@property (nonatomic) NSMutableArray<Event *> *events;
@property (nonatomic) NSDate *date;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parseHandler = [[ParseEventHandler alloc] init];
    self.scheduleView.scheduleTableView.delegate = self;
    self.scheduleView.scheduleTableView.dataSource = self;
    self.scheduleCellDecorator = [[ScheduleCellDecorator alloc] init];
    self.date = [NSDate date];
    
    UINib *nib = [UINib nibWithNibName:@"ScheduleCell" bundle:nil];
    [self.scheduleView.scheduleTableView registerNib:nib forCellReuseIdentifier:@"ScheduleCellId"];
    self.scheduleView.scheduleTableView.rowHeight = 150;
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
    [self.scheduleCellDecorator decorateCell:cell
                                   indexPath:indexPath
                                      events:(NSArray *)self.events
                                    pageDate:self.date];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 24;
}

@end
