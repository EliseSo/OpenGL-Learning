//
//  CameraViewController.m
//  opengles_test
//
//  Created by liuzhe on 2019/11/5.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "CameraViewController.h"
#import <OpenGLES/ES2/glext.h>
#import "ShaderLoader.h"

/*
 Camera test view contoller
 Adjust the MVP matrix
 */

static const float ratio = 414.0/896.0;

typedef struct {
    GLKVector3 position;
    GLKVector4 color;
    GLKVector3 normal;
} CubicVertex;

static const CubicVertex renderCube[] = {
    // front view
    {{-0.5, 0.5, 0.5}, {1, 0, 0, 1}, {0, 0, 1}},  // left top
    {{-0.5, -0.5, 0.5}, {1, 0, 0, 1}, {0, 0, 1}},  // left bottom
    {{0.5, 0.5, 0.5}, {1, 0, 0, 1}, {0, 0, 1}},  // right top

    {{-0.5, -0.5, 0.5}, {1, 0, 0, 1}, {0, 0, 1}},  // left bottom
    {{0.5, -0.5, 0.5}, {1, 0, 0, 1}, {0, 0, 1}},  // right bottom
    {{0.5, 0.5, 0.5}, {1, 0, 0, 1}, {0, 0, 1}},  // right top

    // back view
    {{-0.5, 0.5, -0.5}, {1, 1, 0, 1}, {0, 0, -1}},  // left top
    {{-0.5, -0.5, -0.5}, {1, 1, 0, 1}, {0, 0, -1}},  // left bottom
    {{0.5, 0.5, -0.5}, {1, 1, 0, 1}, {0, 0, -1}},  // right top

    {{-0.5, -0.5, -0.5}, {1, 1, 0, 1}, {0, 0, -1}},  // left bottom
    {{0.5, -0.5, -0.5}, {1, 1, 0, 1}, {0, 0, -1}},  // right bottom
    {{0.5, 0.5, -0.5}, {1, 1, 0, 1}, {0, 0, -1}},  // right top

    // left view
    {{-0.5, 0.5, -0.5}, {1, 0, 1, 1}, {-1, 0, 0}},  // top back
    {{-0.5, 0.5, 0.5}, {1, 0, 1, 1}, {-1, 0, 0}},  // top front
    {{-0.5, -0.5, -0.5}, {1, 0, 1, 1}, {-1, 0, 0}},  // bottom back

    {{-0.5, -0.5, -0.5}, {1, 0, 1, 1}, {-1, 0, 0}},  // bottom back
    {{-0.5, 0.5, 0.5}, {1, 0, 1, 1}, {-1, 0, 0}},  // top front
    {{-0.5, -0.5, 0.5}, {1, 0, 1, 1}, {-1, 0, 0}},  // bottom front

    // right view
    {{0.5, 0.5, -0.5}, {0, 1, 0, 1}, {1, 0, 0}},  // top back
    {{0.5, 0.5, 0.5}, {0, 1, 0, 1}, {1, 0, 0}},  // top front
    {{0.5, -0.5, -0.5}, {0, 1, 0, 1}, {1, 0, 0}},  // bottom back

    {{0.5, -0.5, -0.5}, {0, 1, 0, 1}, {1, 0, 0}},  // bottom back
    {{0.5, 0.5, 0.5}, {0, 1, 0, 1}, {1, 0, 0}},  // top front
    {{0.5, -0.5, 0.5}, {0, 1, 0, 1}, {1, 0, 0}},  // bottom front

    // top view
    {{-0.5, 0.5, 0.5}, {0, 0, 1, 1}, {0, 1, 0}},  // left front
    {{0.5, 0.5, -0.5}, {0, 0, 1, 1}, {0, 1, 0}},  // right back
    {{-0.5, 0.5, -0.5}, {0, 0, 1, 1}, {0, 1, 0}},  // left back

    {{-0.5, 0.5, 0.5}, {0, 0, 1, 1}, {0, 1, 0}},  // left front
    {{0.5, 0.5, 0.5}, {0, 0, 1, 1}, {0, 1, 0}},  // right front
    {{0.5, 0.5, -0.5}, {0, 0, 1, 1}, {0, 1, 0}},  // right back

    // bottom view
    {{-0.5, -0.5, 0.5}, {0, 1, 1, 1}, {0, -1, 0}},  // left front
    {{0.5, -0.5, -0.5}, {0, 1, 1, 1}, {0, -1, 0}},  // right back
    {{-0.5, -0.5, -0.5}, {0, 1, 1, 1}, {0, -1, 0}},  // left back

    {{-0.5, -0.5, 0.5}, {0, 1, 1, 1}, {0, -1, 0}},  // left front
    {{0.5, -0.5, 0.5}, {0, 1, 1, 1}, {0, -1, 0}},  // right front
    {{0.5, -0.5, -0.5}, {0, 1, 1, 1}, {0, -1, 0}},  // right back
};

