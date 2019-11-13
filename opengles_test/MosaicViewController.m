//
//  MosaicViewController.m
//  opengles_test
//
//  Created by liuzhe on 2019/11/8.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "MosaicViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>

#import "ShaderLoader.h"
#import "UIImage+Texture.h"

/*
 use shader to realize mosaic
 */

typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 texture;
} TextureVertex;

typedef enum : NSUInteger {
    SquareMosaic,
    HexagonMosaic,
    TriangleMosaic,
    None
} MosaicType;

@interface MosaicViewController () {
    GLuint vbo;
    GLuint program;
    GLuint* mosaic;
}

@property (nonatomic, assign) TextureVertex *vertexs;
@property (nonatomic, strong) EAGLContext *context;
@property (nonatomic, strong) CAEAGLLayer *renderLayer;

@property (nonatomic, assign) MosaicType mosaicType;
@property (nonatomic, strong) UIButton *mosaicButton;

@end

@implementation MosaicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.mosaicType = None;
    [self setupRenderLayer];

    [self setupVertex];
    [self setViewport];

    [self setupProgram];

    [self commit];

    [self setMosaicButton];
}

- (void)setupRenderLayer {
    self.context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext: self.context];

    self.renderLayer = [[CAEAGLLayer alloc] init];
    self.renderLayer.frame = self.view.bounds;
    [self.view.layer addSublayer: self.renderLayer];

    [self bindRenderLayer: self.renderLayer];
}

- (void)setupVertex {
    self.vertexs = malloc(sizeof(TextureVertex) * 4);
    self.vertexs[0] = (TextureVertex){{-1, 1, 0}, {0, 0}};   // left top
    self.vertexs[1] = (TextureVertex){{-1, -1, 0}, {0, 1}};   // left bottom
    self.vertexs[2] = (TextureVertex){{1, 1, 0}, {1, 0}};   // right top
    self.vertexs[3] = (TextureVertex){{1, -1, 0}, {1, 1}};   // right bottom
}

- (void)setViewport {
    GLsizei width, height;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &height);
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &width);
    glViewport(0, 0, width, height);
}

- (void)setupProgram {
    [ShaderLoader loadProgram: &program vertexFile: @"image_vertex.glsl" fragmentFile: @"mosaic_frag.glsl"];
    glUseProgram(program);

    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"res/planet.jpeg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    GLuint textureId = [UIImage createTextureWithImage:image];

    GLuint position = glGetAttribLocation(program, "position");
    GLuint texture = glGetUniformLocation(program, "texture");
    GLuint textureCoords = glGetAttribLocation(program, "textureCoords");
    GLuint mosaicType = glGetUniformLocation(program, "mosaicType");
    mosaic = &mosaicType;

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(texture, 1);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureId);
    glUniform1i(texture, 0);

    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
    glBufferData(GL_ARRAY_BUFFER, sizeof(TextureVertex)*4, self.vertexs, GL_STATIC_DRAW);

    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(TextureVertex), NULL + offsetof(TextureVertex, positionCoord));

    glEnableVertexAttribArray(textureCoords);
    glVertexAttribPointer(textureCoords, 2, GL_FLOAT, GL_FALSE, sizeof(TextureVertex), NULL + offsetof(TextureVertex, texture));

    glUniform1i(*mosaic, (GLuint)self.mosaicType);

}

- (void)commit {
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    [self.context presentRenderbuffer: GL_RENDERBUFFER];
}

- (void)clearBuffers {
    glDeleteBuffers(1, &vbo);
    vbo = 0;
}

- (void)bindRenderLayer: (CALayer<EAGLDrawable> *) layer {
    GLuint renderBuffer; // render buffer
    GLuint frameBuffer;  // frame buffer

    // generate render buffer
    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];

    // render frame buffer
    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              renderBuffer);
}

// MARK: UI Controls
- (void)setMosaicButton {
    self.mosaicButton = [[UIButton alloc] initWithFrame:CGRectMake(40, 100, 40, 40)];
    self.mosaicButton.titleLabel.textColor = [UIColor whiteColor];
    self.mosaicButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview: self.mosaicButton];

    [self.mosaicButton addTarget: self action: @selector(changeMosaicType) forControlEvents: UIControlEventTouchUpInside];
}

- (void)changeMosaicType {
    self.mosaicType = (_mosaicType + 1) % 4;
    glUniform1i(*mosaic, (GLuint)self.mosaicType);

    NSLog(@"mosaic type: %d", (GLuint)self.mosaicType);
    [self commit];
}

@end
