//
//  LocalChangeHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/29/22.
//

#import "LocalChangeHandler.h"
#import "AppDelegate.h"
#import "CalendarApp-Swift.h"

@interface LocalChangeHandler () <LocalChangeBuildDelegate>

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

- (NSArray<LocalChange *> *)fetchLocalChangesForEvent:(NSUUID *)eventID {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalChange"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", eventID];
    return [self.context executeFetchRequest:request error:nil];;
}

- (void)deleteLocalChange:(LocalChange *)change {
    [self.context deleteObject:change];
    [self.context save:nil];
}

- (void)deleteLocalChangeWithArray:(NSArray<LocalChange *> *)changes {
    for (LocalChange *change in changes) {
        [self.context deleteObject:change];
    }
    [self.context save:nil];
}

- (void)deleteAllLocalChanges {
    NSBatchDeleteRequest *delete = [[NSBatchDeleteRequest alloc] initWithFetchRequest:LocalChange.fetchRequest];
    NSPersistentStoreCoordinator *persistentStoreCoordinator = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.persistentStoreCoordinator;
    [persistentStoreCoordinator executeRequest:delete withContext:self.context error:nil];
}

- (void)saveNewLocalChange:(Event *)oldEvent
              updatedEvent:(Event *)newEvent {
    LocalChangeBuilder *builder = [[LocalChangeBuilder alloc] initWithFirstEvent:oldEvent
                                                                    updatedEvent:newEvent
                                                                      updateDate:[NSDate date]
                                                                  managedContext:self.context
                                                             localChangeDelegate:self];
    [builder saveLocalChanges];
}

- (void)didOfflineDeleteWithEvent:(Event *)event {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalChange"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", event.objectUUID];
    NSArray<LocalChange *> *matchingChanges = [self.context executeFetchRequest:request error:nil];
    for (LocalChange *localChange in matchingChanges) {
        [self.context deleteObject:localChange];
    }
}

- (BOOL)wasAlreadyCreatedWithEvent:(Event *)event {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"LocalChange"];
    request.predicate = [NSPredicate predicateWithFormat:@"eventID == %@", event.objectUUID];
    NSArray<LocalChange *> *matchingChanges = [self.context executeFetchRequest:request error:nil];
    if (matchingChanges.count == 1 &&
        matchingChanges[0].changeType == ChangeTypeCreate) {
        [self.context deleteObject:matchingChanges[0]];
        return true;
    } 
    return false;
}

@end
