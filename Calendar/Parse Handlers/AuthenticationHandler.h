//
//  AuthenticationHandler.h
//  InstagramClone
//
//  Created by Angelina Zhang on 6/27/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AuthenticationHandler : NSObject

- (void)registerUserWithUsername:(NSString *)username
                        password:(NSString *)password
                      completion:(void(^_Nonnull)(NSString * _Nullable error))completion;
- (void)loginUserWithUsername:(NSString *)username
                     password:(NSString *)password
                   completion:(void(^_Nonnull)(NSString * _Nullable error))completion;
- (void)logoutWithCompletion:(void(^_Nonnull)(NSString * _Nullable error))completion;

@end

NS_ASSUME_NONNULL_END
