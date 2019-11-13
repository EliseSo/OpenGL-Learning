//
//  CubicViewController.m
//  opengles_test
//
//  Created by liuzhe on 2019/11/5.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "CubicViewController.h"
#import "ShaderLoader.h"
#import <OpenGLES/ES1/glext.h>


typedef struct {
    GLKVector3 position;
    GLKVector2 texturePos;
    GLKVector3 normal;
} CubeTextureVertex;

static const CubeTextureVertex renderCube[] = {
    // front view
    {{-0.5, 0.5, 0.5}, {0, 0}, {0, 0, 1}},  // left top
    {{-0.5, -0.5, 0.5}, {0, 1}, {0, 0, 1}},  // left bottom
    {{0.5, 0.5, 0.5}, {1, 0}, {0, 0, 1}},  // right top

    {{-0.5, -0.5, 0.5}, {0, 1}, {0, 0, 1}},  // left bottom
    {{0.5, -0.5, 0.5}, {1, 1}, {0, 0, 1}},  // right bottom
    {{0.5, 0.5, 0.5}, {1, 0}, {0, 0, 1}},  // right top

    // back view
    {{-0.5, 0.5, -0.5}, {0, 0}, {0, 0, -1}},  // left top
    {{-0.5, -0.5, -0.5}, {0, 1}, {0, 0, -1}},  // left bottom
    {{0.5, 0.5, -0.5}, {1, 0}, {0, 0, -1}},  // right top

    {{-0.5, -0.5, -0.5}, {0, 1}, {0, 0, -1}},  // left bottom
    {{0.5, -0.5, -0.5}, {1, 1}, {0, 0, -1}},  // right bottom
    {{0.5, 0.5, -0.5}, {1, 0}, {0, 0, -1}},  // right top

    // left view
    {{-0.5, 0.5, -0.5}, {0, 0}, {-1, 0, 0}},  // top back
    {{-0.5, 0.5, 0.5}, {0, 1}, {-1, 0, 0}},  // top front
    {{-0.5, -0.5, -0.5}, {1, 0}, {-1, 0, 0}},  // bottom back

    {{-0.5, -0.5, -0.5}, {1, 0}, {-1, 0, 0}},  // bottom back
    {{-0.5, 0.5, 0.5}, {0, 1}, {-1, 0, 0}},  // top front
    {{-0.5, -0.5, 0.5}, {1, 1}, {-1, 0, 0}},  // bottom front

    // right view
    {{0.5, 0.5, -0.5}, {1, 0}, {1, 0, 0}},  // top back
    {{0.5, 0.5, 0.5}, {0, 0}, {1, 0, 0}},  // top front
    {{0.5, -0.5, -0.5}, {1, 1}, {1, 0, 0}},  // bottom back

    {{0.5, -0.5, -0.5}, {1, 1}, {1, 0, 0}},  // bottom back
    {{0.5, 0.5, 0.5}, {0, 0}, {1, 0, 0}},  // top front
    {{0.5, -0.5, 0.5}, {0, 1}, {1, 0, 0}},  // bottom front

    // top view
    {{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}},  // left front
    {{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}},  // right back
    {{-0.5, 0.5, -0.5}, {0, 0}, {0, 1, 0}},  // left back

    {{-0.5, 0.5, 0.5}, {0, 1}, {0, 1, 0}},  // left front
    {{0.5, 0.5, 0.5}, {1, 1}, {0, 1, 0}},  // right front
    {{0.5, 0.5, -0.5}, {1, 0}, {0, 1, 0}},  // right back

    // bottom view
    {{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}},  // left front
    {{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}},  // right back
    {{-0.5, -0.5, -0.5}, {0, 0}, {0, -1, 0}},  // left back

    {{-0.5, -0.5, 0.5}, {0, 1}, {0, -1, 0}},  // left front
    {{0.5, -0.5, 0.5}, {1, 1}, {0, -1, 0}},  // right front
    {{0.5, -0.5, -0.5}, {1, 0}, {0, -1, 0}},  // right back
};



@interface CubicViewController () {
    GLuint vertexBuffer;
    GLKMatrix4 translate;
    GLKMatrix4 rotate;
    GLfloat changeValue;
    GLfloat ratio;

    // skybox lookAt matrix
    GLKVector3 eyeVector;
    GLKVector3 centerVector;
    GLKVector3 upVector;
}

@property (nonatomic, strong) GLKBaseEffect *baseEffect;
@property (nonatomic, strong) GLKSkyboxEffect *skyboxEffect;
@property (nonatomic, strong) EAGLContext *context;

