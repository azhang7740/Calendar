//
//  LoginViewController.m
//  Calendar
//
//  Created by Angelina Zhang on 7/6/22.
//

#import "LoginViewController.h"
#import "AuthenticationHandler.h"
#import "LoginView.h"

@interface LoginViewController () <AuthenticationDelegate, UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet LoginView *loginView;
@property (nonatomic) AuthenticationHandler *authenticationHandler;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.loginView.errorLabel.text = @"";
    self.authenticationHandler = [[AuthenticationHandler alloc] init];
    self.authenticationHandler.delegate = self;
    
}

- (void)completedAuthentication {
    UITabBarController *tabBarController = (UITabBarController*)[self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    [self presentViewController:tabBarController animated:YES completion:nil];
}

- (void)failedAuthentication:(nonnull NSString *)errorMessage {
    self.loginView.errorLabel.text = errorMessage;
}

- (IBAction)onTapSignUp:(id)sender {
    [self.authenticationHandler registerUser:self.loginView.usernameTextField.text
                                withPassword:self.loginView.passwordTextField.text];
}

- (IBAction)onTapLogin:(id)sender {
    [self.authenticationHandler loginUser:self.loginView.usernameTextField.text
                             withPassword:self.loginView.passwordTextField.text];
}

- (IBAction)onTapOutside:(id)sender {
    [self.view endEditing:true];
}

@end
