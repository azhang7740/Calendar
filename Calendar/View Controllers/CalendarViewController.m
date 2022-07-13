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
#import "DateLogicHandler.h"

#import "FSCalendar/FSCalendar.h"
#import "ParseEventHandler.h"

@interface CalendarViewController () <ComposeViewControllerDelegate, ParseEventHandlerDelegate, ScheduleDecoratorDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) ParseEventHandler *parseHandler;
@property (nonatomic) ScheduleDecorator *scheduleDecorator;

@property (weak, nonatomic) IBOutlet UICollectionView *scheduleCollectionView;
@property (nonatomic) DateLogicHandler *dateLogicHandler;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parseHandler = [[ParseEventHandler alloc] init];
    self.parseHandler.delegate = self;
    
    self.dateLogicHandler = [[DateLogicHandler alloc] init];
    
    self.scheduleDecorator = [[ScheduleDecorator alloc] init];
    self.scheduleDecorator.delegate = self;
}

- (void)addDatesToEnd {
    [self.dateLogicHandler appendDatesWithCount:7];
    [self.scheduleCollectionView reloadData];
}

- (void)addDatesToStart {
    [self.dateLogicHandler prependDatesWithCount:7];
    [self.scheduleCollectionView reloadData];
}

- (void)fetchDataWithDate:(NSDate *)date {
    [self.parseHandler queryUserEventsOnDate:date];
}

- (void)successfullyUploadedEvent:(Event *)event
                          forDate:(NSDate *)date {
    int index = [self.dateLogicHandler getItemIndexWithDate:date];
    if (index != -1) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
        NSArray<NSIndexPath *> *arrayOfNewIndexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.scheduleCollectionView reloadItemsAtIndexPaths:arrayOfNewIndexPaths];
    }
}

- (void)successfullyQueriedWithEvents:(NSMutableArray<Event *> *)events
                              forDate:(NSDate *)date {
    [self.dateLogicHandler addNewEventsWithArray:events forDate:date];
    int index = [self.dateLogicHandler getItemIndexWithDate:date];
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:index inSection:0];
    ScheduleCollectionCell *cell = (ScheduleCollectionCell *)[self.scheduleCollectionView cellForItemAtIndexPath:indexPath];
    [self.scheduleDecorator addEvents:[self.dateLogicHandler getEventsForIndex:(int)indexPath.row] contentView:cell.scheduleView];
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
    return [self.dateLogicHandler getNumberOfElements];
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ScheduleCollectionCell *cell = [collectionView
                                    dequeueReusableCellWithReuseIdentifier:@"scheduleCellId"
                                    forIndexPath:indexPath];
    NSDate *date = [self.dateLogicHandler getDateForIndex:(int)indexPath.row];
    [self.scheduleDecorator decorateBaseScheduleWithDate:date contentView:cell.scheduleView];
    
    int numberOfEvents = [self.dateLogicHandler getNumberOfEventsForDate:date];
    if (numberOfEvents == 0) {
        [self fetchDataWithDate:date];
    } else if (numberOfEvents > 0) {
        [self.scheduleDecorator addEvents:[self.dateLogicHandler getEventsForIndex:(int)indexPath.row] contentView:cell.scheduleView];
    }
    
    if (indexPath.row == 0) {
        [self addDatesToStart];
        NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:[self.dateLogicHandler scrollToItemAfterPrependingDates] inSection:0];
        [self.scheduleCollectionView scrollToItemAtIndexPath:newIndexPath atScrollPosition:UICollectionViewScrollPositionNone animated:false];
    }
    if (indexPath.row == [self.dateLogicHandler getNumberOfElements] - 2) {
        [self addDatesToEnd];
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.scheduleCollectionView.frame.size.width, self.scheduleCollectionView.frame.size.height);
}

@end
