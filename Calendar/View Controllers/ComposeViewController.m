//
//  ComposeViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "ComposeViewController.h"
#import "ComposeScrollView.h"

@interface ComposeViewController ()

@property (weak, nonatomic) IBOutlet ComposeScrollView *composeView;
@property (nonatomic) UIDatePicker *datePicker;

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}



- (IBAction)onTapCancel:(id)sender {
    
}

- (IBAction)onTapCreate:(id)sender {
    
}

- (IBAction)onTapOutside:(id)sender {
    [self.view endEditing:true];
}

@end
