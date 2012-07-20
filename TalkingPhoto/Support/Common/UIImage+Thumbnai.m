//
//  UIImage+UxinExtend.m
//  UXinClient
//
//  Created by tanyu on 12/12/11.
//  Copyright (c) 2011 D-TONG-TELECOM. All rights reserved.
//

#import "UIImage+Thumbnai.h"

@implementation UIImage (UxinExtend)
-(UIImage*)scaleToSize:(CGSize)size  
{  
  CGFloat width = CGImageGetWidth(self.CGImage);  
  CGFloat height = CGImageGetHeight(self.CGImage);  
  
  float verticalRadio = size.height*1.0/height;   
  float horizontalRadio = size.width*1.0/width;  
  
  float radio = 1;  
  if(verticalRadio>1 && horizontalRadio>1)  
  {  
    radio = verticalRadio > horizontalRadio ? horizontalRadio : verticalRadio;     
  }  
  else  
  {  
    radio = verticalRadio < horizontalRadio ? horizontalRadio : verticalRadio;     
  }  
  
  width = width*radio;  
  height = height*radio;  
  
  int xPos = (size.width - width)/2;  
  int yPos = (size.height-height)/2;  
  
  // 创建一个bitmap的context    
  // 并把它设置成为当前正在使用的context    
  UIGraphicsBeginImageContext(size);    
  
  // 绘制改变大小的图片    
  [self drawInRect:CGRectMake(xPos, yPos, width, height)];    
  
  // 从当前context中创建一个改变大小后的图片    
  UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();    
  
  // 使当前的context出堆栈    
  UIGraphicsEndImageContext();    
  
  // 返回新的改变大小后的图片    
  return scaledImage;  
} 
@end