static const float cubeCenters[] = {
    0, 0, -5,
    0.5, 0.6, -6
};

@interface CameraViewController () {
    // vertex and program
    GLuint program;
    GLuint vertexBuffer;
    GLuint vertexArray;
    GLfloat changedValue;

    // matrix
    GLKMatrix4 projectionMatrix;
    GLKMatrix4 cameraMatrix;
    GLKMatrix4 modelMatrix[2];

    GLKMatrix4 translateMatrix[2];
    GLKMatrix4 rotateMatrix;
    GLKMatrix4 scaleMatrix;

    // light
    GLKVector3 lightPos;
    GLKVector3 lightColor;
}

@property (nonatomic, strong) CAEAGLLayer *renderLayer;
@property (nonatomic, strong) EAGLContext *context;

// test UI
@property (nonatomic, strong) UISlider *translateSlider;
@property (nonatomic, strong) UISlider *rotateSlider;
@property (nonatomic, strong) UISlider *projectionSlider;
@property (nonatomic, strong) UISlider *cameraSlider;
@property (nonatomic, strong) UISlider *lightSlider;


@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // set matrix
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(60), ratio, 0.1, 120);
    cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 1, 0, 0, 0, 0, 1, 0);
    rotateMatrix = GLKMatrix4MakeRotation(1.0, 1.0, 1.0, 1.0);
    scaleMatrix = GLKMatrix4MakeScale(1.0, 1.0, 1.0);
    translateMatrix[1] = GLKMatrix4MakeTranslation(cubeCenters[3], cubeCenters[4], cubeCenters[5]);
    translateMatrix[0] = GLKMatrix4MakeTranslation(cubeCenters[0], cubeCenters[1], cubeCenters[2]);
    lightPos = GLKVector3Make(0, 0, 0);

    [self setupEAGLContext];

    [ShaderLoader loadProgram: &program vertexFile:@"camera_vertex.glsl" fragmentFile:@"camera_frag.glsl"];
    [self setupVertexBuffer];
    [self setupVertexArray];

    [self setupTranslateSlider];
    [self setupRotateSlider];
    [self setupProjectionSlider];
    [self setupCameraSlider];
    [self setupLightSlider];
}


// MARK: vertex buffer
- (void)setupVertexBuffer {
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, sizeof(renderCube), renderCube, GL_STATIC_DRAW);
}

- (void)setupVertexArray {
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);

    GLuint position = glGetAttribLocation(program, "position");
    GLuint color = glGetAttribLocation(program, "color");
    GLuint normalLoc = glGetAttribLocation(program, "normal");

    glEnableVertexAttribArray(position);
    glVertexAttribPointer(position, 3, GL_FLOAT, GL_FALSE, sizeof(CubicVertex), NULL + offsetof(CubicVertex, position));

    glEnableVertexAttribArray(color);
    glVertexAttribPointer(color, 4, GL_FLOAT, GL_FALSE, sizeof(CubicVertex), NULL + offsetof(CubicVertex, color));

    glEnableVertexAttribArray(normalLoc);
    glVertexAttribPointer(normalLoc, 3, GL_FLOAT, GL_FALSE, sizeof(CubicVertex), NULL + offsetof(CubicVertex, normal));

    glBindVertexArrayOES(0);
}

- (void)setupEAGLContext {
    self.preferredFramesPerSecond = 10;
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext: view.context];

    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    view.drawableMultisample = GLKViewDrawableMultisample4X;
    view.drawableColorFormat = GLKViewDrawableColorFormatRGBA8888;
    glEnable(GL_DEPTH_TEST);
}

- (void)glkView:(nonnull GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    glClearColor(0.3, 0.4, 0.5, 1.0);

    glUseProgram(program);
    glBindVertexArrayOES(vertexArray);

    GLuint projectionLoc = glGetUniformLocation(program, "projectionMatrix");
    glUniformMatrix4fv(projectionLoc, 1, 0, projectionMatrix.m);

    GLuint cameraLoc = glGetUniformLocation(program, "cameraMatrix");
    glUniformMatrix4fv(cameraLoc, 1, 0, cameraMatrix.m);

    // set lights
    GLuint lightPosLoc = glGetUniformLocation(program, "lightPos");
    glUniform3f(lightPosLoc, lightPos.x, lightPos.y, lightPos.z);

    GLuint lightColorPos = glGetUniformLocation(program, "color");
    glUniform3f(lightColorPos, 1, 1, 1);

    glUniform1f(glGetUniformLocation(program, "ambientIntensity"), 0.6);
    glUniform1f(glGetUniformLocation(program, "diffuseIntensity"), 0.7);
    glUniform1f(glGetUniformLocation(program, "shininess"), 4);
    glUniform1f(glGetUniformLocation(program, "specularIntensity"), 1);

    for (int i = 0; i < 2; i++) {
        GLuint modelLoc = glGetUniformLocation(program, "modelMatrix");
        glUniformMatrix4fv(modelLoc, 1, 0, modelMatrix[i].m);
        glDrawArrays(GL_TRIANGLES, 0, 36);
    }
}

