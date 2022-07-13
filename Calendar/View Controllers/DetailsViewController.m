//
//  DetailsViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/13/22.
//

#import "DetailsViewController.h"
#import "DetailsView.h"

@interface DetailsViewController () <DetailsViewDelegate>

@property (strong, nonatomic) IBOutlet DetailsView *detailsView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.detailsView.delegate = self;
    self.detailsView.eventTitleLabel.text = self.event.eventTitle;
}

- (void)didTapClose {
    [self.delegate didTapClose];
}

- (void)didTapEdit {
    
}

- (void)didTapDelete {
    
}

@end
