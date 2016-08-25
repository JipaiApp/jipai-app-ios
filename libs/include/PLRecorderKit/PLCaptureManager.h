//
//  PLCaptureManager.h
//  PiliKit
//
//  Created by 0day on 14/10/29.
//  Copyright (c) 2014年 qgenius. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef  NS_ENUM(NSUInteger, PLCaptureDeviceAuthorizedStatus) {
    PLCaptureDeviceAuthorizedStatusUnknow,
    PLCaptureDeviceAuthorizedStatusGranted,
    PLCaptureDeviceAuthorizedStatusUngranted
};

//typedef NS_ENUM(NSUInteger, PLCaptureDevicePosition) {
//    PLCaptureDevicePositionBack,
//    PLCaptureDevicePositionFront
//};

typedef NS_ENUM(NSUInteger, PLAudioMode) {
    PLAudioModeON,
    PLAudioModeOFF
};

typedef NS_ENUM(NSUInteger, PLTorchMode) {
    PLTorchModeOFF,
    PLTorchModeON,
    PLTorchModeUnknow
};

typedef NS_ENUM(NSUInteger, PLStreamState) {
    PLStreamStateUnknow,
    PLStreamStateDisconnected,
    PLStreamStateConnected,
    PLStreamStateCreated,
    PLStreamStatePaused,
    PLStreamStatePlaying
};

@class PLCaptureManager;
@protocol PLCaptureManagerDelegate <NSObject>

- (void)captureManager:(PLCaptureManager *)manager streamDidChangeState:(PLStreamState)state;
- (void)captureManagerConnectDidFailure:(PLCaptureManager *)manager;
- (void)captureManager:(PLCaptureManager *)manager fpsDidUpdate:(double)fps;

@end

/**
 * Notification name defines
 */
extern NSString *PLCaptureManagerWillChangeCaptureDevicePositionNotification;
extern NSString *PLCaptureManagerDidChangeCaptureDevicePositionNotification;

@interface PLCaptureManager : NSObject

@property (nonatomic, assign) AVCaptureDevicePosition captureDevicePosition;    // default as AVCaptureDevicePositionBack
@property (nonatomic, assign) PLAudioMode   audioMode;                          // default as PLAudioModeON
@property (nonatomic, assign) PLTorchMode   torchMode;                          // default as PLTorchModeOFF
@property (nonatomic, assign) AVCaptureVideoOrientation videoOrientation;

@property (nonatomic, weak) id<PLCaptureManagerDelegate>    delegate;
@property (nonatomic, strong) NSURL *rtmpPushURL;
@property (nonatomic, assign, readonly) PLStreamState streamState;
@property (nonatomic, strong) UIView *previewView;

+ (instancetype)sharedManager;

// Authorize
+ (PLCaptureDeviceAuthorizedStatus)captureDeviceAuthorizedStatus;
+ (void)requestCaptureDeviceAccessWithCompletionHandler:(void (^)(BOOL granted))block;

// Operations
- (void)connect;
- (void)disconnect;
- (void)pause;
- (void)resume;

@end
