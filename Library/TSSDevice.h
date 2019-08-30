//
//  TSSDevice.h
//  TSSSaver
//
//  Created by Prathap Dodla on 08/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TSSDevice : NSObject <NSCopying>
    
@property (nonatomic, assign) NSInteger udid;
@property (nonatomic, strong) NSString* name;//Name of device
@property (nonatomic, strong) NSString* type;//iPhone 7 Plus (Global)
@property (nonatomic, strong) NSString* identifier;//iPhone 9,2
@property (nonatomic, strong) NSString* ecid;//ABC1245DC12679
@property (nonatomic, strong) NSDate* lastUpdated;
@property (nonatomic, strong) NSString* boardConfig;//D11AP
@property (nonatomic, strong) UIImage* image;
@property (nonatomic, assign, getter=isAutoUpdate) BOOL autoUpdate;
@property (nonatomic, assign, getter=isShowNotification) BOOL showNotification;
@property (nonatomic, assign) NSInteger lastiOS;
    
- (instancetype)init:(NSDictionary*)dictionary;
    
- (NSDictionary*)dictionaryRepresentation;
- (NSDictionary*)blobParams;
- (UIImage*)deviceImage;

@end
