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
#import "ScheduleCollectionCell.h"

#import "FSCalendar/FSCalendar.h"
#import "ParseEventHandler.h"

@interface CalendarViewController () <ComposeViewControllerDelegate, ParseEventHandlerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *calendarDisplay;
@property (weak, nonatomic) IBOutlet UICollectionView *scheduleCollectionView;
@property (nonatomic) CGFloat lastContentOffset;

@property (nonatomic) ParseEventHandler *parseHandler;
@property (nonatomic) ScheduleDecorator *scheduleDecorator;
@property (nonatomic) NSMutableArray<NSMutableArray<Event *> *> *events;
@property (nonatomic) NSMutableArray<NSDate *> *dates;

@property (nonatomic) NSCalendar *calendar;
@property (nonatomic) NSDate *today;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parseHandler = [[ParseEventHandler alloc] init];
    self.parseHandler.delegate = self;
    
    self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [self.calendar setTimeZone:[NSTimeZone systemTimeZone]];
    self.today = [self.calendar dateBySettingHour:0 minute:0 second:0 ofDate:[NSDate date] options:0];
    self.dates = [[NSMutableArray alloc] init];
    self.events = [[NSMutableArray alloc] init];
    [self addDatesToEndWithDate:self.today];
    
    self.scheduleDecorator = [[ScheduleDecorator alloc] init];
    [self fetchData];
}

- (void)addDatesToEndWithDate:(NSDate *)date {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 0;
    
    for (int i = 0; i < 7; i++) {
        [self.dates addObject:[self.calendar dateByAddingComponents:dayComponent toDate:date options:0]];
        [self.events addObject:[[NSMutableArray alloc] init]];
        dayComponent.day += 1;
    }
}

- (void)fetchData {
    for (NSDate *date in self.dates) {
        [self fetchDataWithDate:date];
    }
}

- (void)fetchDataWithDate:(NSDate *)date {
    [self.parseHandler queryUserEventsOnDate:date];
}

- (void)successfullyUploadedEvent:(Event *)event
                          forDate:(NSDate *)date {
    NSDateComponents *differenceComponents = [self.calendar components:(NSCalendarUnitDay)
                                                              fromDate:self.dates[0]
                                                                toDate:date
                                                               options:0];
    if ([differenceComponents day] < self.dates.count) {
        [self fetchDataWithDate:date];
    }
}

- (void)successfullyQueriedWithEvents:(NSMutableArray<Event *> *)events
                              forDate:(NSDate *)date {
    NSDateComponents *differenceComponents = [self.calendar components:(NSCalendarUnitDay)
                                                              fromDate:self.dates[0]
                                                                toDate:date
                                                               options:0];
    self.events[[differenceComponents day]] = events;
    [self.scheduleCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:[differenceComponents day]
                                                                            inSection:0]];
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

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dates.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleCollectionCell *cell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"scheduleCellId"
                                    forIndexPath:indexPath];
    [self.scheduleDecorator decorateBaseScheduleWithDate:self.dates[indexPath.row] contentView:cell.scheduleView];
    [self.scheduleDecorator addEvents:self.events[indexPath.row] contentView:cell.scheduleView];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.scheduleCollectionView.frame.size.width, self.scheduleCollectionView.frame.size.height);
}

@end
