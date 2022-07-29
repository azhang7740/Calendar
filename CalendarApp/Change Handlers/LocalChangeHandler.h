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

@protocol LocalChangeDelegate

- (void)syncEventToParse:(Event *)oldEvent
            updatedEvent:(Event *)newEvent;

@end

@interface LocalChangeHandler : NSObject

@property (weak, nonatomic) id<LocalChangeDelegate> delegate;

- (NSArray<LocalChange *> *)fetchAllLocalChanges;
- (void)deleteAllLocalChanges;
- (void)syncLocalChanges:(NSArray<LocalChange *> *)localChanges;
- (void)saveNewLocalChange:(Event *)oldEvent
              updatedEvent:(Event *)newEvent;

@end

NS_ASSUME_NONNULL_END
