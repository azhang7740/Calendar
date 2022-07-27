//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//
#import "EventSyncHandler.h"
#import "EventHandler.h"

@class Event;

@interface EventSyncHandler (Testing)

@property (nonatomic) id<EventHandler> parseEventHandler;

- (void)syncEventToParse:(Event * _Nullable)oldEvent
            updatedEvent:(Event * _Nullable)newEvent;

@end
