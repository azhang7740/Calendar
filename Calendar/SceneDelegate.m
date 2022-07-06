//
//  SceneDelegate.m
//  Calendar
//
//  Created by Angelina Zhang on 7/5/22.
//

#import "SceneDelegate.h"

@interface SceneDelegate ()

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *homeTabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
    self.window.rootViewController = homeTabBarController;
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    
}


- (void)sceneWillResignActive:(UIScene *)scene {
    
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    
}


@end
