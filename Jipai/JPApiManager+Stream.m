//
//  JPApiManager+Stream.m
//  Jipai
//
//  Created on 14/11/4.
//  Copyright (c) 2015年 Pili Engineering. All rights reserved.
//

#import "JPApiManager+Stream.h"

@implementation JPApiManager (Stream)

- (void)createStreamWithSuccess:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler {
    NSString *path = @"streams";
    
    [self post:path parameters:nil success:^(id responseData) {
        NSAssert([responseData isKindOfClass:[NSDictionary class]], @"This should be a dict.");
        
        PLStream *stream = [[PLStream alloc] initWithJSON:responseData];
        
        if (successHandler) {
            successHandler(stream);
        }
    } failure:^(NSError *error) {
        if (failureHandler) {
            failureHandler(error);
        }
    }];
}

- (void)getStreamWithStreamID:(NSString *)streamID success:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler {
    NSString *path = [NSString stringWithFormat:@"streams/%@", streamID];
    
    [self get:path parameters:nil success:^(id responseData) {
        NSAssert([responseData isKindOfClass:[NSDictionary class]], @"This should be a dict.");
        
        PLStream *stream = [[PLStream alloc] initWithJSON:responseData];
        
        if (successHandler) {
            successHandler(stream);
        }
    } failure:^(NSError *error) {
        if (failureHandler) {
            failureHandler(error);
        }
    }];
}

- (void)getStreamPlayUrlsWithStreamID:(NSString *)streamID success:(JPApiResponseSuccessBlock)successHandler failure:(JPApiResponseFailureBlock)failureHandler {
    NSString *path = [NSString stringWithFormat:@"streams/%@/urls?type=play", streamID];
    
    [self get:path parameters:nil success:^(id responseData) {
        NSAssert([responseData isKindOfClass:[NSDictionary class]], @"This should be a dict.");
        
        if (successHandler) {
            successHandler(responseData);
        }
    } failure:^(NSError *error) {
        if (failureHandler) {
            failureHandler(error);
        }
    }];
}

@end
