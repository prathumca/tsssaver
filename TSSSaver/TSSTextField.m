//
//  TSSTextField.m
//  TSSSaver
//
//  Created by Prathap Dodla on 12/06/18.
//  Copyright © 2018 IArrays. All rights reserved.
//
//Thanks to: https://stackoverflow.com/questions/27944781/how-to-change-the-tint-color-of-the-clear-button-on-a-uitextfield

#import "TSSTextField.h"

@implementation TSSTextField

- (void) layoutSubviews {
    [super layoutSubviews];
    [self tintButtonClear];
}
    
- (UIButton *)buttonClear {
    return [self valueForKey:@"_clearButton"];
}
    
- (void)tintButtonClear {
    UIButton *buttonClear = [self buttonClear];
    if (self.colorButtonClearNormal && self.colorButtonClearHighlighted && buttonClear) {
        if (!self.imageButtonClearHighlighted) {
            UIImage *imageHighlighted = [buttonClear imageForState:UIControlStateHighlighted];
            self.imageButtonClearHighlighted = [[self class] imageWithImage:imageHighlighted tintColor:self.colorButtonClearHighlighted];
        }
        if (!self.imageButtonClearNormal) {
            UIImage *imageNormal = [buttonClear imageForState:UIControlStateNormal];
            self.imageButtonClearNormal = [[self class] imageWithImage:imageNormal tintColor:self.colorButtonClearNormal];
        }
        
        if (self.imageButtonClearHighlighted && self.imageButtonClearNormal) {
            [buttonClear setImage:self.imageButtonClearHighlighted forState:UIControlStateHighlighted];
            [buttonClear setImage:self.imageButtonClearNormal forState:UIControlStateNormal];
        } else {
            buttonClear.tintColor = self.colorButtonClearHighlighted;
            buttonClear.backgroundColor = [UIColor clearColor];
        }
    }
}
    
+ (UIImage *)imageWithImage:(UIImage *)image tintColor:(UIColor *)tintColor {
    if (image == nil) {
        return nil;
    }
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect rect = (CGRect){ CGPointZero, image.size };
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    [image drawInRect:rect];
    
    CGContextSetBlendMode(context, kCGBlendModeSourceIn);
    [tintColor setFill];
    CGContextFillRect(context, rect);
    
    UIImage *imageTinted  = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageTinted;
}

@end
