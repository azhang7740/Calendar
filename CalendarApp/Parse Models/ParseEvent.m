//
//  ParseEvent.m
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import "ParseEvent.h"

@implementation ParseEvent

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
@dynamic isAllDay;

+ (nonnull NSString *)parseClassName {
    return @"Event";
}

@end
