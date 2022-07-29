//
//  ParseChangeBuilder.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import "ParseChangeBuilder.h"
#import "ParseEventBuilder.h"

@implementation ParseChangeBuilder

- (RemoteChange *)getChangeFromParseChange:(ParseChange *)parseChange {
    if (!parseChange) {
        return nil;
    }
    
    if (!parseChange.objectId ||
        [parseChange.objectId isEqual:[NSNull null]] ||
        !parseChange.timestamp ||
        [parseChange.timestamp isEqual:[NSNull null]]) {
        return nil;
    }
    
    if ((parseChange.oldEvent &&
         ![parseChange.oldEvent isKindOfClass:ParseChange.class]) ||
        (parseChange.updatedEvent &&
         ![parseChange.updatedEvent isKindOfClass:ParseChange.class])) {
        return nil;
    }
    
    RemoteChange *remoteChange = [[RemoteChange alloc] initWithChangeDate:parseChange.timestamp];
    remoteChange.parseID = parseChange.objectId;
    
    ParseEventBuilder *builder = [[ParseEventBuilder alloc] init];
    remoteChange.oldEvent = [builder getEventFromParseEvent:parseChange.oldEvent];
    remoteChange.updatedEvent = [builder getEventFromParseEvent:parseChange.updatedEvent];
    
    return remoteChange;
}

- (NSMutableArray<RemoteChange *> *)getChangeFromParseChangeArray:(NSArray<ParseChange *> *)parseChanges {
    NSMutableArray<RemoteChange *> *remoteChanges;
    for (ParseChange *parseChange in parseChanges) {
        [remoteChanges addObject:[self getChangeFromParseChange:parseChange]];
    }
    return remoteChanges;
}

@end
