//
//  TSSDeviceViewModel.h
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "TSSDevice.h"

@interface TSSDeviceViewModel : NSObject <NSCopying>

@property (nonatomic, readonly, strong) TSSDevice* device;

- (NSInteger)udid;
- (NSString*)name;
- (NSString*)type;
- (NSString*)identifier;
- (NSString*)ecid;
- (NSString*)descriptiveECID;
- (NSString*)lastUpdated;
- (NSString*)lastUpdated:(NSString*)prefix;
- (NSString*)boardConfig;
- (UIImage*)image;
- (BOOL)autoUpdate;
- (BOOL)showNotification;
- (NSDictionary*)blobParams;

- (instancetype)init:(TSSDevice*)devicep;
- (instancetype)initWithDeviceData:(NSDictionary*)deviceData;

- (UIImage*)deviceImage;

@end
