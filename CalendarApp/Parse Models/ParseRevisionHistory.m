//
//  ParseRevisionHistory.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import "ParseRevisionHistory.h"

@implementation ParseRevisionHistory

@dynamic objectId;
@dynamic objectUUID;
@dynamic updatedAt;
@dynamic createdAt;

@dynamic mostRecentUpdate;
@dynamic remoteChanges;

+ (nonnull NSString *)parseClassName {
    return @"RevisionHistory";
}

@end
