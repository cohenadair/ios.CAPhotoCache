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
 * Called when the manager begins the request for the example photo zip's file size. This is 
 * guarenteed to be called in the current thread.
 */
- (void)photoManagerZipSizeRequestDidStart;

/**
 * Called when the manager completes the request for the photo zip's file size. This is not 
 * guarenteed to be called in the curren thread.
 *
 * @param msg The string result of the request that will be displayed to the user. If there was an
 *            error the string will equal the error message, otherwise will equal a string 
 *            representation of the file size.
 */
- (void)photoManagerZipSizeRequestDidComplete:(NSString * _Nonnull)msg;

/**
 * Called when the photo download starts. This is guarenteed to be called in the current thread.
 */
- (void)photoManagerDownloadDidStart;

/**
 * Called when the photo download progresses. There is no guarentee this method will be called in
 * the current thread.
 * @param percentCompleted The current progress of the download.
 */
- (void)photoManagerDownloadDidProgress:(NSInteger)percentCompleted;

/**
 * Called when the photo download completed. There is no guarentee this method will be called in
 * the main thread.
 * @param msg The string result of the download that should be displayed to the user.
 */
- (void)photoManagerDownloadDidComplete:(NSString * _Nonnull)msg;

/**
 * Called when the photo unzipping starts. This is guarenteed to be called in the current thread.
 */
- (void)photoManagerUnzippingDidStart;

/**
 * Called when the photo unzipping progresses. There is no guarentee this method will be called in
 * the current thread.
 * @param percentCompleted The current progress of the download.
 */
- (void)photoManagerUnzippingDidProgress:(NSInteger)percentCompleted;

/**
 * Called when the photo unzipping completed. There is no guarentee this method will be called in
 * the current thread.
 * @param msg The string result of the download that should be displayed to the user.
 */
- (void)photoManagerUnzippingDidComplete:(NSString * _Nonnull)msg;

@end

@interface CAPhotoManager : NSObject

@property (strong, nonnull) NSArray *photoPaths;
@property (nonatomic) BOOL cacheEnabled;

+ (CAPhotoManager * _Nonnull)sharedPhotoManager;

/**
 * Will request example photos download permission if there are no photos in the app's /Pictures/ 
 * directory.
 */
- (void)possiblyRequestDownloadPermission;

/**
 * Starts downloading photos. This should only be called after the user has confirmed the download.
 */
- (void)startDownloadingPhotos;

- (void)addChangeListener:(id<CAPhotoManagerChangeListener> _Nonnull)changeListener;
- (void)removeChangeListener:(id<CAPhotoManagerChangeListener> _Nonnull)changeListener;

@end
