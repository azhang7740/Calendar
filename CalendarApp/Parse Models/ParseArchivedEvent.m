//
//  ParseArchivedEvent.m
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import "ParseArchivedEvent.h"

@implementation ParseArchivedEvent

@dynamic objectId;
@dynamic objectUUID;
@dynamic updatedAt;
@dynamic createdAt;

@dynamic eventTitle;
@dynamic author;
@dynamic eventDescription;
@dynamic location;

@dynamic startDate;
@dynamic endDate;

+ (nonnull NSString *)parseClassName {
    return @"ArchivedEvent";
}

@end
