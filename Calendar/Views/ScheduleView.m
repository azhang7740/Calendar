//
//  DailyScheduleView.m
//  Calendar
//
//  Created by Angelina Zhang on 7/8/22.
//

#import "ScheduleView.h"

@interface ScheduleView()

@property (strong, nonatomic) IBOutlet UIView *contentView;

@end

@implementation ScheduleView

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
    [[NSBundle mainBundle] loadNibNamed:@"Schedule" owner:self options:nil];
    [self addSubview:self.contentView];
    self.contentView.frame = self.bounds;
}

@end
