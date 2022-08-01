//
//  ParseChange.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "ParseArchivedEvent.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseChange : PFObject<PFSubclassing>

@property (nonatomic) NSString *objectId;
@property (nonatomic) NSString *objectUUID;
@property (nonatomic) NSDate *updatedAt;
@property (nonatomic) NSDate *createdAt;

@property (nonatomic) NSDate *timestamp;
@property (nonatomic) NSNumber *changeType;
@property (nonatomic) NSNumber *changeField;
@property (nonatomic) NSString * updatedField;

@end

NS_ASSUME_NONNULL_END
