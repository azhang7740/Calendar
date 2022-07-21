//
//  CoreDataEventHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/20/22.
//

#import "CoreDataEventHandler.h"
#import "AppDelegate.h"
#import "CoreDataEventBuilder.h"

@interface CoreDataEventHandler ()

@property (nonatomic) NSManagedObjectContext *context;

@end

@implementation CoreDataEventHandler

- (instancetype)init {
    if (self = [super init]) {
        self.context = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
    }
    return self;
}

- (void)deleteEvent:(nonnull Event *)event
         completion:(void (^ _Nonnull)(NSString * _Nullable))completion {
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CoreDataEvent"];
    request.predicate = [NSPredicate predicateWithFormat:@"objectUUID == %@", event.objectUUID];
    NSArray<CoreDataEvent *> *cdEvents = [self.context executeFetchRequest:request error:nil];
    if (cdEvents.count != 1) {
        completion(@"Something went wrong.");
    } else {
        [self.context deleteObject:cdEvents[0]];
        [self.context save:nil];
        completion(nil);
    }
}

- (void)queryEventsOnDate:(nonnull NSDate *)date
               completion:(void (^ _Nonnull)(NSMutableArray<Event *> * _Nullable, NSDate * _Nonnull, NSString * _Nullable))completion {
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *midnight = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:date options:0];
    NSDateComponents *dayComponent = [[NSDateComponents alloc] init];
    dayComponent.day = 1;
    NSDate *nextDate = [calendar dateByAddingComponents:dayComponent toDate:midnight options:0];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:@"CoreDataEvent"];
    request.predicate = [NSPredicate predicateWithFormat:@"startDate >= %@ AND startDate <= %@", date, nextDate];
    NSArray<CoreDataEvent *> *cdEvents = [self.context executeFetchRequest:request error:nil];
    
    if (!cdEvents) {
        completion([[NSMutableArray alloc] init], midnight, @"Failed to retrieve CoreData events.");
    } else {
        CoreDataEventBuilder *builder = [[CoreDataEventBuilder alloc] init];
        NSMutableArray<Event *> *newEvents = [builder getEventsFromCoreDataEventArray:cdEvents];
        completion(newEvents, midnight, nil);
    }
}

- (void)updateEvent:(nonnull Event *)event
         completion:(void (^ _Nonnull)(NSString * _Nullable))completion {
    
}

- (void)uploadWithEvent:(nonnull Event *)newEvent
             completion:(void (^ _Nonnull)(Event * _Nonnull, NSDate * _Nonnull, NSString * _Nullable))completion {
    CoreDataEvent *cdEvent = [[CoreDataEvent alloc] initWithContext:self.context];
    cdEvent.objectUUID = newEvent.objectUUID;
    [self updateRemoteEventFrom:newEvent cdEvent:cdEvent];
    [self.context save:nil];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    [calendar setTimeZone:[NSTimeZone systemTimeZone]];
    NSDate *midnight = [calendar dateBySettingHour:0 minute:0 second:0 ofDate:newEvent.startDate options:0];
    completion(newEvent, midnight, nil);
}

- (void)updateRemoteEventFrom:(Event *)canonicalEvent
                      cdEvent:(CoreDataEvent *)remoteEvent {
    remoteEvent.eventTitle = canonicalEvent.eventTitle;
    remoteEvent.authorUsername = canonicalEvent.authorUsername;
    remoteEvent.ekEventID = canonicalEvent.ekEventID;
    remoteEvent.parseID = remoteEvent.parseID;
    remoteEvent.updatedAt = canonicalEvent.updatedAt;
    remoteEvent.createdAt = canonicalEvent.createdAt;
    
    remoteEvent.startDate = canonicalEvent.startDate;
    remoteEvent.endDate = canonicalEvent.endDate;
    remoteEvent.eventDescription = canonicalEvent.eventDescription;
    remoteEvent.isAllDay = canonicalEvent.isAllDay;
    remoteEvent.location = canonicalEvent.location;
}

@end
