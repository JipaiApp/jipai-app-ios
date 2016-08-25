//
//  JPApiManager.m
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "JPApiManager.h"
#import "AFNetworking.h"

#define kBaseURL    @"http://localhost:8481/v1"

@interface JPApiManager ()

@property (nonatomic, strong) AFHTTPSessionManager  *sessionManager;

@end

@implementation JPApiManager

+ (instancetype)sharedManager {
    static JPApiManager *s_manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        s_manager = [[self alloc] init];
    });
    
    return s_manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.sessionManager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kBaseURL]];
        self.sessionManager.requestSerializer = [AFJSONRequestSerializer serializer];
        self.sessionManager.responseSerializer = [AFJSONResponseSerializer serializer];
    }
    
    return self;
}

- (void)get:(NSString *)path parameters:(NSDictionary *)parameters success:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler {
    [self.sessionManager GET:path parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseData) {
        if (successHandler) {
            successHandler(responseData);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureHandler) {
            failureHandler(error);
        }
    }];
}

- (void)post:(NSString *)path parameters:(NSDictionary *)parameters success:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler {
    [self.sessionManager POST:path parameters:parameters progress:nil success:^(NSURLSessionDataTask *task, id responseData) {
        if (successHandler) {
            successHandler(responseData);
        }
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        if (failureHandler) {
            failureHandler(error);
        }
    }];
}

@end
