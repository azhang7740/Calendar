//
//  CoreDataEventHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/20/22.
//

#import "CoreDataEventHandler.h"
#import "AppDelegate.h"
#import "CoreDataEventBuilder.h"
#import "NSDate+Midnight.h"

@interface CoreDataEventHandler ()

@property (nonatomic) NSManagedObjectContext *context;

@end

@implementation CoreDataEventHandler

- (instancetype)init {
    if ((self = [super init])) {
        self.context = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    }
    return self;
}

- (void)deleteEvent:(nonnull NSString *)eventID
         completion:(RemoteEventChangeCompletion)completion {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CoreDataEvent"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectUUID == %@", [[NSUUID alloc] initWithUUIDString:eventID]];
    NSArray<CoreDataEvent *> *coreDataEvents = [self.context executeFetchRequest:request error:nil];
    if (coreDataEvents.count != 1) {
        completion(false, @"Something went wrong.");
    } else {
        [self.context deleteObject:coreDataEvents[0]];
        [self.context save:nil];
        completion(true, nil);
    }
}

- (void)queryEventsOnDate:(nonnull NSDate *)date
               completion:(EventQueryCompletion)completion {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CoreDataEvent"];
    request.predicate = [NSPredicate predicateWithFormat:@"(startDate >= %@ AND startDate <= %@) OR (startDate < %@ AND endDate > %@)", date.midnight, date.nextDate, date.midnight, date.nextDate];
    NSArray<CoreDataEvent *> *coreDataEvents = [self.context executeFetchRequest:request error:nil];
    
    if (!coreDataEvents) {
        completion(false, nil, nil, @"Failed to retrieve CoreData events.");
    } else {
        CoreDataEventBuilder *builder = [[CoreDataEventBuilder alloc] init];
        NSMutableArray<Event *> *newEvents = [builder getEventsFromCoreDataEventArray:coreDataEvents];
        completion(true, newEvents, date.midnight, nil);
    }
}

- (void)updateEvent:(nonnull Event *)event
         completion:(RemoteEventChangeCompletion)completion {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CoreDataEvent"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectUUID == %@", event.objectUUID];
    NSArray<CoreDataEvent *> *coreDataEvents = [self.context executeFetchRequest:request error:nil];
    if (coreDataEvents.count != 1) {
        completion(false, @"Something went wrong.");
    } else {
        [self updateRemoteEventFrom:event coreDataEvent:coreDataEvents[0]];
        [self.context save:nil];
        completion(true, nil);
    }
}

- (void)uploadWithEvent:(nonnull Event *)newEvent
             completion:(RemoteEventChangeCompletion)completion {
    CoreDataEvent *coreDataEvent = [[CoreDataEvent alloc] initWithContext:self.context];
    coreDataEvent.objectUUID = newEvent.objectUUID;
    [self updateRemoteEventFrom:newEvent coreDataEvent:coreDataEvent];
    [self.context save:nil];
    completion(true, nil);
}

- (void)updateRemoteEventFrom:(Event *)canonicalEvent
                      coreDataEvent:(CoreDataEvent *)remoteEvent {
    remoteEvent.eventTitle = canonicalEvent.eventTitle;
    remoteEvent.authorUsername = canonicalEvent.authorUsername;
    remoteEvent.ekEventID = canonicalEvent.ekEventID;
    remoteEvent.updatedAt = canonicalEvent.updatedAt;
    remoteEvent.createdAt = canonicalEvent.createdAt;
    
    remoteEvent.startDate = canonicalEvent.startDate;
    remoteEvent.endDate = canonicalEvent.endDate;
    remoteEvent.eventDescription = canonicalEvent.eventDescription;
    remoteEvent.isAllDay = canonicalEvent.isAllDay;
    remoteEvent.location = canonicalEvent.location;
}

- (Event *)queryEventFromID:(NSUUID *)eventID {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CoreDataEvent"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectUUID == %@", eventID];
    NSArray<CoreDataEvent *> *coreDateEvents = [self.context executeFetchRequest:request error:nil];
    if (coreDateEvents.count != 1) {
        // TODO: Error handling
        return nil;
    }
    CoreDataEventBuilder *builder = [[CoreDataEventBuilder alloc] init];
    return [builder getEventFromCoreDataEvent:coreDateEvents[0]];
}

@end
