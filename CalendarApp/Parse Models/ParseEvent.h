//
//  ParseEvent.h
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseEvent : PFObject<PFSubclassing>

@property (nonatomic) NSString *objectId;
@property (nonatomic) NSString *objectUUID;
@property (nonatomic) NSDate *updatedAt;
@property (nonatomic) NSDate *createdAt;

@property (nonatomic) NSString *eventTitle;
@property (nonatomic) PFUser *author;
@property (nonatomic) NSString *eventDescription;
@property (nonatomic)  NSString *location;

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

@end

NS_ASSUME_NONNULL_END
