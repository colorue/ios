//
//  UIImage_UIImageColorPicker.h
//  Colorue
//
//  Created by Dylan Wight on 6/5/16.
//  Copyright © 2016 Dylan Wight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Canvix-Bridging-Header.h"

@implementation UIImage (Picker)
- (nullable UIColor *)colorAtPosition:(CGPoint)position {

  CGRect sourceRect = CGRectMake(position.x, position.y, 1.f, 1.f);
  CGImageRef imageRef = CGImageCreateWithImageInRect(self.CGImage, sourceRect);

  if (position.y < 0 || position.y > self.size.height || position.x < 0 || position.x > self.size.width) {
    CGImageRelease(imageRef);
    return nil;
  }

  CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
  unsigned char *buffer = malloc(4);
  CGBitmapInfo bitmapInfo = kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big;
  CGContextRef context = CGBitmapContextCreate(buffer, 1, 1, 8, 4, colorSpace, bitmapInfo);
  CGColorSpaceRelease(colorSpace);
  CGContextDrawImage(context, CGRectMake(0.f, 0.f, 1.f, 1.f), imageRef);
  CGImageRelease(imageRef);
  CGContextRelease(context);

  CGFloat r = buffer[0] / 255.f;
  CGFloat g = buffer[1] / 255.f;
  CGFloat b = buffer[2] / 255.f;
  CGFloat a = buffer[3] / 255.f;

  free(buffer);

  return [UIColor colorWithRed:r green:g blue:b alpha:a];
}
@end
