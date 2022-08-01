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
    
    if ([parseChange.changeType intValue] > 3 ||
        [parseChange.changeType intValue] < 1) {
        return nil;
    }
    
    if ([parseChange.changeField intValue] > 5 ||
        [parseChange.changeField intValue] < 0) {
        return nil;
    }
    
    RemoteChange *remoteChange = [[RemoteChange alloc] initWithUpdatedDate:parseChange.timestamp];
    remoteChange.parseID = parseChange.objectId;
    remoteChange.changeType = [parseChange.changeType intValue];
    remoteChange.changeField = [parseChange.changeField intValue];
    remoteChange.updatedField = parseChange.updatedField;
    remoteChange.eventID = [[NSUUID alloc] initWithUUIDString:parseChange.objectUUID];
    
    return remoteChange;
}

- (NSMutableArray<RemoteChange *> *)getChangeFromParseChangeArray:(NSArray<ParseChange *> *)parseChanges {
    NSMutableArray<RemoteChange *> *remoteChanges = [[NSMutableArray alloc] init];
    for (ParseChange *parseChange in parseChanges) {
        RemoteChange *change = [self getChangeFromParseChange:parseChange];
        if (change) {
            [remoteChanges addObject:[self getChangeFromParseChange:parseChange]];
        }
    }
    return remoteChanges;
}

@end
