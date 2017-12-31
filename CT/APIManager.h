//
//  APIManager.h
//  SWP
//
//  Created by Admin on 8/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^APICompletionHandler) (NSDictionary* responseDict);
typedef void (^APICompletionHandlerWithArray) (NSArray* responseArr);
typedef void (^APIErrorHandler) (NSString *errorStr);

@interface APIManager : NSObject

+ (APIManager *) sharedManager;

#pragma mark - APIs

//- (void)getSportsList:(APICompletionHandlerWithArray)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler;
//- (void)getPositionList:(int)team_id SucceedHandler:(APICompletionHandlerWithArray)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler;
//
//- (void)getDemoPositionList:(int)sport_id SucceedHandler:(APICompletionHandlerWithArray)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler;

#pragma mark - Helpers

- (void) executeHTTPRequest:(NSString *)method url:(NSString *)urlStr headers:(NSDictionary *)headerDic parameters:(NSDictionary *)paramDic CompletionHandler:(APICompletionHandler)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler;

- (void) executeHTTPRequest:(NSString *)method url:(NSString *)urlStr parameters:(NSDictionary *)paramDic CompletionHandler:(APICompletionHandler)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler;

@end
