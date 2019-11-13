//
//  UIImage+Texture.h
//  opengles_test
//
//  Created by liuzhe on 2019/10/28.
//  Copyright © 2019 LZ. All rights reserved.
//



#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (Texture)

+ (GLuint)createTextureWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
