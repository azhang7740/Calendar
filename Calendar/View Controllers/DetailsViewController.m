//
//  DetailsViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/13/22.
//

#import "DetailsViewController.h"
#import "DetailsView.h"
#import "ComposeViewController.h"

@interface DetailsViewController () <DetailsViewDelegate, ComposeViewControllerDelegate>

@property (strong, nonatomic) IBOutlet DetailsView *detailsView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailsView.delegate = self;
    [self updateDetailsView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateDetailsView];
}

- (void)updateDetailsView {
    self.detailsView.eventTitleLabel.text = self.event.eventTitle;
}

- (void)didTapClose {
    [self.delegate didTapClose];
}

- (void)didTapEdit {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compose" bundle:[NSBundle mainBundle]];
    UINavigationController *composeNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ComposeNavigation"];
    ComposeViewController *composeView = (ComposeViewController *)composeNavigationController.topViewController;
    composeView.delegate = self;
    composeView.currentUserName = [self.parseEventHandler getCurrentUsername];
    composeView.event = self.event;
    [self presentViewController:composeNavigationController animated:YES completion:nil];
}

- (void)didTapDelete {
    [self.parseEventHandler deleteParseObjectWithEvent:self.event withCompletion:^(NSString * _Nullable error) {
        if (!error) {
            [self.delegate didDeleteEvent:self.event];
        } else {
            // error handling
        }
    }];
}

- (void)didTapCancel {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didTapCreateWithEvent:(Event *)event {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.parseEventHandler updateParseObjectWithEvent:event withCompletion:^(NSString * _Nullable error) {
        if (error) {
            // error handling
        }
    }];
}

@end