@end

@implementation CubicViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ratio = self.view.bounds.size.width / self.view.bounds.size.height;

    [self setupEAGLContext];
    [self setupVertex];
    [self setupMatrix];
    [self setupCubeTexture];
    [self setupSkyboxEffect];
}

- (void)setupMatrix {
    eyeVector = GLKVector3Make(0, 0, 0);
    upVector = GLKVector3Make(0, 0, 1);

}

- (void)setupEAGLContext {
    self.preferredFramesPerSecond = 10;
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    self.context = view.context;
    [EAGLContext setCurrentContext: view.context];

    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
}

- (void)setupVertex {
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(renderCube), renderCube, GL_STATIC_DRAW);
}

- (void)setupSkyboxEffect {
    NSString *skyboxPath = [[NSBundle mainBundle] pathForResource:@"skybox" ofType: @"png" inDirectory: @"res"];

    NSError *error;
    GLKTextureInfo *skyboxTexture = [GLKTextureLoader cubeMapWithContentsOfFile: skyboxPath options:nil error:&error];
    if (error) {
        NSLog(@"load texture error: %@", error.debugDescription);
    }

    self.skyboxEffect = [[GLKSkyboxEffect alloc] init];
    self.skyboxEffect.center = GLKVector3Make(0, 0, 0);
    self.skyboxEffect.textureCubeMap.name = skyboxTexture.name;
    self.skyboxEffect.textureCubeMap.target = skyboxTexture.target;

    self.skyboxEffect.xSize = 6.0;
    self.skyboxEffect.ySize = 6.0;
    self.skyboxEffect.zSize = 6.0;
}

- (void)setupCubeTexture {
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingString: @"/res/emoji.jpeg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                               options:options
                                                                 error:NULL];

    self.baseEffect = [[GLKBaseEffect alloc] init];
    self.baseEffect.texture2d0.name = textureInfo.name;
    self.baseEffect.texture2d0.target = textureInfo.target;

    self.baseEffect.light0.enabled = GL_TRUE;
    self.baseEffect.light0.position = GLKVector4Make(0.0f, 1.0f, -2.0f, 1.0f);
    self.baseEffect.light0.specularColor = GLKVector4Make(0.25f, 0.25f, 0.25f, 1.0f);
    self.baseEffect.light0.diffuseColor = GLKVector4Make(0.75f, 0.75f, 0.75f, 1.0f);
    self.baseEffect.lightingType = GLKLightingTypePerPixel;

    self.baseEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), ratio, 0.1, 20.0);
    translate = GLKMatrix4MakeTranslation(0, 0, -3.0);
    rotate = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(45), 1, 1, 1);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Multiply(translate, rotate);

    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.6f, 0.6f, 0.7f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

    self.skyboxEffect.center = eyeVector;
    self.skyboxEffect.transform.projectionMatrix = self.baseEffect.transform.projectionMatrix;
    self.skyboxEffect.transform.modelviewMatrix = self.baseEffect.transform.modelviewMatrix;
    [self.skyboxEffect prepareToDraw];
    glDepthMask(GL_FALSE);
    [self.skyboxEffect draw];
    glDepthMask(GL_TRUE);

    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, 0);
    glBindTexture(GL_TEXTURE_CUBE_MAP, 0);
    glBindVertexArrayOES(0);

    // draw cube
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(CubeTextureVertex), NULL + offsetof(CubeTextureVertex, position));

    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(CubeTextureVertex), NULL + offsetof(CubeTextureVertex, texturePos));

    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, sizeof(CubeTextureVertex), NULL + offsetof(CubeTextureVertex, normal));

    [self.baseEffect prepareToDraw];
    glDrawArrays(GL_TRIANGLES, 0, 36);
}

- (void)update {
    NSTimeInterval deltaTime = self.timeSinceLastUpdate;
    changeValue += deltaTime;
    float value = sinf(changeValue);

    translate = GLKMatrix4MakeTranslation(0, 0, -3.0);
    rotate = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(changeValue * 40), 1, 1, 1);
    self.baseEffect.transform.modelviewMatrix = GLKMatrix4Multiply(translate, rotate);

    eyeVector = GLKVector3Make(value, value, value);
    self.skyboxEffect.transform.modelviewMatrix = GLKMatrix4MakeLookAt(eyeVector.x, eyeVector.y, eyeVector.z, centerVector.x, centerVector.y, centerVector.z, upVector.x, upVector.y, upVector.z);
}

@end
