//
//  CalendarViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "CalendarViewController.h"
#import "ComposeViewController.h"
#import "DetailsViewController.h"

#import "ScheduleScrollView.h"
#import "ScheduleDecorator.h"
#import "ScheduleCollectionCell.h"
#import "EventDateLogicHandler.h"

#import "FSCalendar/FSCalendar.h"
#import "ParseEventHandler.h"

@interface CalendarViewController () <ComposeViewControllerDelegate, ScheduleDecoratorDelegate, DetailsViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic) ParseEventHandler *parseHandler;
@property (nonatomic) ScheduleDecorator *scheduleDecorator;

@property (weak, nonatomic) IBOutlet UICollectionView *scheduleCollectionView;
@property (nonatomic) EventDateLogicHandler *dateLogicHandler;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parseHandler = [[ParseEventHandler alloc] init];
    self.dateLogicHandler = [[EventDateLogicHandler alloc] init];
    
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
    [self.parseHandler queryUserEventsOnDate:date withCompletion:^(NSMutableArray<Event *> * _Nullable events, NSDate * _Nonnull date, NSString * _Nullable error) {
        if (error) {
            [self failedRequestWithMessage:error];
        } else {
            [self successfullyQueriedWithEvents:events forDate:date];
        }
    }];
}

- (void)successfullyUploadedEvent:(Event *)event
                          forDate:(NSDate *)date {
    NSIndexPath *indexPath = [self.dateLogicHandler getItemIndexWithDate:date];
    [self.dateLogicHandler addNewEvent:event forDate:date];
    if (indexPath) {
        NSArray<NSIndexPath *> *arrayOfNewIndexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
        [self.scheduleCollectionView reloadItemsAtIndexPaths:arrayOfNewIndexPaths];
    }
}

- (void)successfullyQueriedWithEvents:(NSMutableArray<Event *> *)events
                              forDate:(NSDate *)date {
    [self.dateLogicHandler addNewEventsWithArray:events forDate:date];
    NSIndexPath *indexPath = [self.dateLogicHandler getItemIndexWithDate:date];
    if (indexPath) {
        ScheduleCollectionCell *cell = (ScheduleCollectionCell *)[self.scheduleCollectionView cellForItemAtIndexPath:indexPath];
        if (cell.scheduleView) {
            [self.scheduleDecorator addEvents:[self.dateLogicHandler getEventsForIndexPath:indexPath] contentView:cell.scheduleView];
        }
    }
}

- (void)failedRequestWithMessage:(NSString *)errorMessage {
    
}

- (void)didTapView:(NSUUID *)eventId {
    Event *detailedEvent = [self.dateLogicHandler getEventFromId:eventId withIndex:[self.scheduleCollectionView indexPathsForVisibleItems]];
    if (detailedEvent) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Details" bundle:[NSBundle mainBundle]];
        UINavigationController *detailsNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"DetailsNavigation"];
        DetailsViewController *detailsView = (DetailsViewController *)detailsNavigationController.topViewController;
        detailsView.event = detailedEvent;
        detailsView.parseEventHandler = self.parseHandler;
        detailsView.delegate = self;
        [self presentViewController:detailsNavigationController animated:YES completion:nil];
    } else {
        [self failedRequestWithMessage:@"Your event cannot be displayed"];
    }
}

- (IBAction)onTapCompose:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compose" bundle:[NSBundle mainBundle]];
    UINavigationController *composeNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ComposeNavigation"];
    ComposeViewController *composeView = (ComposeViewController *)composeNavigationController.topViewController;
    composeView.delegate = self;
    [self presentViewController:composeNavigationController animated:YES completion:nil];
}

- (void)didTapClose {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapCreateWithEvent:(nonnull Event *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.parseHandler uploadToParseWithEvent:event withCompletion:^(Event * _Nonnull event, NSDate * _Nonnull date, NSString * _Nullable error) {
        if (error) {
            [self failedRequestWithMessage:error];
        } else {
            [self successfullyUploadedEvent:event forDate:date];
        }
    }];
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
    NSDate *date = [self.dateLogicHandler getDateForIndexPath:indexPath];
    [self.scheduleDecorator decorateBaseScheduleWithDate:date contentView:cell.scheduleView];
    
    int numberOfEvents = [self.dateLogicHandler getNumberOfEventsForDate:date];
    if (numberOfEvents == 0) {
        [self fetchDataWithDate:date];
    } else if (numberOfEvents > 0) {
        [self.scheduleDecorator addEvents:[self.dateLogicHandler getEventsForIndexPath:indexPath] contentView:cell.scheduleView];
    }
    
    if (indexPath.row == 0) {
        [self addDatesToStart];
        NSIndexPath *newIndexPath = [self.dateLogicHandler scrollToItemAfterPrependingDates];
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
