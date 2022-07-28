//
//  ParseChangeHandler.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import "ParseChangeHandler.h"
#import "CalendarApp-Swift.h"
#import "ParseRevisionHistory.h"

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
            
        }
    }];
}

@end
