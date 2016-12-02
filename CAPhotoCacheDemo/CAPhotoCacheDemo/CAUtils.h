//
//  CAUtils.h
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

@interface CAUtils : NSObject

+ (void)runBlockInMainThread:(void(^)())block;

/**
 * @return The size of the main screen, measured in points.
 */
+ (CGSize)screenSizeInPoints;

@end
