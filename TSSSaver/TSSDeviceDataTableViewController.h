//
//  TSSDeviceDataTableViewController.h
//  TSSSaver
//
//  Created by Prathap Dodla on 11/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "TSSDeviceViewModel.h"

#import <UIKit/UIKit.h>

@interface TSSDeviceDataTableViewController : UITableViewController
    
@property (nonatomic, strong) NSArray<NSDictionary*>* details;
@property (nonatomic, strong) TSSDeviceViewModel* deviceViewModel;
@property (nonatomic, copy) void(^completion)(NSDictionary*);

@end
