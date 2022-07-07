//
//  CalendarViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "CalendarViewController.h"
#import "ComposeViewController.h"

#import "FSCalendar/FSCalendar.h"
#import "ParseEventHandler.h"

@interface CalendarViewController () <ComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet FSCalendar *calendarDisplay;
@property (nonatomic) ParseEventHandler *parseHandler;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.parseHandler = [[ParseEventHandler alloc] init];
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
