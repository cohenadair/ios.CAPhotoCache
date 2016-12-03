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
#import "CATableViewCell.h"

static NSString *const ACTION_YES = @"Yes";
static NSString *const ACTION_NO = @"No";

static NSString *const SIZE_PROGRESS_MESSAGE = @"Gathering information...";
static NSString *const DOWNLOAD_PROGRESS_MESSAGE = @"Downloading photos (%ld%%)";
static NSString *const UNZIP_PROGRESS_MESSAGE = @"Unzipping photos (%ld%%)";

static NSString *const CONFIRM_DOWNLOAD_MESSAGE = @"Download demo photos (%@ MB)?";

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
    [_photoManager possiblyRequestDownloadPermission];
}

- (void)setAlertViewDownloadPercent:(NSInteger)percent {
    _setupProgressAlert.message = [NSString stringWithFormat:DOWNLOAD_PROGRESS_MESSAGE, percent];
}

- (void)setAlertViewUnzipPercent:(NSInteger)percent {
    _setupProgressAlert.message = [NSString stringWithFormat:UNZIP_PROGRESS_MESSAGE, percent];
}

- (UIAlertController *)setupProgressAlert {
    return _setupProgressAlert;
}

- (CAPhotoManager *)photoManager {
    return _photoManager;
}

#pragma mark - UITableView Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _photoManager.photoPaths.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CATableViewCell *cell = (CATableViewCell *)
        [tableView dequeueReusableCellWithIdentifier:CATableViewCell.IDENTIFIER];
    
    NSString *imagePath = _photoManager.photoPaths[indexPath.row];
    cell.thumbnailView.image = [UIImage imageWithContentsOfFile:imagePath];
    cell.titleLabel.text = imagePath.lastPathComponent;
    
    return cell;
}

#pragma mark - CAPhotoManagerChangeListener

- (void)photoManagerZipSizeRequestDidStart {
    _setupProgressAlert.message = SIZE_PROGRESS_MESSAGE;
    [self.tabBarController presentViewController:_setupProgressAlert animated:YES completion:nil];
}

- (void)photoManagerZipSizeRequestDidComplete:(NSString * _Nonnull)msg {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        UIAlertController *alert = weakSelf.setupProgressAlert;
        alert.message = [NSString stringWithFormat:CONFIRM_DOWNLOAD_MESSAGE, msg];
        
        UIAlertAction *yesAction =
            [UIAlertAction actionWithTitle:ACTION_YES
                                     style:UIAlertActionStyleDefault
                                   handler:^(UIAlertAction *action) {
                                       [weakSelf.photoManager startDownloadingPhotos];
                                   }];
        
        UIAlertAction *noAction =
            [UIAlertAction actionWithTitle:ACTION_NO
                                     style:UIAlertActionStyleDestructive
                                   handler:nil];
        
        [alert addAction:noAction];
        [alert addAction:yesAction];
    }];
}

- (void)photoManagerDownloadDidStart {
    // Reinitialize alert to remove actions.
    _setupProgressAlert =
        [UIAlertController alertControllerWithTitle:nil
                                            message:nil
                                     preferredStyle:UIAlertControllerStyleAlert];
    
    [self setAlertViewDownloadPercent:0];
    [self.tabBarController presentViewController:_setupProgressAlert
                                        animated:YES
                                      completion:nil];
}

- (void)photoManagerDownloadDidProgress:(NSInteger)percentCompleted {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        [weakSelf setAlertViewDownloadPercent:percentCompleted];
    }];
}

- (void)photoManagerDownloadDidComplete:(NSString * _Nonnull)msg {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        weakSelf.setupProgressAlert.message = msg;
    }];
}

- (void)photoManagerUnzippingDidStart {
    [self setAlertViewUnzipPercent:0];
}

- (void)photoManagerUnzippingDidProgress:(NSInteger)percentCompleted {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        [weakSelf setAlertViewUnzipPercent:percentCompleted];
    }];
}

- (void)photoManagerUnzippingDidComplete:(NSString * _Nonnull)msg {
    __weak typeof(self) weakSelf = self;
    [CAUtils runBlockInMainThread: ^{
        weakSelf.setupProgressAlert.message = msg;
        [weakSelf.setupProgressAlert dismissViewControllerAnimated:YES completion:nil];
        [weakSelf.tableView reloadData];
    }];
}

@end
