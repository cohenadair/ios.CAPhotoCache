//
//  CAUtils.m
//  CAPhotoCacheDemo
//
//  Created by Cohen Adair on 2016-11-27.
//
//  CAPhotoCache is a robust photo caching system for iOS.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//
//  For the full copyright and license information, please
//  view the LICENSE file that was distributed with this
//  source code.
//

#import "CAUtils.h"

@implementation CAUtils

+ (void)runBlockInMainThread:(void(^)())block {
    dispatch_async(dispatch_get_main_queue(), ^{
        block();
    });
}

+ (CGSize)screenSizeInPoints {
    return [UIScreen mainScreen].bounds.size;
}

@end
