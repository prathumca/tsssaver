//
//  UIViewController+Utils.m
//  TSSSaver
//
//  Created by Prathap Dodla on 11/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import "UIViewController+Utils.h"

@implementation UIViewController (Utils)
    
- (UIAlertController*)tss__showMessage:(NSString*)title message:(NSString*)message {
    __weak __typeof(self)weakSelf = self;
    __block UIAlertController* alertController = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel") style:UIAlertActionStyleCancel handler:nil];
        [alertController addAction:cancelAction];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    });
    return alertController;
}
    
- (UIAlertController*)tss__showInformation:(NSString*)message {
    return [self tss__showMessage:NSLocalizedString(@"Information", @"Information") message:message];
}
    
- (UIAlertController*)tss__showError:(NSString*)message {
    return [self tss__showMessage:NSLocalizedString(@"Error", @"Error") message:message];
}
    
- (UIAlertController*)tss__showActivityIndicator:(NSString*)title message:(NSString*)message {
    __weak __typeof(self)weakSelf = self;
    __block UIAlertController* alertController = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        alertController = [UIAlertController alertControllerWithTitle:title message:[NSString stringWithFormat:@"%@\n\n\n", message] preferredStyle:UIAlertControllerStyleAlert];
        UIActivityIndicatorView* indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        indicator.color = [UIColor blackColor];
        indicator.translatesAutoresizingMaskIntoConstraints = NO;
        [alertController.view addSubview:indicator];
        NSDictionary * views = @{@"alertController" : alertController.view, @"indicator" : indicator};
        
        NSArray * constraintsVertical = [NSLayoutConstraint constraintsWithVisualFormat:@"V:[indicator]-(20)-|" options:0 metrics:nil views:views];
        NSArray * constraintsHorizontal = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[indicator]|" options:0 metrics:nil views:views];
        NSArray * constraints = [constraintsVertical arrayByAddingObjectsFromArray:constraintsHorizontal];
        [alertController.view addConstraints:constraints];
        [indicator setUserInteractionEnabled:NO];
        [indicator startAnimating];
        [weakSelf presentViewController:alertController animated:YES completion:nil];
    });
    return alertController;
}
    
- (UIAlertController*)tss__showActivityIndicator:(NSString*)title {
    return [self tss__showActivityIndicator:title];
}
    
- (UIAlertController*)tss__showActivityIndicator {
    return [self tss__showActivityIndicator:nil];
}

@end
