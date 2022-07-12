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

@interface CalendarViewController () <ComposeViewControllerDelegate, ParseEventHandlerDelegate, ScheduleDecoratorDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (nonatomic) ParseEventHandler *parseHandler;
@property (nonatomic) ScheduleDecorator *scheduleDecorator;

@property (weak, nonatomic) IBOutlet UICollectionView *scheduleCollectionView;
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
    [self.dates addObject:self.today];
    [self addDatesToEnd];
    
    self.scheduleDecorator = [[ScheduleDecorator alloc] init];
    self.scheduleDecorator.delegate = self;
}

- (void)addDatesToEnd {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    
    for (int i = 0; i < 7; i++) {
        [self.dates addObject:[self.calendar dateByAddingComponents:dayComponent
                                                             toDate:self.dates[self.dates.count - 1]
                                                            options:0]];
        [self.events addObject:[[NSMutableArray alloc] init]];
    }
    [self.scheduleCollectionView reloadData];
}

- (void)addDatesToStart {
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = -1;
    
    for (int i = 0; i < 7; i++) {
        [self.dates insertObject:[self.calendar dateByAddingComponents:dayComponent toDate:self.dates[0] options:0]
                         atIndex:0];
        [self.events insertObject:[[NSMutableArray alloc] init] atIndex:0];
    }
    [self.scheduleCollectionView reloadData];
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
        [self.events[[differenceComponents day]] addObject:event];
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[differenceComponents day] inSection:0];
        NSArray<NSIndexPath *> *arrayOfNewIndexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.scheduleCollectionView reloadItemsAtIndexPaths:arrayOfNewIndexPaths];
    }
}

- (void)successfullyQueriedWithEvents:(NSMutableArray<Event *> *)events
                              forDate:(NSDate *)date {
    NSDateComponents *differenceComponents = [self.calendar components:(NSCalendarUnitDay)
                                                              fromDate:self.dates[0]
                                                                toDate:date
                                                               options:0];
    self.events[[differenceComponents day]] = events;
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:[differenceComponents day] inSection:0];
    ScheduleCollectionCell *cell = (ScheduleCollectionCell *)[self.scheduleCollectionView cellForItemAtIndexPath:indexPath];
    [self.scheduleDecorator addEvents:self.events[indexPath.row] contentView:cell.scheduleView];
}

- (void)failedRequestWithMessage:(NSString *)errorMessage {
    
}

- (void)didTapView:(NSUUID *)eventId {
    // find corresponding view
    // display details view controller
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
    if (self.events[indexPath.row].count == 0) {
        [self fetchDataWithDate:self.dates[indexPath.row]];
    } else {
        [self.scheduleDecorator addEvents:self.events[indexPath.row] contentView:cell.scheduleView];
    }
    
    if (indexPath.row == 0) {
        [self addDatesToStart];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:7 inSection:0];
        [self.scheduleCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:false];
    }
    if (indexPath.row == self.dates.count - 2) {
        [self addDatesToEnd];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.scheduleCollectionView.frame.size.width, self.scheduleCollectionView.frame.size.height);
}

@end
