//
//  CACollectionViewCell.h
//  CAPhotoCacheDemo
//
//  Created by Cohen Adair on 2016-11-29.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//

@interface CACollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;

/**
 * @return The identifier associated with a CACollectionViewCell. Note that the value returned by 
 * this method needs to match the value entered in the "Identifier" field in the Storyboard/nib.
 */
+ (NSString *)IDENTIFIER;

/**
 * @return The maximum size for a CACollectionViewCell.
 */
+ (CGFloat)MAX_SIZE;

/**
 * @return The size of the cell, calculated based on the current screen width and given parameters.
 * @param spacing The spacing, in points, between cells. This applies to both horizontal and 
 *                vertical spacing.
 * @param cellsPerRow The number of cells in each row of the associated UICollectionView.
 */
+ (CGSize)sizeWithSpacing:(NSInteger)spacing cellsPerRow:(NSInteger)cellsPerRow;

@end