// matrix: projection matrix, model matrix, view matrix
- (void)update {
//    NSTimeInterval deltaTime = self.timeSinceLastUpdate;
//    changedValue += deltaTime;
//    GLfloat elValue = sinf(changedValue);
//    NSLog(@"elvalue: %f", elValue);
    modelMatrix[0] = GLKMatrix4Multiply(translateMatrix[0], rotateMatrix);
    modelMatrix[1] = GLKMatrix4Multiply(translateMatrix[1], rotateMatrix);
}

// MARK: UI controls
- (void)setupTranslateSlider {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 540, 100, 60)];
    label.text = @"Translate Z";
    [self.view addSubview: label];

    self.translateSlider = [[UISlider alloc] initWithFrame: CGRectMake(120, 540, 260, 60)];
    [self.view addSubview: self.translateSlider];

    self.translateSlider.maximumValue = 2;
    self.translateSlider.minimumValue = -10;
    self.translateSlider.value = -5;

    [self.translateSlider addTarget:self action:@selector(translateSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)translateSliderValueChanged {
    NSLog(@"translateSliderValueChanged: %f", self.translateSlider.value);
    translateMatrix[0] = GLKMatrix4MakeTranslation(0, 0, self.translateSlider.value);
}

- (void)setupRotateSlider {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 600, 100, 60)];
    label.text = @"Rotate XYZ";
    [self.view addSubview: label];

    self.rotateSlider = [[UISlider alloc] initWithFrame: CGRectMake(120, 600, 260, 60)];
    [self.view addSubview: self.rotateSlider];

    self.rotateSlider.maximumValue = GLKMathDegreesToRadians(360);
    self.rotateSlider.minimumValue = GLKMathDegreesToRadians(0);
    self.rotateSlider.value = GLKMathDegreesToRadians(0);

    [self.rotateSlider addTarget:self action:@selector(rotateSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)rotateSliderValueChanged {
    NSLog(@"rotateSliderValueChanged: %f", self.rotateSlider.value);
    rotateMatrix = GLKMatrix4MakeRotation(self.rotateSlider.value, 1.0, 1.0, 1.0);
}

- (void)setupProjectionSlider {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 660, 100, 60)];
    label.text = @"Projection radians";
    [self.view addSubview: label];

    self.projectionSlider = [[UISlider alloc] initWithFrame: CGRectMake(120, 660, 260, 60)];
    [self.view addSubview: self.projectionSlider];

    self.projectionSlider.maximumValue = 180;
    self.projectionSlider.minimumValue = 0;
    self.projectionSlider.value = 60;

    [self.projectionSlider addTarget:self action:@selector(projectionSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)projectionSliderValueChanged {
    NSLog(@"projectionSliderValueChanged: %f", self.projectionSlider.value);
    projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(self.projectionSlider.value), ratio, 0.1, 120);
}

- (void)setupCameraSlider {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 720, 100, 60)];
    label.text = @"Camera";
    [self.view addSubview: label];

    self.cameraSlider = [[UISlider alloc] initWithFrame: CGRectMake(120, 720, 260, 60)];
    [self.view addSubview: self.cameraSlider];

    self.cameraSlider.maximumValue = 5;
    self.cameraSlider.minimumValue = -5;
    self.cameraSlider.value = 0;

    [self.cameraSlider addTarget:self action:@selector(cameraSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)cameraSliderValueChanged {
    NSLog(@"cameraSliderValueChanged: %f", self.cameraSlider.value);
    // eye position
    cameraMatrix = GLKMatrix4MakeLookAt(0, 0, self.cameraSlider.value, 0, 0, 2, 0, 1, 0);
    // center, the point camera look to
//    cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 1, self.cameraSlider.value, 0, 0, 0, 1, 0);
    // up, the up direction of the camera top
//    cameraMatrix = GLKMatrix4MakeLookAt(0, 0, 1, 0, 0, 0, 0, self.cameraSlider.value, 1);

}

- (void)setupLightSlider {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10, 780, 100, 60)];
    label.text = @"Light";
    [self.view addSubview: label];

    self.lightSlider = [[UISlider alloc] initWithFrame: CGRectMake(120, 780, 260, 60)];
    [self.view addSubview: self.lightSlider];

    self.lightSlider.maximumValue = 1;
    self.lightSlider.minimumValue = -1;
    self.lightSlider.value = 0;

    [self.lightSlider addTarget:self action:@selector(lightSliderValueChanged) forControlEvents:UIControlEventValueChanged];
}

- (void)lightSliderValueChanged {
    NSLog(@"projectionSliderValueChanged: %f", self.lightSlider.value);
    lightPos = GLKVector3Make(self.lightSlider.value, self.lightSlider.value, 1);
//    lightColor = GLKVector3Make(self.lightSlider.value/5.0, self.lightSlider.value/5.0, 0);
}


@end

