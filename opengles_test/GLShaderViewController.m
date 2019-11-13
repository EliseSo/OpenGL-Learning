//
//  GLShaderViewController.m
//  opengles_test
//
//  Created by liuzhe on 2019/11/4.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "GLShaderViewController.h"
#import <GLKit/GLKit.h>
#import <OpenGLES/ES2/glext.h>
#import "ShaderLoader.h"
#import "UIImage+Texture.h"

typedef struct {
    GLKVector3 positionCoord; // (X, Y, Z)
    GLKVector2 textureCoord; // (U, V)
} SceneVertex;

static const float width = 0.6;

static SceneVertex vertexex[] = {
    {{-width, 1.0, 0}, {0, 1}}, // left top
    {{-1, -1.0, 0}, {0, 0}},  // left bottom
    {{width, 1.0, 0}, {1, 1}},    // right top
    {{1, -1.0, 0}, {1, 0}}    // right bottom
};

//static SceneVertex vertexex[] = {
//    {{-1.0, 1.0, 0}, {0, 1}}, // left top
//    {{-1.0, -1.0, 0}, {0, 0}},  // left bottom
//    {{1.0, 1.0, 0}, {1, 1}},    // right top
//    {{1.0, -1.0, 0}, {1, 0}}    // right bottom
//};

@interface GLShaderViewController ()

@property (nonatomic, assign) SceneVertex *vertices;
@property (nonatomic, strong) EAGLContext *context;


@end

@implementation GLShaderViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    [self commonInit];
}

- (void)commonInit {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:self.context];

    self.vertices = vertexex;

    CAEAGLLayer *layer = [[CAEAGLLayer alloc] init];
    layer.frame = CGRectMake(0, 200, self.view.frame.size.width, self.view.frame.size.width);
    layer.contentsScale = [[UIScreen mainScreen] scale];  // contentScale to fit the screen scale
    [self.view.layer addSublayer:layer];

    [self bindRenderLayer:layer];

    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"res/checker.png"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
//    GLuint textureID = [self createTextureWithImage:image];
    GLuint textureID = [UIImage createTextureWithImage:image];

    glViewport(0, 0, self.drawableWidth, self.drawableHeight);
    NSLog(@"drawable width: %d, height: %d", self.drawableWidth, self.drawableHeight);

    GLuint program;
    [ShaderLoader loadProgram:&program vertexFile:@"trapezoid_vertex.glsl" fragmentFile:@"trapezoid_frag.glsl"];
    glUseProgram(program);

    GLuint positionSlot = glGetAttribLocation(program, "position");
    GLuint textureSlot = glGetUniformLocation(program, "texture");
    GLuint textureCoordsSlot = glGetAttribLocation(program, "textureCoords");

    glActiveTexture(GL_TEXTURE1);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glUniform1i(textureSlot, 1);

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureID);
    glUniform1i(textureSlot, 0);

    GLuint vertexBuffer;
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    GLsizeiptr bufferSizeBytes = sizeof(SceneVertex) * 4;
    glBufferData(GL_ARRAY_BUFFER, bufferSizeBytes, self.vertices, GL_STATIC_DRAW);

    glEnableVertexAttribArray(positionSlot);
    glVertexAttribPointer(positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, positionCoord));

    glEnableVertexAttribArray(textureCoordsSlot);
    glVertexAttribPointer(textureCoordsSlot, 2, GL_FLOAT, GL_FALSE, sizeof(SceneVertex), NULL + offsetof(SceneVertex, textureCoord));

    // draw Trapedzoid with projection matrix in shader
    GLuint proMatrix = glGetUniformLocation(program, "proMatrix");
    GLKMatrix4 pMatrix = GLKMatrix4MakePerspective(GLKMathRadiansToDegrees(120), 414.0/896.0, 0.1, 20);
    GLKMatrix4 rotateX = GLKMatrix4MakeXRotation(GLKMathDegreesToRadians(-15)); // rotate X
    GLKMatrix4 viewMatrix = GLKMatrix4MakeTranslation(0, 0, -2.0);  // translate Z
    GLKMatrix4 scale = GLKMatrix4MakeScale(0.8, 0.8, 0.8);  // scale
    GLKMatrix4 modleMatrix = GLKMatrix4Multiply(scale, rotateX);
    GLKMatrix4 projection = GLKMatrix4Multiply(pMatrix, GLKMatrix4Multiply(viewMatrix, modleMatrix));
    glUniformMatrix4fv(proMatrix, 1, GL_FALSE, projection.m);
    // projection matrix in shader

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    [self.context presentRenderbuffer:GL_RENDERBUFFER];

    glDeleteBuffers(1, &vertexBuffer);
    vertexBuffer = 0;
}

- (void)bindRenderLayer:(CALayer <EAGLDrawable> *)layer {
    GLuint renderBuffer;
    GLuint frameBuffer;

    glGenRenderbuffers(1, &renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, renderBuffer);
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:layer];

    glGenFramebuffers(1, &frameBuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, frameBuffer);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER,
                              GL_COLOR_ATTACHMENT0,
                              GL_RENDERBUFFER,
                              renderBuffer);
}

// viewPort widht
- (GLsizei)drawableWidth {
    GLsizei backingWidth;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &backingWidth);

    return backingWidth;
}

// viewPort height
- (GLsizei)drawableHeight {
    GLsizei backingHeight;
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &backingHeight);

    return backingHeight;
}


@end
