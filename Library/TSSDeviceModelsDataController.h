//
//  TSSDeviceModelsDataController.h
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TSSDeviceModelsDataController : NSObject
    
+ (nonnull instancetype)sharedInstance;
    
@property (nonatomic, readonly, strong) NSArray* _Nullable allAvailableDevices;//Including iPhone, iPod, iPad, Apple TV, iWatch, Home Pod, etc..
@property (nonatomic, readonly, strong) NSArray* _Nullable allAvailableiDevices;//iPhone/iPod/iPad
    
- (void)loadDevices:(void (^ _Nullable )(void))completion;
- (void)loadAvailableOS:(NSString* _Nonnull)identifier completion:(void (^ _Nullable )(NSArray* _Nullable))completion;
- (NSString* _Nonnull)deviceModel:(NSString* _Nonnull)deviceIdentifier;

@end
