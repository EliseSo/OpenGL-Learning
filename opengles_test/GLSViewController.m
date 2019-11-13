//
//  GLSViewController.m
//  opengles_test
//
//  Created by liuzhe on 2019/10/31.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "GLSViewController.h"
#import <GLKit/GLKit.h>

#import "UIImage+Texture.h"
#import "ShaderLoader.h"

/*
    Use CAEAGLLayer to render shader vertex.
 */

typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 texture;
} TextureVertex;

@interface GLSViewController () {
    GLuint vbo;
    GLuint imageProgram;
}

@property (nonatomic, assign) TextureVertex *vertexs;
@property (nonatomic, strong) EAGLContext *contex;

@end

@implementation GLSViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self commit];
}

- (void)setupVertex {
    self.vertexs = malloc(sizeof(TextureVertex) * 4);
    self.vertexs[0] = (TextureVertex){{-1, 1, 0}, {0, 1}};   // left top
    self.vertexs[1] = (TextureVertex){{-1, -1, 0}, {0, 0}};   // left bottom
    self.vertexs[2] = (TextureVertex){{1, 1, 0}, {1, 1}};   // right top
    self.vertexs[3] = (TextureVertex){{1, -1, 0}, {1, 0}};   // right bottom
}

- (void)bindRenderLayer: (CALayer<EAGLDrawable> *) layer {
    GLuint renderBuffer; // render buffer
    GLuint frameBuffer;  // frame buffer

    // generate render buffer
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.contex renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];

    // render frame buffer
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              renderBuffer);
}

- (void)setupVertexBuffer {
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    GLsizeiptr bufferSizeBytes = sizeof(TextureVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertexs, GL_STATIC_DRAW);
}


- (void)commit {
    [self setupVertex];

    self.contex = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.contex];

    CAEAGLLayer *renderLayer = [[CAEAGLLayer alloc] init];
    renderLayer.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view.layer addSublayer: renderLayer];
    [self bindRenderLayer: renderLayer];

    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"res/planet.jpeg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    GLuint textureId = [UIImage createTextureWithImage:image];

    glViewport(0, 0, self.renderBufferWidth, self.renderBufferHeight);

    [ShaderLoader loadProgram:&imageProgram vertexFile:@"image_vertex.glsl" fragmentFile:@"image_frag.glsl"];
    glUseProgram(imageProgram);

    GLuint position = glGetAttribLocation(imageProgram, "position");
    GLuint texture = glGetUniformLocation(imageProgram, "texture");
    GLuint textureCoords = glGetAttribLocation(imageProgram, "textureCoords");

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(texture, 1);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(texture, 0);

    [self setupVertexBuffer];

    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(TextureVertex), NULL + offsetof(TextureVertex, positionCoord));

    glEnableVertexAttribArray(textureCoords);
    glVertexAttribPointer(textureCoords, 2, GL_FLOAT, GL_FALSE, sizeof(TextureVertex), NULL + offsetof(TextureVertex, texture));
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [self.contex presentRenderbuffer: GL_RENDERBUFFER];

    glDeleteBuffers(1, &vbo);
    vbo = 0;
}

- (GLsizei)renderBufferHeight {
    GLsizei height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    return height;
}

- (GLsizei)renderBufferWidth {
    GLsizei width;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    return width;
}

@end



