//
//  CalendarViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "CalendarViewController.h"
#import "ComposeViewController.h"

#import "ScheduleScrollView.h"
#import "ScheduleDecorator.h"

#import "FSCalendar/FSCalendar.h"
#import "ParseEventHandler.h"

@interface CalendarViewController () <ComposeViewControllerDelegate, ParseEventHandlerDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *calendarDisplay;
@property (weak, nonatomic) IBOutlet ScheduleScrollView *scheduleView;

@property (nonatomic) ParseEventHandler *parseHandler;
@property (nonatomic) ScheduleDecorator *scheduleDecorator;
@property (nonatomic) NSMutableArray<Event *> *events;
@property (nonatomic) NSDate *date;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parseHandler = [[ParseEventHandler alloc] init];
    self.parseHandler.delegate = self;

    self.date = [NSDate date];
    self.scheduleDecorator = [[ScheduleDecorator alloc] init];
    [self.scheduleDecorator decorateBaseScheduleWithDate:self.date contentView:self.scheduleView];
    
    [self fetchData];
}

- (void)fetchData {
    [self.parseHandler queryUserEventsOnDate:self.date];
}

- (void)successfullyUploadedEvent:(Event *)event {
    [self.scheduleDecorator addEvent:event contentView:self.scheduleView];
}

- (void)successfullyQueriedWithEvents:(NSMutableArray<Event *> *)events {
    self.events = events;
    [self.scheduleDecorator addEvents:(NSArray<Event *> *)self.events contentView:self.scheduleView];
}

- (void)failedRequestWithMessage:(NSString *)errorMessage {
    
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

@end
