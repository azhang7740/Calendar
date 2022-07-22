//
//  EKEventHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/19/22.
//

#import <Foundation/Foundation.h>
#import "EventHandler.h"
#import "CalendarApp-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface EKEventHandler : NSObject <EventHandler>

@property (weak, nonatomic) id<RemoteEventUpdates> delegate;

- (void)requestAccessToCalendarWithCompletion:(void (^ _Nonnull)(BOOL success, NSString * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
