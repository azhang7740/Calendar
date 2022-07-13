//
//  ScheduleEventView.m
//  Calendar
//
//  Created by Angelina Zhang on 7/11/22.
//

#import "ScheduleEventView.h"

@interface ScheduleEventView ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation ScheduleEventView

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    
    if (self) {
        [self customInit];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        [self customInit];
    }
    return self;
}

- (void)customInit {
    [[NSBundle mainBundle] loadNibNamed:@"ScheduleEvent" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}


@end
