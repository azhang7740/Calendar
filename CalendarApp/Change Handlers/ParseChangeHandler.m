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
            PFRelation *changesRelation = [history relationForKey:@"remoteChanges"];
            PFQuery *queryChanges = [changesRelation query];
            [queryChanges setLimit:100];
            [queryChanges includeKey:@"oldEvent"];
            [queryChanges includeKey:@"newEvent"];
            NSArray<ParseChange *> *changes = [queryChanges findObjects];
            [self deleteParseChangesFromArray:changes];
            while (changes.count == 100) {
                changes = [queryChanges findObjects];
                [self deleteParseChangesFromArray:changes];
            }
            [history deleteInBackground];
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
    [query includeKey:@"remoteChanges"];
    [query includeKey:@"mostRecentUpdate"];
    [query whereKey:@"objectUUID" equalTo:[remoteChange.objectUUID UUIDString]];
    ParseRevisionHistory *history = [query getFirstObject];
    
    if (!history) {
        completion(false, @"RevisionHistory not found.");
        return;
    }
    
    ParseChange *change = [self getParseChangeFromRemoteChange:remoteChange];
    [change saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded) {
            PFRelation *changesRelation = [history relationForKey:@"remoteChanges"];
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
}

- (ParseChange *)getParseChangeFromRemoteChange:(RemoteChange *)remoteChange {
    ParseChange *parseChange = [[ParseChange alloc] init];
    parseChange.objectUUID = [remoteChange.objectUUID UUIDString];
    parseChange.timestamp = remoteChange.timestamp;
    
    parseChange.oldEvent = (remoteChange.oldEvent) ?
    [self getArchivedEventFromEvent:remoteChange.oldEvent] : nil;
    parseChange.updatedEvent = (remoteChange.updatedEvent) ?
    [self getArchivedEventFromEvent:remoteChange.updatedEvent] : nil;
    
    return parseChange;
}

- (ParseArchivedEvent *)getArchivedEventFromEvent:(Event *)uploadEvent {
    ParseArchivedEvent *archivedEvent = [[ParseArchivedEvent alloc] init];
    archivedEvent.objectUUID = [uploadEvent.objectUUID UUIDString];
    archivedEvent.eventTitle = uploadEvent.eventTitle;
    archivedEvent.author = [PFUser currentUser];
    
    archivedEvent.eventDescription = uploadEvent.eventDescription;
    archivedEvent.location = uploadEvent.location;
    archivedEvent.startDate = uploadEvent.startDate;
    archivedEvent.endDate = uploadEvent.endDate;
    
    return archivedEvent;
}

@end
