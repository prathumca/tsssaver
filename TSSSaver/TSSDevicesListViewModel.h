//
//  TSSDevicesListViewModel.h
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TSSDeviceViewModel.h"

@interface TSSDevicesListViewModel : NSObject
    
- (void)loadDevices:(void (^_Nullable)(void))completion;
- (BOOL)deleteDevice:(TSSDeviceViewModel* _Nullable)deviceViewModel;
- (NSInteger)devicesCount;
- (TSSDeviceViewModel* _Nullable)deviceModelAtIndex:(NSInteger)index;
- (TSSDeviceViewModel*  _Nullable)deviceModelByUDID:(NSInteger)byUDID;
- (BOOL)isDeviceAlreadyExists:(NSInteger)udid ecid:(NSString* _Nullable)ecid;

@end
