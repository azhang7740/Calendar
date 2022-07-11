//
//  AuthenticationHandler.m
//  InstagramClone
//
//  Created by Angelina Zhang on 6/27/22.
//

#import "AuthenticationHandler.h"
#import <Parse/Parse.h>

@implementation AuthenticationHandler

- (BOOL)fieldsAreEmptyWithUsername:(NSString *)username
                          password:(NSString *)password {
    return [username isEqual:@""] || [password isEqual:@""];
}

- (void)registerUserWithUsername:(NSString *)username
                        password:(NSString *)password {
    if ([self fieldsAreEmptyWithUsername:username password:password]) {
        [self.delegate failedAuthentication:@"Username or password field is empty."];
        return;
    }
    PFUser *newUser = [PFUser user];
    
    newUser.username = username;
    newUser.password = password;
    
    [newUser signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (error) {
            if ([error code] == 202) {
                [self.delegate failedAuthentication:@"Username is taken."];
            } else {
                [self.delegate failedAuthentication:@"Something went wrong."];
            }
        } else {
            [self.delegate completedAuthentication];
        }
    }];
}

- (void)loginUserWithUsername:(NSString *)username
                     password:(NSString *)password {
    if ([self fieldsAreEmptyWithUsername:username password:password]) {
        [self.delegate failedAuthentication:@"Username or password field is empty."];
        return;
    }
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser * user, NSError *  error) {
        if (error) {
            if ([error code] == 101) {
                [self.delegate failedAuthentication:@"Invalid username or password."];
            } else {
                [self.delegate failedAuthentication:@"Something went wrong."];
            }
        } else {
            [self.delegate completedAuthentication];
        }
    }];
}

@end
