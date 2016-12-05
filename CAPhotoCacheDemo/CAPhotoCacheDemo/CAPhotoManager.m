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

static NSInteger const MINIMUM_FILES = 100;

static NSString *const EXAMPLE_PHOTOS_URL =
    @"https://dl.dropboxusercontent.com/s/ck0uxg93012pgbw/CAPhotoCache_Photos.zip";

static NSString *const DOWNLOAD_SUCCESS = @"Successfully downloaded example photos.";
static NSString *const DOWNLOAD_FAILURE = @"Unable to download example photos.";
static NSString *const UNZIP_SUCCESS = @"Successfully unzipped example photos.";
static NSString *const UNZIP_FAILURE = @"Unable to unzip example photos.";

static NSString *const PHOTO_EXTENSION = @".jpg";

@interface CAPhotoManager () <NSURLConnectionDataDelegate>
@end

@implementation CAPhotoManager {
    NSMutableArray<id<CAPhotoManagerChangeListener>> *_listeners;
    
    NSFileManager *_fileManager;
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
        _fileManager = [NSFileManager defaultManager];
        
        _documentsDirectory =
            [_fileManager URLForDirectory:NSDocumentDirectory
                                 inDomain:NSUserDomainMask
                        appropriateForURL:nil
                                   create:NO
                                    error:nil];
        _picturesDirectory =
            [_fileManager URLForDirectory:NSPicturesDirectory
                                 inDomain:NSUserDomainMask
                        appropriateForURL:nil
                                   create:NO
                                    error:nil];
        
        // Create pictures directory if it doesn't already exist.
        if (![self pathIsDirectory:_picturesDirectory.path]) {
            NSError *error;
            if (![_fileManager createDirectoryAtPath:_picturesDirectory.path
                         withIntermediateDirectories:YES
                                          attributes:nil
                                               error:&error])
            {
                NSLog(@"Error creating pictures directory: %@", error.localizedDescription);
            }
        }
        
        NSLog(@"%@", _picturesDirectory);
    }
    
    return self;
}

/**
 * Scans the contents of the app's /Pictures/ directory and stores the full path for every 
 * PHOTO_EXTENSION suffix'd file.
 *
 * Skips directories and non-PHOTO_EXTENSION files.
 */
- (void)initPhotoPaths {
    NSArray<NSString *> *picturesDirectoryContents = self.picturesDirectoryContents;
    if (picturesDirectoryContents.count <= 0) {
        NSLog(@"No pictures exist in the pictures directory");
        return;
    }
    
    NSMutableArray<NSString *> *photoPaths = [NSMutableArray new];
    
    for (NSString *fileName in picturesDirectoryContents) {
        NSString *fullPath = [_picturesDirectory.path stringByAppendingPathComponent:fileName];
        
        // Skip file if it's a directory or a non-JPG file.
        if ([self pathIsDirectory:fullPath] || ![fileName hasSuffix:PHOTO_EXTENSION]) {
            continue;
        }
        
        [photoPaths addObject:fullPath];
    }
    
    self.photoPaths = photoPaths;
}

- (NSArray<NSString *> *)picturesDirectoryContents {
    NSError *error;
    NSArray<NSString *> *contents = [_fileManager contentsOfDirectoryAtPath:_picturesDirectory.path
                                                                      error:&error];
    if (contents == nil) {
        NSLog(@"Error reading contents of pictures directory: %@", error.localizedDescription);
    }
    
    return contents;
}

/**
 * @return YES if the file at the given path is a directory; NO if it is not or if no file exists
 *         at the given path.
 */
- (BOOL)pathIsDirectory:(NSString *)path {
    BOOL isDirectory = NO;
    if ([_fileManager fileExistsAtPath:path isDirectory:&isDirectory]) {
        return isDirectory;
    }
    return NO;
}

- (NSFileManager *)fileManager {
    return _fileManager;
}

#pragma mark - Photo Downloading

