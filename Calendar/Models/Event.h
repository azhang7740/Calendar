//
//  Event.h
//  Calendar
//
//  Created by Angelina Zhang on 7/7/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Event : NSObject

@property (nonatomic) NSString *parseObjectId;
@property (nonatomic) NSDate *updatedAt;
@property (nonatomic) NSDate *createdAt;

@property (nonatomic) NSString *eventTitle;
@property (nonatomic) NSString *authorUsername;
@property (nonatomic) NSString *eventDescription;
@property (nonatomic)  NSString *location;

@property (nonatomic) NSDate *startDate;
@property (nonatomic) NSDate *endDate;

@end

NS_ASSUME_NONNULL_END
