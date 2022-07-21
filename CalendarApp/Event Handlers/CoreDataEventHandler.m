//
//  CoreDataEventHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/20/22.
//

#import "CoreDataEventHandler.h"
#import "AppDelegate.h"

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
    
}

- (void)queryEventsOnDate:(nonnull NSDate *)date
               completion:(void (^ _Nonnull)(NSMutableArray<Event *> * _Nullable, NSDate * _Nonnull, NSString * _Nullable))completion {
    NSArray<CoreDataEvent *> *cdEvents = [self.context executeFetchRequest:CoreDataEvent.fetchRequest error:nil];
}

- (void)updateEvent:(nonnull Event *)event
         completion:(void (^ _Nonnull)(NSString * _Nullable))completion {
    
}

- (void)uploadWithEvent:(nonnull Event *)newEvent
             completion:(void (^ _Nonnull)(Event * _Nonnull, NSDate * _Nonnull, NSString * _Nullable))completion {
    CoreDataEvent *cdEvent = [[CoreDataEvent alloc] initWithContext:self.context];
    
    [self.context save:nil];
}

@end
