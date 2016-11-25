//
//  CAPhotoManager.h
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

@interface CAPhotoManager : NSObject

@property (nonatomic) BOOL cacheEnabled;

+ (CAPhotoManager *)sharedPhotoManager;

@end
