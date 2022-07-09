//
//  ScheduleHour.m
//  Calendar
//
//  Created by Angelina Zhang on 7/9/22.
//

#import "ScheduleHour.h"

@interface ScheduleHour ()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation ScheduleHour

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
    [[NSBundle mainBundle] loadNibNamed:@"ScheduleScroll" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

@end
