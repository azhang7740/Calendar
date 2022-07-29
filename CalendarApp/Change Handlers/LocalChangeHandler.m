//
//  LocalChangeHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/29/22.
//

#import "LocalChangeHandler.h"
#import "AppDelegate.h"
#import "CalendarApp-Swift.h"

@interface LocalChangeHandler ()

@property (nonatomic) NSManagedObjectContext *context;

@end

@implementation LocalChangeHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.context = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    }
    return self;
}

- (NSArray<LocalChange *> *)fetchAllLocalChanges {
    return [self.context executeFetchRequest:LocalChange.fetchRequest error:nil];
}

- (void)deleteAllLocalChanges {
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:LocalChange.fetchRequest];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.persistentStoreCoordinator;
    [persistentStoreCoordinator executeRequest:delete withContext:self.context error:nil];
}

- (void)saveNewLocalChange:(Event *)oldEvent
              updatedEvent:(Event *)newEvent {
    if (!newEvent) {
        [self didOfflineDelete:oldEvent completion:^(Event *oldEvent) {
            [self createLocalChange:oldEvent updatedEvent:nil];
        }];
    } else if (oldEvent) {
        oldEvent = ([self didOfflineUpdate:newEvent]) ? nil : oldEvent;
        [self createLocalChange:oldEvent updatedEvent:newEvent];
    } else {
        [self createLocalChange:oldEvent updatedEvent:newEvent];
    }
    
    [self.context save:nil];
}

- (void)createLocalChange:(Event *)oldEvent
             updatedEvent:(Event *)newEvent {
    LocalChange *localChange = [[LocalChange alloc] initWithContext:self.context];
    localChange.timestamp = [NSDate date];
    localChange.oldEvent = (oldEvent) ? [[Event alloc] initWithOriginalEvent:oldEvent] : nil;
    localChange.updatedEvent = (newEvent) ? [[Event alloc] initWithOriginalEvent:newEvent] : nil;
    localChange.eventUUID = (oldEvent) ? oldEvent.objectUUID : newEvent.objectUUID;
}

- (void)didOfflineDelete:(Event *)event
              completion:(void (^ _Nonnull)(Event *oldEvent))completion {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalChange"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventUUID == %@", event.objectUUID];
    NSArray<LocalChange *> *matchingChanges = [self.context executeFetchRequest:request error:nil];
    for (LocalChange *localChange in matchingChanges) {
        [self.context deleteObject:localChange];
    }
    completion(event);
}

- (BOOL)didOfflineUpdate:(Event *)event {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalChange"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventUUID == %@", event.objectUUID];
    NSArray<LocalChange *> *matchingChanges = [self.context executeFetchRequest:request error:nil];
    if (matchingChanges.count == 1 && !matchingChanges[0].oldEvent) {
        [self.context deleteObject:matchingChanges[0]];
        return true;
    }
    return false;
}

@end
