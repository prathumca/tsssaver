//
//  TSSDeviceTableViewCell.h
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSSDeviceTableViewCell : UITableViewCell
    
@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *modelLabel;
@property (weak, nonatomic) IBOutlet UILabel *ecidLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastUpdatedDateLabel;

@end