- (void)possiblyRequestDownloadPermission {
    NSArray *picturesPaths = self.picturesDirectoryContents;
    if (picturesPaths == nil) {
        return;
    }
    
    // If there are more than MINIMUM_FILES files in /Pictures/ assume most of them are photos and
    // can be used for the demo.
    if (picturesPaths.count > MINIMUM_FILES) {
        [self initPhotoPaths];
    } else {
        [self notifyZipSizeRequestDidStart];
        [self requestExamplePhotoZipSize];
    }
}

- (void)startDownloadingPhotos {
    [self notifyDownloadDidStart];
    
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
                return [weakSelf downloadUrlForFile:response.suggestedFilename];
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

- (NSURL *)downloadUrlForFile:(NSString *)fileName {
    return [_documentsDirectory URLByAppendingPathComponent:fileName];
}

- (void)startExtractingPhotosFromPath:(NSURL *)fileUrl {
    __weak typeof(self) weakSelf = self;
    
    [SSZipArchive unzipFileAtPath:fileUrl.path
                    toDestination:_picturesDirectory.path
     
        progressHandler:^(NSString *entry, unz_file_info zipInfo, long entryNumber, long total) {
            [weakSelf notifyUnzippingDidProgress:((double)entryNumber / (double)total) * 100];
        }
     
        completionHandler:^(NSString *path, BOOL succeeded, NSError *error) {
            if (error != nil) {
                NSLog(@"Error unzipping photos: %@", error.localizedDescription);
            }
            [weakSelf notifyUnzippingDidComplete:succeeded ? UNZIP_SUCCESS : UNZIP_FAILURE];
            [weakSelf initPhotoPaths];
            
            // Delete ZIP file after unzipping.
            NSError *err;
            if (![weakSelf.fileManager removeItemAtPath:fileUrl.path error:&err]) {
                NSLog(@"Error deleting ZIP file at path: %@", fileUrl.path);
            }
        }];
}

- (void)requestExamplePhotoZipSize {
    NSMutableURLRequest *request =
        [NSMutableURLRequest requestWithURL:[NSURL URLWithString:EXAMPLE_PHOTOS_URL]];
    request.HTTPMethod = @"HEAD";
    
    if (![[NSURLConnection alloc] initWithRequest:request delegate:self]) {
        NSLog(@"Error requesting example photos's URL data.");
    }
}

#pragma mark - Change Listener Stuff

- (void)addChangeListener:(id<CAPhotoManagerChangeListener> _Nonnull)changeListener {
    [_listeners addObject:changeListener];
}

- (void)removeChangeListener:(id<CAPhotoManagerChangeListener> _Nonnull)changeListener {
    [_listeners removeObject:changeListener];
}

- (void)notifyListenersWithBlock:(void(^)(id<CAPhotoManagerChangeListener>))notifyBlock {
    for (id listener in _listeners) {
        notifyBlock(listener);
    }
}

- (void)notifyZipSizeRequestDidStart {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerZipSizeRequestDidStart];
    }];
}

- (void)notifyZipSizeRequestDidComplete:(NSString * _Nonnull)msg {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerZipSizeRequestDidComplete:msg];
    }];
}

- (void)notifyDownloadDidProgress:(NSInteger)percentCompleted {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerDownloadDidProgress:percentCompleted];
    }];
}

- (void)notifyDownloadDidComplete:(NSString * _Nonnull)msg {
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

- (void)notifyUnzippingDidComplete:(NSString * _Nonnull)msg {
    [self notifyListenersWithBlock:^(id<CAPhotoManagerChangeListener> listener) {
        [listener photoManagerUnzippingDidComplete:msg];
    }];
}

#pragma mark - NSURLConnectionDataDelegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    long long responseLength = response.expectedContentLength;
    if (responseLength == NSURLResponseUnknownLength) {
        [self notifyZipSizeRequestDidComplete:@"-1"];
    } else {
        float size = (float)responseLength / (float)1000000;
        [self notifyZipSizeRequestDidComplete:[NSString stringWithFormat:@"%.1f", size]];
    }
}

@end
