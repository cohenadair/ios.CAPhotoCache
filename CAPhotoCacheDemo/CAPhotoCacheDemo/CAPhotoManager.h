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

@protocol CAPhotoManagerChangeListener <NSObject>

@required
/**
 * Called when the photo download starts.  There is no guarentee this method will be called on
 * the main thread.
 */
- (void)photoManagerDownloadDidStart;

/**
 * Called when the photo download progresses.  There is no guarentee this method will be called on
 * the main thread.
 * @param percentCompleted The current progress of the download.
 */
- (void)photoManagerDownloadDidProgress:(NSInteger)percentCompleted;

/**
 * Called when the photo download completed.  There is no guarentee this method will be called on
 * the main thread.
 * @param msg The string result of the download that should be displayed to the user.
 */
- (void)photoManagerDownloadDidComplete:(NSString * _Nonnull)msg;

/**
 * Called when the photo unzipping starts.  There is no guarentee this method will be called on
 * the main thread.
 */
- (void)photoManagerUnzippingDidStart;

/**
 * Called when the photo unzipping progresses.  There is no guarentee this method will be called on
 * the main thread.
 * @param percentCompleted The current progress of the download.
 */
- (void)photoManagerUnzippingDidProgress:(NSInteger)percentCompleted;

/**
 * Called when the photo unzipping completed.  There is no guarentee this method will be called on
 * the main thread.
 * @param msg The string result of the download that should be displayed to the user.
 */
- (void)photoManagerUnzippingDidComplete:(NSString * _Nonnull)msg;

@end

@interface CAPhotoManager : NSObject

@property (strong, nonnull) NSArray *photoPaths;
@property (nonatomic) BOOL cacheEnabled;

+ (CAPhotoManager * _Nonnull)sharedPhotoManager;

/**
 * Will download example photos if there are no photos in the app's /Pictures/ directory.
 */
- (void)possiblyDownloadPhotos;

- (void)addChangeListener:(id<CAPhotoManagerChangeListener> _Nonnull)changeListener;
- (void)removeChangeListener:(id<CAPhotoManagerChangeListener> _Nonnull)changeListener;

@end
