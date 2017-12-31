//
//  ProgressHudHelper.h
//  Cauldron
//
//  Created by Logic express on 20/03/14.
//  Copyright (c) 2014 Logic express. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MBProgressHUD.h"

@interface ProgressHudHelper : NSObject

+(void)showLoadingHudWithText:(NSString*)loadingMsg;
+(void)hideLoadingHud;

@end
