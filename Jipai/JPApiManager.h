//
//  JPApiManager.h
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^JPApiResponseSuccessBlock)(id responseData);
typedef void (^JPApiResponseFailureBlock)(NSError *error);

@interface JPApiManager : NSObject

+ (instancetype)sharedManager;

- (void)get:(NSString *)path parameters:(NSDictionary *)parameters success:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler;
- (void)post:(NSString *)path parameters:(NSDictionary *)parameters success:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler;

@end
