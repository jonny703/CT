//
//  APIManager.m
//  SWP
//
//  Created by Admin on 8/11/16.
//  Copyright © 2016 Admin. All rights reserved.
//

#import "APIManager.h"
#import "AFNetworking.h"

NSString *errorMessage = @"Something went wrong";

@implementation APIManager

static APIManager *singleton = nil;

+ (APIManager *) sharedManager {
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        singleton = [[self alloc] init];
    });
    
    return singleton;
}

#pragma mark - APIs


/**
 Get Spots List
 
 @return value
     {
     ID = 1;
     Sport = Soccer;
     position = "Defense,Keeper,Forward,Midfield,Striker";
     },
     {
     ID = 2;
     Sport = Lacrosse;
     position = "Attack,Midfield,Defense,Goalie";
     },
     {
     ID = 3;
     Sport = Volleyball;
     position = "Defensive Specialist,Middle Hitter,Outside Hitter, Right Side Hitter,Setter";
     },
     {
     ID = 4;
     Sport = Basketball;
     position = "Guard,Center,Forward";
     },
     {
     ID = 5;
     Sport = Football;
     position = "QB,WR,RB,DE,LB";
     },
     {
     ID = 6;
     Sport = Hockey;
     position = "Forwards,Left Wing,Center,Right Wing,Defense,Left Defense,Right Defense,Goalie";
     },
     {
     ID = 7;
     Sport = Bobsled;
     position = "Driver,Brakeman,Pusher";
     }
 */

//- (void)getSportsList:(APICompletionHandlerWithArray)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler {
//    
//    [self executeHTTPRequest:Get url:sportsList parameters:nil CompletionHandler:^(NSDictionary *responseDict) {
//        succeedHandler((NSArray *) responseDict);
//    } ErrorHandler: errorHandler];
//}
//
//- (void)getPositionList:(int)team_id SucceedHandler:(APICompletionHandlerWithArray)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler {
//    NSString *url = [NSString stringWithFormat:postionList, team_id];
//    
//    [self executeHTTPRequest:Get url:url parameters:nil CompletionHandler:^(NSDictionary *responseDict) {
//        succeedHandler((NSArray *) responseDict);
//    } ErrorHandler: errorHandler];
//}
//
//-  (void)getDemoPositionList:(int)sport_id SucceedHandler:(APICompletionHandlerWithArray)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler {
//    
//    NSString *url = [NSString stringWithFormat:demoPostionList, sport_id];
//    
//    [self executeHTTPRequest:Get url:url parameters:nil CompletionHandler:^(NSDictionary *responseDict) {
//        succeedHandler((NSArray *) responseDict);
//    } ErrorHandler: errorHandler];
//    
//}

#pragma mark - Helpers

- (void) executeHTTPRequest:(NSString *)method url:(NSString *)urlStr headers:(NSDictionary *)headerDic parameters:(NSDictionary *)paramDic CompletionHandler:(APICompletionHandler)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler {
    
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    if (headerDic) {
        NSArray *keyArr = [headerDic allKeys];
        
        for (NSString *key in keyArr) {
            NSString *value = [headerDic objectForKey:key];
            [requestSerializer setValue:value forHTTPHeaderField:key];
        }
    }
    
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    NSLog(@"URL -- %@",url);
    
    if ([method isEqualToString:@"get"]) {
        
        [manager GET:url parameters:paramDic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            succeedHandler(responseObject);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            errorHandler(errorMessage);
        }];
        
    } else if ([method isEqualToString:@"post"]) {
        
        [manager POST:url parameters:paramDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"JSON: %@", responseObject);
            succeedHandler(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            errorHandler(errorMessage);
        }];
        
    } else if ([method isEqualToString:@"patch"]) {
        
        [manager PATCH:url parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"JSON: %@", responseObject);
            succeedHandler(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            errorHandler(errorMessage);
        }];
        
    } else if ([method isEqualToString:@"delete"]) {
        
        [manager DELETE:url parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"JSON: %@", responseObject);
            succeedHandler(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            errorHandler(errorMessage);
        }];
    }
}

- (void) executeHTTPRequest:(NSString *)method url:(NSString *)urlStr parameters:(NSDictionary *)paramDic CompletionHandler:(APICompletionHandler)succeedHandler ErrorHandler:(APIErrorHandler)errorHandler {
    
    NSString *url = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    
    manager.requestSerializer = requestSerializer;
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/html", nil];
    
    NSLog(@"URL -- %@",url);
    NSLog(@"params --- %@", paramDic);
//    NSLog(@"loginaftersignup---%@,%@", url, paramDic);
    
    if ([method isEqualToString:@"get"]) {
        
        [manager GET:url parameters:paramDic progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", responseObject);
            succeedHandler(responseObject);
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
            errorHandler(errorMessage);
        }];
        
    } else if ([method isEqualToString:@"post"]) {
        
        [manager POST:url parameters:paramDic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"JSON: %@", responseObject);
            succeedHandler(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            errorHandler(errorMessage);
        }];
        
    } else if ([method isEqualToString:@"patch"]) {
        
        [manager PATCH:url parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"JSON: %@", responseObject);
            succeedHandler(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            errorHandler(errorMessage);
        }];
        
    } else if ([method isEqualToString:@"delete"]) {
        
        [manager DELETE:url parameters:paramDic success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            NSLog(@"JSON: %@", responseObject);
            succeedHandler(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Error: %@", error);
            errorHandler(errorMessage);
        }];
    }
}


@end
