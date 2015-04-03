//
//  MenuOptionTableViewCell.h
//  iSleepLate
//
//  Created by David Neubauer on 4/2/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuOptionTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *menuTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *selectionIndicator;

@end
