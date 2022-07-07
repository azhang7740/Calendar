//
//  CalendarViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "CalendarViewController.h"
#import "FSCalendar/FSCalendar.h"

@interface CalendarViewController ()

@property (weak, nonatomic) IBOutlet FSCalendar *calendarDisplay;

@end

@implementation CalendarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)onTapCompose:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Compose" bundle:[NSBundle mainBundle]];
    UINavigationController *composeNavigationController = (UINavigationController*)[storyboard instantiateViewControllerWithIdentifier:@"ComposeNavigation"];
   [self presentViewController:composeNavigationController animated:YES completion:nil];
}

@end
