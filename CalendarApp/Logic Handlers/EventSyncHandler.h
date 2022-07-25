//
//  EventSyncHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/22/22.
//

#import <Foundation/Foundation.h>
#import "CalendarApp-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface EventSyncHandler : NSObject

- (void)didChangeEvent:(Event *)event
                action:(ChangeType)action;

@end

NS_ASSUME_NONNULL_END
