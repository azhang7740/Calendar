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

- (void)registerUserWithUsername:(NSString *)username
        password:(NSString *)password;
- (void)loginUserWithUsername:(NSString *)username
    password:(NSString *)password;

@end

NS_ASSUME_NONNULL_END
