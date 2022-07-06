//
//  LogoutHandler.h
//  InstagramClone
//
//  Created by Angelina Zhang on 6/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol LogoutHandlerDelegate

- (void)failedLogout;

@end

@interface LogoutHandler : NSObject

@property (nonatomic, weak) id<LogoutHandlerDelegate> delegate;

- (void)logout;

@end

NS_ASSUME_NONNULL_END
