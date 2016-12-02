//
//  CACollectionViewController.m
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

#import "CACollectionViewController.h"
#import "CACollectionViewCell.h"
#import "CAPhotoManager.h"
#import "CAUtils.h"

static NSInteger const CELL_SPACING = 2;
static NSInteger const CELLS_PER_ROW_SMALL = 4;
static NSInteger const CELLS_PER_ROW_LARGE = 8;

@implementation CACollectionViewController {
    CAPhotoManager *_photoManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _photoManager = [CAPhotoManager sharedPhotoManager];
}

#pragma mark UICollectionView Data Source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section
{
    return _photoManager.photoPaths.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CACollectionViewCell *cell = (CACollectionViewCell *)
        [collectionView dequeueReusableCellWithReuseIdentifier:CACollectionViewCell.IDENTIFIER
                                                  forIndexPath:indexPath];
    
    cell.thumbnailView.image =
        [UIImage imageWithContentsOfFile:_photoManager.photoPaths[indexPath.item]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    CGSize size =
        [CACollectionViewCell sizeWithSpacing:CELL_SPACING cellsPerRow:CELLS_PER_ROW_SMALL];
    
    // If the cells are too large, increase the number of cells.
    if (size.width > CACollectionViewCell.MAX_SIZE) {
        NSLog(@"Size: %@", NSStringFromCGSize(size));
        return [CACollectionViewCell sizeWithSpacing:CELL_SPACING cellsPerRow:CELLS_PER_ROW_LARGE];
    }
    
    NSLog(@"Size: %@", NSStringFromCGSize(size));
    return size;
}

@end
