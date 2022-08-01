//
//  ParseChangeHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import "ParseChangeHandler.h"
#import "CalendarApp-Swift.h"
#import "ParseRevisionHistory.h"
#import "ParseRevisionBuilder.h"
#import "ParseChange.h"
#import "ParseArchivedEvent.h"

@implementation ParseChangeHandler

- (void)queryChangesAfterUpdateDate:(NSDate *)date
                         completion:(ChangeQueryCompletion)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"RevisionHistory"];
    [query whereKey:@"mostRecentUpdate" greaterThan:date];
    [query includeKey:@"objectId"];
    [query includeKey:@"mostRecentUpdate"];
    [query includeKey:@"objectUUID"];
    [query includeKey:@"remoteChanges"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray<ParseRevisionHistory *> * _Nullable revisionHistories,
                                              NSError * _Nullable error) {
        if (error) {
            completion(false, nil, @"Something went wrong.");
        } else {
            ParseRevisionBuilder *builder = [[ParseRevisionBuilder alloc] init];
            NSMutableArray<RecentRevisionHistory *> *recentRevisions =
            (NSMutableArray<RecentRevisionHistory *> *)
            [builder getRevisionsFromParseRevisionArray:revisionHistories mostRecentUpdate:date];
            completion(true, recentRevisions, nil);
        }
    }];
}

- (void)deleteRevisionHistory:(NSUUID *)eventID
                   completion:(ChangeActionCompletion)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"RevisionHistory"];
    [query includeKey:@"remoteChanges"];
    [query whereKey:@"objectUUID" equalTo:[eventID UUIDString]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object,
                                                 NSError * _Nullable error) {
        if (error) {
            completion(false, @"Couldn't find RevisionHistory.");
            return;
        }
        ParseRevisionHistory *history = (ParseRevisionHistory *)object;
        PFRelation *changesRelation = [history relationForKey:@"remoteChanges"];
        PFQuery *queryChanges = [changesRelation query];
        [queryChanges setLimit:10];
        [queryChanges findObjectsInBackgroundWithBlock:^(NSArray<ParseChange *> * _Nullable changes,
                                                         NSError * _Nullable error) {
            if (error) {
                completion(false, @"Couldn't query RemoteChanges.");
                return;
            }
            [self deleteParseChangesFromArray:changes];
            [history deleteInBackground];
            completion(true, nil);
        }];
    }];
}

- (void)deleteParseChangesFromArray:(NSArray<ParseChange *> *)changes {
    for (ParseChange *change in changes) {
        [change deleteInBackground];
    }
}

- (void)deleteParseChange:(NSString *)changeID
               completion:(ChangeActionCompletion)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"RemoteChange"];
    [query whereKey:@"objectId" equalTo:changeID];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
            if (!succeeded) {
                completion(false, @"Something went wrong.");
            } else {
                completion(true, nil);
            }
        }];
    }];
}

- (void)addNewRevisionHistory:(NSUUID *)eventID
                       change:(RemoteChange *)change
                   completion:(ChangeActionCompletion)completion {
    ParseRevisionHistory *history = [[ParseRevisionHistory alloc] init];
    history.objectUUID = [eventID UUIDString];
    history.mostRecentUpdate = change.timestamp;
    [history saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!succeeded) {
            completion(false, @"RevisionHistory was not saved.");
            return;
        }
        [self addNewParseChange:change completion:^(BOOL success, NSString * _Nullable error) {
            if (error) {
                completion(false, error);
            } else {
                completion(true, nil);
            }
        }];
    }];
}

- (void)addNewParseChange:(RemoteChange *)remoteChange
               completion:(ChangeActionCompletion)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"RevisionHistory"];
    [query includeKey:@"remoteChanges"];
    [query includeKey:@"mostRecentUpdate"];
    [query whereKey:@"objectUUID" equalTo:[remoteChange.eventID UUIDString]];
    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
        if (error) {
            completion(false, @"Couldn't find RevisionHistory.");
            return;
        }
        ParseRevisionHistory *history = (ParseRevisionHistory *)object;
        PFRelation *changesRelation = [history relationForKey:@"remoteChanges"];
        PFQuery *changeQuery = [changesRelation query];
        [changeQuery includeKey:@"changeField"];
        
        NSNumber *changeNumber = [[NSNumber alloc] initWithInt:(int)remoteChange.changeField];
        [changeQuery whereKey:@"changeField" equalTo:changeNumber];
        [changeQuery findObjectsInBackgroundWithBlock:^(NSArray<ParseChange *> * _Nullable parseChanges,
                                                        NSError * _Nullable error) {
            if (error) {
                completion(false, @"Couldn't query the changes.");
            } else if (parseChanges.count != 0) {
                for (ParseChange *parseChange in parseChanges) {
                    [parseChange deleteInBackground];
                }
            }
            ParseChange *change = [self getParseChangeFromRemoteChange:remoteChange];
            [change saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded) {
                    [changesRelation addObject:change];
                    history.mostRecentUpdate = ([history.mostRecentUpdate compare:remoteChange.timestamp]
                                                == NSOrderedAscending) ?
                    remoteChange.timestamp : history.mostRecentUpdate;
                    [history saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (succeeded) {
                            completion(true, nil);
                        } else {
                            completion(false, @"Something went wrong.");
                        }
                    }];
                } else {
                    completion(false, @"Failed to save.");
                }
            }];
        }];
    }];
}

- (ParseChange *)getParseChangeFromRemoteChange:(RemoteChange *)remoteChange {
    ParseChange *parseChange = [[ParseChange alloc] init];
    
    parseChange.objectUUID = [remoteChange.eventID UUIDString];
    parseChange.timestamp = remoteChange.timestamp;
    parseChange.changeType = [[NSNumber alloc] initWithInt:(int)remoteChange.changeType];
    parseChange.changeField = [[NSNumber alloc] initWithInt:(int)remoteChange.changeField];
    parseChange.updatedField = remoteChange.updatedField;
    
    return parseChange;
}

@end
