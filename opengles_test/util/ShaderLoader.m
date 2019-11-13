//
//  ShaderLoader.m
//  opengles_test
//
//  Created by liuzhe on 2019/10/31.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "ShaderLoader.h"

@implementation ShaderLoader

+ (BOOL)loadProgram:(GLuint*)program vertexFile: (NSString *)vertexFile fragmentFile: (NSString *)fragFile {
    NSString *vertexFilePath = [NSString stringWithFormat:@"/shader/%@", vertexFile];
    NSString *fragFilePath = [NSString stringWithFormat:@"/shader/%@", fragFile];
    NSString *vertexPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString: vertexFilePath];
    NSString *fragPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString: fragFilePath];

    NSString *vertexString = [NSString stringWithContentsOfFile:vertexPath encoding:NSUTF8StringEncoding error:nil];
    NSString *fragString = [NSString stringWithContentsOfFile:fragPath encoding:NSUTF8StringEncoding error:nil];

    return [self loadProgram:program vertexShader: vertexString.UTF8String fragmentShader: fragString.UTF8String];
}


+ (BOOL)loadProgram:(GLuint*)program vertexShader:(const char*)vertexShader fragmentShader:(const char*)fragmentShader
{
    GLuint vertShader, fragShader;
    NSString *vertShaderSource, *fragShaderSource;

    // Create the shader program.
    *program = glCreateProgram();

    // Create and compile the vertex shader.
    vertShaderSource = [NSString stringWithCString:vertexShader encoding:NSUTF8StringEncoding];
//    NSLog(@"%@", vertShaderSource);
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER source:vertShaderSource]) {
        NSLog(@"Failed to compile vertex shader");
        return NO;
    }

    // Create and compile fragment shader.
    fragShaderSource = [NSString stringWithCString:fragmentShader encoding:NSUTF8StringEncoding];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER source:fragShaderSource]) {
        NSLog(@"Failed to compile Y fragment shader");
        return NO;
    }

    // Attach vertex shader to programY.
    glAttachShader(*program, vertShader);

    // Attach fragment shader to program.
    glAttachShader(*program, fragShader);

    // Link the program.
    if (![self linkProgram:*program]) {
        NSLog(@"Failed to link program: %d", *program);

        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (*program) {
            glDeleteProgram(*program);
            *program = 0;
        }

        return NO;
    }

    // Release vertex and fragment shaders.
    if (vertShader) {
        glDetachShader(*program, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(*program, fragShader);
        glDeleteShader(fragShader);
    }

    return YES;
}

+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type source:(NSString *)sourceString
{
    if (sourceString == nil) {
        NSLog(@"Failed to load vertex shader: Empty source string");
        return NO;
    }

    GLint status;
    const GLchar *source;
    source = (GLchar *)[sourceString UTF8String];

    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);

    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        printf("Shader compile log:\n%s", log);
        printf("Shader: \n %s\n", source);
        free(log);
    }

    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    } else {
        NSLog(@"succede compile: %d", status);
    }

    return YES;
}

+ (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    glLinkProgram(prog);

    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }

    return YES;
}


@end
