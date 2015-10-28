//
//  AppDelegate.m
//  Alex DeCastro
//
//  Created by Alex on 4/20/15.
//  Copyright (c) 2015 Alex DeCastro. All rights reserved.
//

#import "AppDelegate.h"

#import "DataHolder.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // Customize the color of the page control
    [UIPageControl appearance].pageIndicatorTintColor = [UIColor lightGrayColor];
    [UIPageControl appearance].currentPageIndicatorTintColor = [UIColor blackColor];
    [UIPageControl appearance].backgroundColor = [UIColor whiteColor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleWatchKitExtensionRequest:(NSDictionary *)userInfo reply:(void (^)(NSDictionary *))reply {
    // Temporary fix, I hope.
    // --------------------
    __block UIBackgroundTaskIdentifier bogusWorkaroundTask;
    bogusWorkaroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] endBackgroundTask:bogusWorkaroundTask];
    });
    // --------------------
    
    __block UIBackgroundTaskIdentifier realBackgroundTask;
    realBackgroundTask = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        reply(nil);
        [[UIApplication sharedApplication] endBackgroundTask:realBackgroundTask];
    }];
    
    // Kick off a network request, heavy processing work, etc.
    // Get the dictionary values
    NSString *messageType = [userInfo valueForKey:@"kMessageType"];
    NSLog(@"DEBUG: AppDelegate: handleWatchKitExtensionRequest: messageType = %@", messageType);
    
    if ([messageType isEqualToString:@"CheckAnswer"]) {
        // Ignore the word list passed here.
        // Instead use the word list stored in the DataHolder
        NSString *wordList = [userInfo objectForKey:@"kWordList"];
        NSLog(@"DEBUG: AppDelegate: handleWatchKitExtensionRequest: wordList = %@", wordList);
        
        [DataHolder sharedInstance].wordList = wordList;
        [DataHolder sharedInstance].appState = @"03-Received-Answer";
        
        // Reply with a dictionary
        NSMutableDictionary *replyDictionary = [[NSMutableDictionary alloc] init];
        [replyDictionary setValue:@"CheckAnswer" forKey:@"kMessageType"];
        
        reply(replyDictionary);
    }
    else {
        reply(nil);
    }
    
    [[UIApplication sharedApplication] endBackgroundTask:realBackgroundTask];
}

@end
