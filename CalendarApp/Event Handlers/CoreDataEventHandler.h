//
//  CoreDataEventHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/20/22.
//

#import <Foundation/Foundation.h>
#import "EventHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface CoreDataEventHandler : NSObject <EventHandler>

- (Event * _Nullable)queryEventFromID:(NSUUID *)eventID;

@end

NS_ASSUME_NONNULL_END
