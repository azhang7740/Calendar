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
    
}

- (ParseChange *)queryParseChange:(NSString *)changeID {
    PFQuery *query = [PFQuery queryWithClassName:@"RemoteChange"];
    [query includeKey:@"oldEvent"];
    [query includeKey:@"newEvent"];
    ParseChange *change = [query getObjectWithId:changeID];
    return change;
}

- (void)deleteParseChangeSynchronously:(NSString *)changeID {
    ParseChange *change = [self queryParseChange:changeID];
    [change.oldEvent delete];
    [change.updatedEvent delete];
    [change delete];
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

- (void)addNewParseChange:(RemoteChange *)remoteChange
               completion:(ChangeActionCompletion)completion {
    
}

@end
