//
//  ShaderLoader.h
//  opengles_test
//
//  Created by liuzhe on 2019/10/31.
//  Copyright © 2019 LZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ShaderLoader : NSObject

+ (BOOL)loadProgram:(GLuint*)program vertexFile: (NSString *)vertexFile fragmentFile: (NSString *)fragFile;

+ (BOOL)loadProgram:(GLuint*)program vertexShader:(const char*)vertexShader fragmentShader:(const char*)fragmentShader;

@end

NS_ASSUME_NONNULL_END
