//
//  ParseRevisionHistory.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

NS_ASSUME_NONNULL_BEGIN

@interface ParseRevisionHistory : PFObject<PFSubclassing>

@property (nonatomic) NSString *objectId;
@property (nonatomic) NSString *objectUUID;
@property (nonatomic) NSDate *updatedAt;
@property (nonatomic) NSDate *createdAt;

@property (nonatomic) NSDate *mostRecentUpdate;
@property (readonly, nonatomic) PFRelation *remoteChanges;

@end

NS_ASSUME_NONNULL_END
