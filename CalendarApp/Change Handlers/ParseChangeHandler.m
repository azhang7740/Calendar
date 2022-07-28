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
            completion(false, @"Something went wrong");
        } else {
            ParseRevisionHistory *history = (ParseRevisionHistory *)object;
            PFQuery *queryChanges = [history.remoteChanges query];
            [queryChanges setLimit:100];
            [queryChanges includeKey:@"oldEvent"];
            [queryChanges includeKey:@"newEvent"];
            NSArray<ParseChange *> *changes = [queryChanges findObjects];
            [self deleteParseChangesFromArray:changes];
            while (changes.count == 100) {
                changes = [queryChanges findObjects];
                [self deleteParseChangesFromArray:changes];
            }
            completion(true, nil);
        }
    }];
}

- (ParseChange *)queryParseChange:(NSString *)changeID {
    PFQuery *query = [PFQuery queryWithClassName:@"RemoteChange"];
    [query includeKey:@"oldEvent"];
    [query includeKey:@"newEvent"];
    ParseChange *change = [query getObjectWithId:changeID];
    return change;
}

- (void)deleteParseChangesFromArray:(NSArray<ParseChange *> *)changes {
    for (ParseChange *change in changes) {
        [change.oldEvent delete];
        [change.updatedEvent delete];
        [change delete];
    }
}

- (void)deleteParseChange:(NSString *)changeID
               completion:(ChangeActionCompletion)completion {
    ParseChange *change = [self queryParseChange:changeID];
    [change.oldEvent delete];
    [change.updatedEvent delete];
    [change deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!succeeded) {
            completion(false, @"Something went wrong.");
        } else {
            completion(true, nil);
        }
    }];
}

- (void)addNewRevisionHistory:(NSUUID *)eventID
                       change:(RemoteChange *)change
                   completion:(ChangeActionCompletion)completion {
    ParseRevisionHistory *history = [[ParseRevisionHistory alloc] init];
    history.objectUUID = [eventID UUIDString];
    history.mostRecentUpdate = change.timestamp;
    [history save];
    [self addNewParseChange:change completion:^(BOOL success, NSString * _Nullable error) {
        if (error) {
            completion(false, @"Something went wrong.");
        } else {
            completion(true, nil);
        }
    }];
}

- (void)addNewParseChange:(RemoteChange *)remoteChange
               completion:(ChangeActionCompletion)completion {
    PFQuery *query = [PFQuery queryWithClassName:@"RevisionHistory"];
    NSString *eventUUID = remoteChange.oldEvent ?
    [remoteChange.oldEvent.objectUUID UUIDString] :
    [remoteChange.updatedEvent.objectUUID UUIDString];
    [query includeKey:@"remoteChanges"];
    [query includeKey:@"mostRecentUpdate"];
    [query whereKey:@"objectUUID" equalTo:eventUUID];
    ParseRevisionHistory *history = [query getFirstObject];
    
    if (!history) {
        completion(false, @"RevisionHistory not found.");
        return;
    }
    
    [history.remoteChanges addObject:[self getParseChangeFromRemoteChange:remoteChange]];
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
}

- (ParseChange *)getParseChangeFromRemoteChange:(RemoteChange *)remoteChange {
    ParseChange *parseChange = [[ParseChange alloc] init];
    
    return parseChange;
}

@end
