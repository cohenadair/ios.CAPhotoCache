//
//  CATableViewCell.h
//  CAPhotoCacheDemo
//
//  Created by Cohen Adair on 2016-11-27.
//  Copyright © 2016 Cohen Adair. All rights reserved.
//
//  For the full copyright and license information, please
//  view the LICENSE file that was distributed with this
//  source code.
//

@interface CATableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *thumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

/**
 * The identifier associated with a CATableViewCell. Note that the value returned by this method
 * needs to match the value entered in the "Identifier" field in the Storyboard/nib.
 */
+ (NSString *)IDENTIFIER;

@end
