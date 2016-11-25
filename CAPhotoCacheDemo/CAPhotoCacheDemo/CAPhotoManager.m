//
//  CAPhotoManager.m
//  CAPhotoCacheDemo
//
//  Created by Cohen Adair on 2016-11-23.
//
//  CAPhotoCache is a robust photo caching system for iOS.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//
//  For the full copyright and license information, please
//  view the LICENSE file that was distributed with this
//  source code.
//

#import "CAPhotoManager.h"

@implementation CAPhotoManager

+ (CAPhotoManager *)sharedPhotoManager {
    static CAPhotoManager *sharedPhotoManager = nil;
    @synchronized (self) {
        if (sharedPhotoManager == nil) {
            sharedPhotoManager = [self new];
        }
    }
    return sharedPhotoManager;
}

- (id)init {
    if (self = [super init]) {
    }
    
    return self;
}

@end
