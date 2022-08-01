//
//  ParseRevisionBuilder.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import "ParseRevisionBuilder.h"
#import "ParseChangeBuilder.h"
#import "ParseChange.h"

@implementation ParseRevisionBuilder

- (NSArray<RemoteChange *> *)getRevisionfromParseRevision:(ParseRevisionHistory *)parseRevision
                                       mostRecentUpdate:(NSDate *)date {
    PFQuery *remoteChangeQuery = [parseRevision.remoteChanges query];
    [remoteChangeQuery includeKey:@"objectId"];
    [remoteChangeQuery includeKey:@"timestamp"];
    [remoteChangeQuery includeKey:@"changeType"];
    [remoteChangeQuery includeKey:@"changeField"];
    [remoteChangeQuery includeKey:@"updatedField"];
    [remoteChangeQuery includeKey:@"objectUUID"];
    [remoteChangeQuery orderByAscending:@"timestamp"];
    [remoteChangeQuery whereKey:@"updatedEvent" greaterThan:date];
    
    ParseChangeBuilder *builder = [[ParseChangeBuilder alloc] init];
    NSArray<RemoteChange *> *remoteChanges = [builder getChangeFromParseChangeArray:[remoteChangeQuery findObjects]];
    
    return remoteChanges;
}

- (NSMutableArray<NSArray<RemoteChange *> *> *)getRevisionsFromParseRevisionArray:(NSArray<ParseRevisionHistory *> *)parseRevisions
                                                               mostRecentUpdate:(NSDate *)date {
    NSMutableArray<NSArray<RemoteChange *> *> *canonicalRevisions = [[NSMutableArray alloc] init];
    for (ParseRevisionHistory *revisionHistory in parseRevisions) {
        NSArray<RemoteChange *> *newRevision = [self getRevisionfromParseRevision:revisionHistory
                                                               mostRecentUpdate:date];
        [canonicalRevisions addObject:newRevision];
    }
    return canonicalRevisions;
}

@end
