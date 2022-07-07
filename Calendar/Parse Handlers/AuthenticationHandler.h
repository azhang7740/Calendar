//
//  AuthenticationHandler.h
//  InstagramClone
//
//  Created by Angelina Zhang on 6/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AuthenticationDelegate

- (void)completedAuthentication;
- (void)failedAuthentication:(NSString *)errorMessage;

@end

@interface AuthenticationHandler : NSObject

@property (nonatomic, weak) id<AuthenticationDelegate> delegate;

- (void)registerUser:(NSString *)username
        withPassword:(NSString *)password;
- (void)loginUser:(NSString *)username
    withPassword:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
