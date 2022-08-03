//
//  ParseChangeBuilder.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "CalendarApp-Swift.h"
#import "ParseChange.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseChangeBuilder : NSObject

- (RemoteChange *)getChangeFromParseChange:(ParseChange *)parseChange;
- (NSMutableArray<RemoteChange *> *)getChangeFromParseChangeArray:(NSArray<ParseChange *> *)parseChanges;

@end

NS_ASSUME_NONNULL_END
