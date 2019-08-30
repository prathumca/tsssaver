//
//  TSSBlobSaver.h
//  TSSSaver
//
//  Created by Prathap Dodla on 11/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

@interface TSSBlob : NSObject

@property (nonatomic, strong, readonly) NSString* _Nullable urlString;
@property (nonatomic, strong, readonly) NSURL* _Nullable blobURL;
    
- (nonnull instancetype)init:(NSString* _Nonnull)urlString;
    
@end

@interface TSSBlobSaver : NSObject
    
+ (nonnull instancetype)sharedInstance;
    
- (void)saveBlob:(NSDictionary* _Nonnull)blobParams completion:(void (^ _Nullable )(TSSBlob* _Nullable,  NSError* _Nullable))completion;

@end
