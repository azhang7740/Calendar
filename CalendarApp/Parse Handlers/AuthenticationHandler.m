//
//  AuthenticationHandler.m
//  InstagramClone
//
//  Created by Angelina Zhang on 6/27/22.
//

#import "AuthenticationHandler.h"
#import "SceneDelegate.h"
#import "LoginViewController.h"
#import <Parse/Parse.h>

@implementation AuthenticationHandler

- (BOOL)fieldsAreEmptyWithUsername:(NSString *)username
                          password:(NSString *)password {
    return [username isEqual:@""] || [password isEqual:@""];
}

- (void)registerUserWithUsername:(NSString *)username
                        password:(NSString *)password
                      completion:(void(^_Nonnull)(NSString * _Nullable error))completion {
    if ([self fieldsAreEmptyWithUsername:username password:password]) {
        completion(@"Username or password field is empty");
        return;
    }
    PFUser *newUser = [PFUser user];
    
    newUser.username = username;
    newUser.password = password;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error) {
            if ([error code] == 202) {
                completion(@"Username is taken.");
            } else {
                completion(@"Something went wrong.");
            }
        } else {
            completion(nil);
        }
    }];
}

- (void)loginUserWithUsername:(NSString *)username
                     password:(NSString *)password
                   completion:(void(^_Nonnull)(NSString * _Nullable error))completion {
    if ([self fieldsAreEmptyWithUsername:username password:password]) {
        completion(@"Username or password field is empty");
        return;
    }
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error) {
            if ([error code] == 101) {
                completion(@"Invalid username or password.");
            } else {
                completion(@"Something went wrong.");
            }
        } else {
            completion(nil);
        }
    }];
}

- (void)logoutWithCompletion:(void(^_Nonnull)(NSString * _Nullable error))completion {
    [PFUser logOutInBackgroundWithBlock:^(NSError * _Nullable error) {
        if (error) {
            completion(@"Failed to logout.");
        } else {
            SceneDelegate *sceneDelegate = (SceneDelegate * ) UIApplication.sharedApplication.connectedScenes.allObjects.firstObject.delegate;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            LoginViewController *loginViewController = [storyboard instantiateViewControllerWithIdentifier:@"LoginViewController"];
            sceneDelegate.window.rootViewController = loginViewController;
            completion(nil);
        }
    }];
}

@end
