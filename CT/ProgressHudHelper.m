//
//  ProgressHudHelper.m
//  Cauldron
//
//  Created by Logic express on 20/03/14.
//  Copyright (c) 2014 Logic express. All rights reserved.
//

#import "ProgressHudHelper.h"

@implementation ProgressHudHelper

+(void)showLoadingHudWithText:(NSString*)loadingMsg
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:window animated:YES];
    hud.label.text = loadingMsg;

    hud.alpha = 1.0;
    hud.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.7];
    hud.bezelView.color = [UIColor clearColor];
}

+(void)hideLoadingHud
{
    UIWindow *window = [[[UIApplication sharedApplication] windows] lastObject];
    [MBProgressHUD hideHUDForView:window animated:YES];
}

@end
