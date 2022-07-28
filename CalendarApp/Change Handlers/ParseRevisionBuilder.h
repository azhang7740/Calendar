//
//  ParseRevisionBuilder.h
//  CalendarApp
//
//  Created by Angelina Zhang on 7/27/22.
//

#import <Foundation/Foundation.h>
#import "ParseRevisionHistory.h"
#import "CalendarApp-Swift.h"

NS_ASSUME_NONNULL_BEGIN

@interface ParseRevisionBuilder : NSObject

- (RecentRevisionHistory *)getRevisionfromParseRevision:(ParseRevisionHistory *)parseRevision
                                       mostRecentUpdate:(NSDate *)date;
- (NSMutableArray<RecentRevisionHistory *> *)getRevisionsFromParseRevisionArray:(NSArray<ParseRevisionHistory *> *)parseRevisions
                                                               mostRecentUpdate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
