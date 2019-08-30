//
//  TSSTextField.h
//  TSSSaver
//
//  Created by Prathap Dodla on 12/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//

#import <UIKit/UIKit.h>

IB_DESIGNABLE

@interface TSSTextField : UITextField
    
@property (nonatomic, strong) IBInspectable UIColor *colorButtonClearHighlighted;
@property (nonatomic, strong) IBInspectable UIColor *colorButtonClearNormal;

@property (nonatomic, strong) IBInspectable UIImage *imageButtonClearHighlighted;
@property (nonatomic, strong) IBInspectable UIImage *imageButtonClearNormal;

@end
