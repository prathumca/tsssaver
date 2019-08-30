//
//  TSSDevicesListViewModel.m
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "TSSUtils.h"

#import "TSSDevicesListViewModel.h"

@interface TSSDevicesListViewModel ()
    
@property (nonatomic, strong) NSArray<TSSDeviceViewModel*>* devicesViewModels;
    
@end

@implementation TSSDevicesListViewModel
    
- (instancetype)init {
    if (self = [super init]) {
        self.devicesViewModels = [[NSMutableArray alloc] init];
    }
    return self;
}
    
- (void)loadDevices:(void (^)(void))completion {
    [(NSMutableArray*)self.devicesViewModels removeAllObjects];
    NSMutableOrderedSet* uniqueDevices = [[NSMutableOrderedSet alloc] init];
    [TSSUtils loadStoredDevices:^(NSArray *devices) {
        for (NSDictionary* dict in devices) {
            TSSDeviceViewModel* deviceModel = [[TSSDeviceViewModel alloc] initWithDeviceData:dict];
            [uniqueDevices addObject:deviceModel];
        }
        [(NSMutableArray*)self.devicesViewModels addObjectsFromArray:[uniqueDevices array]];
        //finally call completion
        dispatch_async(dispatch_get_main_queue(), ^{
            completion();
        });
    }];
}

- (NSInteger)devicesCount {
    return self.devicesViewModels.count;
}

- (TSSDeviceViewModel* _Nullable)deviceModelAtIndex:(NSInteger)index {
    if (index < [self devicesCount]) {
        return self.devicesViewModels[index];
    }
    return nil;
}

- (TSSDeviceViewModel* _Nullable)deviceModelByUDID:(NSInteger)byUDID {
    for (TSSDeviceViewModel* deviceModel in self.devicesViewModels) {
        if (deviceModel.udid == byUDID) {
            return deviceModel;
        }
    }
    return nil;
}

- (BOOL)isDeviceAlreadyExists:(NSInteger)udid ecid:(NSString*)ecid {
    for (TSSDeviceViewModel* deviceModel in self.devicesViewModels) {
        if ([[deviceModel ecid] isEqualToString:ecid] && [deviceModel udid] != udid) {
            return YES;
        }
    }
    return NO;
}
    
- (BOOL)deleteDevice:(TSSDeviceViewModel*)deviceViewModel {
    if ([TSSUtils deleteDevice:deviceViewModel.udid]) {
        [(NSMutableArray*)self.devicesViewModels removeObject:deviceViewModel];
        return YES;
    }
    return NO;
}

@end
