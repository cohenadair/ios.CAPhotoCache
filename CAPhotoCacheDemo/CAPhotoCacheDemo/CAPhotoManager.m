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
#import "AFNetworking/AFNetworking.h"
#import "SSZipArchive/SSZipArchive.h"

static NSString *const EXAMPLE_PHOTOS_URL =
    @"https://github.com/cohenadair/ios.CAPhotoCache/blob/master/CAPhotoCache_Photos.zip?raw=true";

static NSString *const DOWNLOAD_SUCCESS = @"Successfully downloaded example photos.";
static NSString *const DOWNLOAD_FAILURE = @"Unable to download example photos.";
static NSString *const UNZIP_SUCCESS = @"Successfully unzipped example photos.";
static NSString *const UNZIP_FAILURE = @"Unable to unzip example photos.";

@implementation CAPhotoManager {
    NSMutableArray<id<CAPhotoManagerChangeListener>> *_listeners;
    
    NSURL *_documentsDirectory;
    NSURL *_picturesDirectory;
}

#pragma mark - Singleton

+ (CAPhotoManager *)sharedPhotoManager {
    static CAPhotoManager *sharedPhotoManager = nil;
    @synchronized (self) {
        if (sharedPhotoManager == nil) {
            sharedPhotoManager = [self new];
        }
    }
    return sharedPhotoManager;
}

#pragma mark - Initializing

- (id)init {
    if (self = [super init]) {
        _listeners = [NSMutableArray new];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        
        _documentsDirectory =
            [fileManager URLForDirectory:NSDocumentDirectory
                                inDomain:NSUserDomainMask
                       appropriateForURL:nil
                                  create:NO
                                   error:nil];
        _picturesDirectory =
            [fileManager URLForDirectory:NSPicturesDirectory
                                inDomain:NSUserDomainMask
                       appropriateForURL:nil
                                  create:NO
                                   error:nil];
        
        // Create pictures directory if it doesn't already exist.
        BOOL isDirectory;
        if (![fileManager fileExistsAtPath:_picturesDirectory.path
                               isDirectory:&isDirectory])
        {
            NSError *error;
            if (![fileManager createDirectoryAtPath:_picturesDirectory.path
                        withIntermediateDirectories:YES
                                         attributes:nil
                                              error:&error])
            {
                NSLog(@"Error creating pictures directory: %@", error.localizedDescription);
            }
        }
    }
    
    return self;
}

#pragma mark - Photo Downloading

- (void)possiblyDownloadPhotos {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // If there are more than 100 files in /Pictures/ assume most of them are photos and can be used
    // for the demo.
    if ([fileManager contentsOfDirectoryAtPath:_picturesDirectory.path
                                         error:nil].count > 100)
    {
        NSLog(@"Photos already exist in the app's /Pictures/ directory");
    } else {
        [self notifyDownloadDidStart];
        [self startDownloadingPhotos];
    }
}

- (void)startDownloadingPhotos {
    NSURLSessionConfiguration *configuration =
        [NSURLSessionConfiguration defaultSessionConfiguration];
    
    AFURLSessionManager *manager =
        [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:EXAMPLE_PHOTOS_URL]];
    
    __weak typeof(self) weakSelf = self;
    
    NSURLSessionDownloadTask *downloadTask =
        [manager downloadTaskWithRequest:request
            progress:^(NSProgress *progress) {
                [weakSelf notifyDownloadDidProgress:progress.fractionCompleted * 100];
            }
         
            destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
                return [weakSelf getDownloadUrlForFile:response.suggestedFilename];
            }
         
            completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
                if (error == nil) {
                    [weakSelf notifyDownloadDidComplete:DOWNLOAD_SUCCESS];
                    [weakSelf notifyUnzippingDidStart];
                    [weakSelf startExtractingPhotosFromPath:filePath];
                } else {
                    NSLog(@"Error downloading photos: %@", error.localizedDescription);
                    [weakSelf notifyDownloadDidComplete:DOWNLOAD_FAILURE];
                }
            }];
    
    [downloadTask resume];
}

- (NSURL *)getDownloadUrlForFile:(NSString *)fileName {
    return [_documentsDirectory URLByAppendingPathComponent:fileName];
}

- (void)startExtractingPhotosFromPath:(NSURL *)filePath {
    __weak typeof(self) weakSelf = self;
    
    [SSZipArchive unzipFileAtPath:filePath.path
                    toDestination:_picturesDirectory.path
     
        progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
            [weakSelf notifyUnzippingDidProgress:((double)entryNumber / (double)total) * 100];
        }
     
        completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
            if (error != nil) {
                NSLog(@"Error unzipping photos: %@", error.localizedDescription);
            }
            [weakSelf notifyUnzippingDidComplete:succeeded ? UNZIP_SUCCESS : UNZIP_FAILURE];
        }];
}

#pragma mark - Change Listener Stuff

- (void)addChangeListener:(id<CAPhotoManagerChangeListener>)changeListener {
    [_listeners addObject:changeListener];
}

- (void)removeChangeListener:(id<CAPhotoManagerChangeListener>)changeListener {
    [_listeners removeObject:changeListener];
}

- (void)notifyListenersWithBlock:(void(^)(id<CAPhotoManagerChangeListener>))notifyBlock {
    for (id listener in _listeners) {
        notifyBlock(listener);
    }
}

- (void)notifyDownloadDidProgress:(NSInteger)percentCompleted {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerDownloadDidProgress:percentCompleted];
    }];
}

- (void)notifyDownloadDidComplete:(NSString *)msg {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerDownloadDidComplete:msg];
    }];
}

- (void)notifyDownloadDidStart {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerDownloadDidStart];
    }];
}

- (void)notifyUnzippingDidStart {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerUnzippingDidStart];
    }];
}

- (void)notifyUnzippingDidProgress:(NSInteger)percentCompleted {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerUnzippingDidProgress:percentCompleted];
    }];
}

- (void)notifyUnzippingDidComplete:(NSString *)msg {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerUnzippingDidComplete:msg];
    }];
}

@end
