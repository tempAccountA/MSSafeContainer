//
//  AppDelegate.m
//  MSSafeContainerDemo
//
//  Created by J on 2017/3/8.
//  Copyright © 2017年 J. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [UIWindow new];
    self.window.frame = [UIScreen mainScreen].bounds;
    self.window.rootViewController = ViewController.new;
    [self.window makeKeyAndVisible];
    return YES;
}
@end
