//
//  AppDelegate.m
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "AppDelegate.h"
#import <PLCameraStreamingKit/PLCameraStreamingKit.h>
#ifdef DEBUG
#   import "AFNetworkActivityLogger.h"
#endif

#define kWXAppID    @"YOUR_WEIXIN_APP_ID"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)setupColors {
    [[UINavigationBar appearance] setBarTintColor:JPColorNavigationBarTint];
//    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName: JPColorNavigationTitle}];
    [[UINavigationBar appearance] setTintColor:JPColorNavigationTint];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [WXApi registerApp:kWXAppID];
    
#ifdef DEBUG
    [[AFNetworkActivityLogger sharedLogger] startLogging];
#endif
    
    application.idleTimerDisabled = YES;
    
    [PLStreamingEnv initEnv];
    
    [self setupColors];
    
    return YES;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    application.idleTimerDisabled = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    application.idleTimerDisabled = NO;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    return [WXApi handleOpenURL:url delegate:self];
}

#pragma mark - WXApiDelegate

/*! @brief 收到一个来自微信的请求，处理完后调用sendResp
 *
 * 收到一个来自微信的请求，异步处理完成后必须调用sendResp发送处理结果给微信。
 * 可能收到的请求有GetMessageFromWXReq、ShowMessageFromWXReq等。
 * @param req 具体请求内容，是自动释放的
 */
- (void)onReq:(BaseReq*)req {}

/*! @brief 发送一个sendReq后，收到微信的回应
 *
 * 收到一个来自微信的处理结果。调用一次sendReq后会收到onResp。
 * 可能收到的处理结果有SendMessageToWXResp、SendAuthResp等。
 * @param resp具体的回应内容，是自动释放的
 */
- (void)onResp:(BaseResp*)resp {}

@end
