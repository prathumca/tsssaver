//
//  UIViewController+Utils.h
//  TSSSaver
//
//  Created by Prathap Dodla on 11/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Utils)
    
- (UIAlertController*)tss__showMessage:(NSString*)title message:(NSString*)message;
- (UIAlertController*)tss__showInformation:(NSString*)message;
- (UIAlertController*)tss__showError:(NSString*)message;
    
- (UIAlertController*)tss__showActivityIndicator;
- (UIAlertController*)tss__showActivityIndicator:(NSString*)title;
- (UIAlertController*)tss__showActivityIndicator:(NSString*)title message:(NSString*)message;

@end
