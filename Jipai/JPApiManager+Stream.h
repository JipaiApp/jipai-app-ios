//
//  JPApiManager+Stream.h
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "JPApiManager.h"
#import <PLCameraStreamingKit/PLCameraStreamingKit.h>

@interface JPApiManager (Stream)

- (void)createStreamWithSuccess:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler;

- (void)getStreamWithStreamID:(NSString *)streamID success:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler;

- (void)getStreamPlayUrlsWithStreamID:(NSString *)streamID success:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler;

@end
