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
@property int prevPage;

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
    self.prevPage = 0;
    
    [self fetchData];
}

- (void)fetchData {
    [self.parseHandler queryUserEventsOnDate:self.date];
}

- (void)successfullyUploadedEvent:(Event *)event {
    [self fetchData];
}

- (void)successfullyQueriedWithEvents:(NSMutableArray<Event *> *)events {
    self.events = events;
    [self.scheduleCollectionView reloadData];
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
    return 3;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleCollectionCell *cell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"scheduleCellId"
                                    forIndexPath:indexPath];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    if (self.prevPage < indexPath.row) {
        dayComponent.day = 1;
        NSDate *nextDate = [calendar dateByAddingComponents:dayComponent toDate:self.date options:0];
        self.date = nextDate;
    } else if (self.prevPage > indexPath.row) {
        dayComponent.day = -1;
        NSDate *nextDate = [calendar dateByAddingComponents:dayComponent toDate:self.date options:0];
        self.date = nextDate;
    }
    self.prevPage = (int)indexPath.row;
    [self.scheduleDecorator decorateBaseScheduleWithDate:self.date contentView:cell.scheduleView];
    [self.scheduleDecorator addEvents:self.events contentView:cell.scheduleView];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.scheduleCollectionView.frame.size.width, self.scheduleCollectionView.frame.size.height);
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
}

@end
