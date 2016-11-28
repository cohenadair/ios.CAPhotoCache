//
//  CATableViewController.m
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

#import "CATableViewController.h"
#import "CAPhotoManager.h"
#import "CAUtils.h"

static NSString *const DOWNLOAD_PROGRESS_MESSAGE = @"Downloading photos (%ld%%)";
static NSString *const UNZIP_PROGRESS_MESSAGE = @"Unzipping photos (%ld%%)";

@interface CATableViewController () <CAPhotoManagerChangeListener>
@end

@implementation CATableViewController {
    CAPhotoManager *_photoManager;
    UIAlertController *_setupProgressAlert;
}

- (void)dealloc {
    [_photoManager removeChangeListener:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _setupProgressAlert =
        [UIAlertController alertControllerWithTitle:nil
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    _photoManager = [CAPhotoManager sharedPhotoManager];
    [_photoManager addChangeListener:self];
    [_photoManager possiblyDownloadPhotos];
}

- (void)setAlertViewDownloadPercent:(NSInteger)percent {
    _setupProgressAlert.message = [NSString stringWithFormat:DOWNLOAD_PROGRESS_MESSAGE, percent];
}

- (void)setAlertViewUnzipPercent:(NSInteger)percent {
    _setupProgressAlert.message = [NSString stringWithFormat:UNZIP_PROGRESS_MESSAGE, percent];
}

- (UIAlertController *)getSetupProgressAlert {
    return _setupProgressAlert;
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

#pragma mark - CAPhotoManagerChangeListener

- (void)photoManagerDownloadDidStart {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        [weakSelf setAlertViewDownloadPercent:0];
        [weakSelf.tabBarController presentViewController:_setupProgressAlert
                                                animated:NO
                                              completion:nil];
    }];
}

- (void)photoManagerDownloadDidProgress:(NSInteger)percentCompleted {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        [weakSelf setAlertViewDownloadPercent:percentCompleted];
    }];
}

- (void)photoManagerDownloadDidComplete:(NSString *)msg {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        weakSelf.getSetupProgressAlert.message = msg;
    }];
}

- (void)photoManagerUnzippingDidStart {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        [weakSelf setAlertViewUnzipPercent:0];
    }];
}

- (void)photoManagerUnzippingDidProgress:(NSInteger)percentCompleted {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        [weakSelf setAlertViewUnzipPercent:percentCompleted];
    }];
}

- (void)photoManagerUnzippingDidComplete:(NSString *)msg {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        weakSelf.getSetupProgressAlert.message = msg;
        [weakSelf.getSetupProgressAlert dismissViewControllerAnimated:YES completion:nil];
    }];
}

@end
