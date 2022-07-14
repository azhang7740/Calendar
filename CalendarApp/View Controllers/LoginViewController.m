//
//  LoginViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "LoginViewController.h"
#import "AuthenticationHandler.h"
#import "LoginView.h"

@interface LoginViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet LoginView *loginView;
@property (nonatomic) AuthenticationHandler *authenticationHandler;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginView.errorLabel.text = @"";
    self.authenticationHandler = [[AuthenticationHandler alloc] init];
}

- (void)completedAuthentication {
    UITabBarController *tabBarController = (UITabBarController*)[self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self presentViewController:tabBarController animated:YES completion:nil];
}

- (void)failedAuthentication:(nonnull NSString *)errorMessage {
    self.loginView.errorLabel.text = errorMessage;
}

- (IBAction)onTapSignUp:(id)sender {
    [self.authenticationHandler registerUserWithUsername:self.loginView.usernameTextField.text
                                                password:self.loginView.passwordTextField.text
                                              completion:^(NSString * _Nullable error) {
        if (error) {
            [self failedAuthentication:error];
        } else {
            [self completedAuthentication];
        }
    }];
}

- (IBAction)onTapLogin:(id)sender {
    [self.authenticationHandler loginUserWithUsername:self.loginView.usernameTextField.text
                                             password:self.loginView.passwordTextField.text
                                           completion:^(NSString * _Nullable error) {
        if (error) {
            [self failedAuthentication:error];
        } else {
            [self completedAuthentication];
        }
    }];
}

- (IBAction)onTapOutside:(id)sender {
    [self.view endEditing:true];
}

@end
