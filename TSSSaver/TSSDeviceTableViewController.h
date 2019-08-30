//
//  TSSDeviceTableViewController.h
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TSSDeviceViewModel.h"
#import "TSSDevicesTableViewController.h"

@protocol TSSDeviceTableViewControllerDelegate <NSObject>
    
@optional
- (TSSDeviceViewModel*)model:(NSInteger)byUDID;
- (BOOL)isDeviceAlreadyExists:(NSInteger)udid ecid:(NSString*)ecid;
    
@end

@interface TSSDeviceTableViewController : UITableViewController
    
@property (nonatomic, copy) TSSDeviceViewModel* deviceViewModel;
@property (nonatomic, assign) NSObject<TSSDeviceTableViewControllerDelegate>* deviceListDelegate;

@end
