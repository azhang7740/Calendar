//
//  EKEventHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/19/22.
//

#import "EKEventHandler.h"
#import <Eventkit/EventKit.h>

@implementation EKEventHandler

- (void)deleteRemoteObjectWithEvent:(nonnull Event *)event
                         completion:(void (^ _Nonnull)(NSString * _Nullable))completion {
    
}

- (void)queryUserEventsOnDate:(nonnull NSDate *)date
                   completion:(void (^ _Nonnull)(NSMutableArray<Event *> * _Nullable, NSDate * _Nonnull, NSString * _Nullable))completion {
    
}

- (void)updateRemoteObjectWithEvent:(nonnull Event *)event
                         completion:(void (^ _Nonnull)(NSString * _Nullable))completion {
    
}

- (void)uploadWithEvent:(nonnull Event *)newEvent
             completion:(void (^ _Nonnull)(Event * _Nonnull, NSDate * _Nonnull, NSString * _Nullable))completion {
    
}

@end
