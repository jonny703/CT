#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "Base64Transcoder.h"
#import "HSK_CFUtilities.h"
#import "NSData+Base64Additions.h"
#import "NSStream+SKPSMTPExtensions.h"
#import "SKPSMTPMessage.h"

FOUNDATION_EXPORT double skpsmtpmessageVersionNumber;
FOUNDATION_EXPORT const unsigned char skpsmtpmessageVersionString[];

