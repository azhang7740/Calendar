//
//  LocalChangeHandler.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/29/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@class Event;
@class LocalChange;

@interface LocalChangeHandler : NSObject

- (NSArray<LocalChange *> *)fetchAllLocalChanges;
- (NSArray<LocalChange *> *)fetchLocalChangesForEvent:(NSUUID *)eventID;
- (void)deleteAllLocalChanges;
- (void)deleteLocalChange:(LocalChange *)change;
- (void)deleteLocalChangeWithArray:(NSArray<LocalChange *> *)changes;
- (void)saveNewLocalChange:(Event *)oldEvent
              updatedEvent:(Event *)newEvent;

@end

NS_ASSUME_NONNULL_END
