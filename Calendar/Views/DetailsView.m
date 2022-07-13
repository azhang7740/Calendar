//
//  DetailsView.m
//  Calendar
//
//  Created by Angelina Zhang on 7/13/22.
//

#import "DetailsView.h"

@implementation DetailsView

- (IBAction)onTapEdit:(id)sender {
    [self.delegate didTapEdit];
}

- (IBAction)onTapDelete:(id)sender {
    [self.delegate didTapDelete];
}

- (IBAction)onTapClose:(id)sender {
    [self.delegate didTapClose];
}

@end
