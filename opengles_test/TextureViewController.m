//
//  TextureViewController.m
//  opengles_test
//
//  Created by liuzhe on 2019/10/28.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "TextureViewController.h"
#import <OpenGLES/ES2/glext.h>

#import "ShaderLoader.h"

static const float ratio = 414.0/896.0;

typedef struct {
    GLKVector3 positionCoords;
    GLKVector4 color;
}sceneVertex;

typedef struct {
    GLKVector3  position;
}positionVertex;

//static const positionVertex vertices[] = {
//    {{0.0f, 0.4 * ratio, 0.0f}},
//    {{-0.346f, -0.2 * ratio, 0.0f}},
//    {{0.346f, -0.2 * ratio, 0.0f}},
//};

static const sceneVertex trapezoid[] = {
    {{-0.5, 0.5, 0.0}, {0.6, 0, 0.6, 0.8}},
    {{-0.5, -0.5, 0.6}, {0.6, 0.6, 0, 1.0}},
    {{0.5, 0.5, 0.0}, {0.0, 0.6, 0.6, 0.8}},
    {{0.5, -0.5, 0.6}, {0.77, 0.44, 0.77, 1.0}}
};


/*
    draw square triangle_strip : top, left, right, bottom
    top, left, right, left, bottom, right
*/
static const sceneVertex vertices[] = {
    {{0.0f, 0.746 * ratio, -0.0}, {0.6, 0, 0.6, 0.8}},   // top
    {{-0.346f, 0, 0.0f}, {0.6, 0.6, 0, 1.0}},    // left
    {{0.346f, 0, 0.0f}, {0.0, 0.6, 0.6, 0.8}}, // right
    {{0.0f, -0.746 * ratio, 0.0}, {0.77, 0.44, 0.77, 1.0}},    // bottom
};

/*
 draw corner:
    top, left, front,
    left, front, front, -- line
    front, right, top,
    right, top, back,
    top, back, back,    -- line
    back, top, left
 */
//static const sceneVertex vertices[] = {
//    {{0.0f, 0.5 * ratio, 0.0f}, {0.6, 0, 0.6, 0.8}},   // top
//    {{-0.5f, 0.0, 0.0f}, {0.6, 0, 0.6, 0.8}},    // x left
//    {{0.0f, 0, 0.5f}, {0.6, 0, 0.6, 0.8}}, // z front
//
//    {{0.0f, 0, 0.5f}, {0.0, 0.6, 0.6, 0.8}}, // z front
//
//    {{0.5f, 0.0, 0.0f}, {0.0, 0.6, 0.6, 0.8}},    // x right
//    {{0.0f, 0.5 * ratio, 0.0f}, {0.0, 0.9, 0.9, 0.8}},   // top
//    {{0.0f, 0, -0.5f}, {0.0, 0.9, 0.9, 0.8}}, // z back
//
//    {{0.0f, 0, -0.5f}, {0.9, 0.6, 0, 1.0}}, // z back
//    {{0.0f, 0.5 * ratio, 0.0f}, {0.9, 0.6, 0, 1.0}},   // top
//    {{-0.5f, 0.0, 0.0f}, {0.9, 0.6, 0, 1.0}},    // x left
//};

/*  draw triangles for corn
static const sceneVertex vertices[] = {
    {{0.0f, 0.5 * ratio, 0.0f}, {0.6, 0, 0.6, 0.8}},   // top
    {{-0.5f, 0.0, 0.0f}, {0.6, 0, 0.6, 0.8}},    // x left
    {{0.0f, 0, 0.5f}, {0.6, 0, 0.6, 0.8}}, // z front

    {{0.0f, 0.5 * ratio, 0.0f}, {0.0, 0.9, 0.9, 0.8}},   // top
    {{0.5f, 0.0, 0.0f}, {0.0, 0.9, 0.9, 0.8}},    // x right
    {{0.0f, 0, -0.5f}, {0.0, 0.9, 0.9, 0.8}}, // z back

    {{0.0f, 0.5 * ratio, 0.0f}, {0.9, 0.6, 0, 1.0}},   // top
    {{0.0f, 0, -0.5f}, {0.9, 0.6, 0, 1.0}}, // z back
    {{-0.5f, 0.0, 0.0f}, {0.9, 0.6, 0, 1.0}},    // x left

    {{0.0f, 0.5 * ratio, 0.0f}, {0, 0, 1.0, 0}},   // top
    {{0.0f, 0, 0.5f}, {0, 0, 1.0, 0}}, // z front
    {{0.5f, 0.0, 0.0f}, {0, 0, 1.0, 0}},    // x right
};
*/

/* draw corns with triangles fan
static const sceneVertex vertices[] = {
    {{0.0f, 0.5 * ratio, 0.0f}, {0.6, 0, 0.6, 0.8}},   // top
    {{-0.5f, 0.0, 0.0f}, {0.6, 0, 0.6, 0.8}},    // x left
    {{0.0f, 0, 0.5f}, {0.6, 0, 0.6, 0.8}}, // z front
    {{0.5f, 0.0, 0.0f}, {0, 0, 1.0, 0}},    // x right
    {{0.0f, 0, -0.5f}, {0.0, 0.9, 0.9, 0.8}}, // z back
    {{-0.5f, 0.0, 0.0f}, {0.9, 0.6, 0, 1.0}},    // x left
};
*/

// draw on YZ
//static const sceneVertex vertices[] = {
//    {{0.0f, 0.746 * ratio, 0.0f}, {0.6, 0, 0.6, 0.8}},   // top
//    {{0.0f, 0, -0.346f}, {0.6, 0.6, 0, 1.0}},    // left
//    {{0.0f, 0, 0.346f}, {0.0, 0.6, 0.6, 0.8}}, // right
//    {{0.0f, -0.746 * ratio, 0.0f}, {0.77, 0.44, 0.77, 1.0}},    // bottom
//};

// draw line array
//static const sceneVertex line[] = {
//    {{0.0f, 0.746 * ratio, 0.0f}},
//    {{0.0f, -0.746 * ratio, 0.0f}}
//};

//static const sceneVertex vertices[] = {
//    {{0.0f, 0.4, 0.0f}},
//    {{0.0f, -0.2, -0.346f}},
//    {{0.0f, -0.2, 0.346f}},
//};

//static const GLfloat vertices[] = {
//    0.0f, 0.8f, 0.0f,
//    -1.0, -0.8f, 0.0f,
//    1.0f, -0.8f, 0.0f,
//    0.0f, 0.5f, 0.0f,
//    -0.5, -0.5f, 0.0f,
//    0.5f, -0.5f, 0.0f,
//};

//static GLfloat vertices[] = {
//    0.0f,  0.5f,  0, 1, 0, 0,
//   -0.5f, -0.5f,  0, 0, 1, 0,
//    0.5f, -0.5f,  0, 0, 0, 1,
//};

@interface TextureViewController () {
    GLuint program;
    GLKMatrix4 transformMatrix;
    GLuint vbo;
    GLuint vao;
    GLfloat changeValue;
}

@end


@implementation TextureViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupEAGLContext];

    [self setupProgram];
    [self generateVBO];

    transformMatrix = GLKMatrix4Identity;
    [self generateVAO];

    /* get max vertex attribute for device
        int attributeCount;
        glGetIntegerv(GL_MAX_VERTEX_ATTRIBS, &attributeCount);
        NSLog(@"count: %d", attributeCount);
    */

    int maxViewPort;
    glGetIntegerv(GL_MAX_VIEWPORT_DIMS, &maxViewPort);
    NSLog(@"max view port: %d", maxViewPort);

}

- (void)setupProgram {
    [ShaderLoader loadProgram:&program vertexFile: @"vertex.glsl" fragmentFile: @"frag.glsl"];
}

- (void)setupEAGLContext {
    // set up current EAGLContex
    GLKView *view = (GLKView *)self.view;
    view.context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];

    self.preferredFramesPerSecond = 10;
    [EAGLContext setCurrentContext:view.context];
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
    glClearColor(0.6f, 0.6f, 0.7f, 1.0f);
    glEnable(GL_CULL_FACE);
    glEnable(GL_DEPTH_TEST);

    glCullFace(GL_BACK);

    /* set uniform paragram for shader
        int vertexColor = glGetUniformLocation(program, "color");
        glUseProgram(program);
        glUniform4f(vertexColor, 0.4, 0.6, 0.4, 1.0);
    */

    glUseProgram(program);
    glBindVertexArrayOES(vao);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    GLuint transformUniformLocation = glGetUniformLocation(program, "transform");
    glUniformMatrix4fv(transformUniformLocation, 1, 0, transformMatrix.m);

//    GLuint indexBuffer;
//    glGenBuffers(1, &indexBuffer);
//    glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, indexBuffer);
//    glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(indices), indices, GL_STATIC_DRAW);

    /* set attributes, render without VAO
        glVertexAttribPointer(0, 3, GL_FLOAT, GL_FALSE, 0, 0);
        glEnableVertexAttribArray(0);
        glDrawArrays(GL_TRIANGLES, 0, 6); // draw
        glDrawArrays(GL_LINE_LOOP, 0, 6);

        // draw single line
    //    GLuint lineBuffer;
    //    glGenBuffers(2, &lineBuffer);
    //    glBindBuffer(GL_ARRAY_BUFFER, lineBuffer);
    //    glBufferData(GL_ARRAY_BUFFER, sizeof(line), line, GL_STATIC_DRAW);
    //    glDrawArrays(GL_LINES, 0, 2);
    */
}

- (void)generateVBO {
    glGenBuffers(1, &vbo);
    glBindBuffer(GL_ARRAY_BUFFER, vbo);
//    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
    glBufferData(GL_ARRAY_BUFFER, sizeof(trapezoid), trapezoid, GL_STATIC_DRAW);
}

- (void)generateVAO {
    glGenVertexArraysOES(1, &vao);
    glBindVertexArrayOES(vao); // bind vao

    glBindBuffer(GL_ARRAY_BUFFER, vbo); // set buffer

    // set vertex attributes
    GLuint positionAttribLocation = glGetAttribLocation(program, "position");
    glEnableVertexAttribArray(positionAttribLocation);

    GLuint colorAttribLocation = glGetAttribLocation(program, "color");
    glEnableVertexAttribArray(colorAttribLocation);

    glVertexAttribPointer(positionAttribLocation, 3, GL_FLOAT, GL_FALSE, sizeof(sceneVertex), NULL + offsetof(sceneVertex, positionCoords));
    glVertexAttribPointer(colorAttribLocation, 4, GL_FLOAT, GL_FALSE, sizeof(sceneVertex), NULL + offsetof(sceneVertex, color));

    glBindVertexArrayOES(0);
}

- (void)update {
    NSTimeInterval deltaTime = self.timeSinceLastUpdate;
    changeValue += deltaTime;
//    GLfloat elValue = sinf(changeValue);
//    NSLog(@"elvalue: %f", elValue);
//    GLfloat elValue = (GLfloat)changeValue;

//    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(elValue, elValue, 0.0);
//    transformMatrix = translateMatrix;
//    GLKMatrix4 rotateMatrixX = GLKMatrix4MakeRotation(elValue, 1.0, 1.0, 1.0);
//
//    GLKMatrix4 zRotateMatrix = GLKMatrix4Make(cos(elValue),-sin(elValue), 0.0, 0.0,
//                                              sin(elValue), cos(elValue), 0.0, 0.0,
//                                              0.0,           0.0,         1.0, 0.0,
//                                              0.0,           0.0,         0.0, 1.0);
//    transformMatrix = zRotateMatrix;
//    GLKMatrix4 lookAt = GLKMatrix4MakeLookAt(0, 0, 0, 0, 0, -3, 0, 0, elValue);
//    transformMatrix = lookAt;
//    GLKMatrix4 zRotate = GLKMatrix4MakeZRotation(elValue);
//    GLKMatrix4 rotateMatrix = GLKMatrix4MakeRotation(elValue , 0.0, 1.0, 0.0);
//    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, -2.0); // move the object behind the camera
//    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), ratio, 0.1, 20.0);
//    GLKMatrix4 pMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), ratio, 0.1, 20.0);
//    transformMatrix = GLKMatrix4Multiply(lookAt, zRotate);
//    transformMatrix = GLKMatrix4Identity;
//    transformMatrix = GLKMatrix4Multiply(pMatrix, transformMatrix);
//    transformMatrix = GLKMatrix4Multiply(translateMatrix, rotateMatrix);
//    transformMatrix = GLKMatrix4Multiply(perspectiveMatrix, transformMatrix);
//    transformMatrix = GLKMatrix4Multiply(perspectiveMatrix, translateMatrix);
    //  X rotate
//    transformMatrix = GLKMatrix4Make(1.0, 0.0,           0.0,          0.0,
//                                     0.0, cos(elValue), -sin(elValue), 0.0,
//                                     0.0, sin(elValue),  cos(elValue), 0.0,
//                                     0.0, 0.0,           0.0,          1.0);

    // Y rotate
//    transformMatrix = GLKMatrix4Make(cos(elValue),0.0, sin(elValue), 0.0,
//                                     0.0,         1.0, 0.0,          0.0,
//                                    -sin(elValue),0.0, cos(elValue), 0.0,
//                                     0.0,         0.0, 0.0,          1.0);
    transformMatrix = GLKMatrix4MakeRotation(changeValue, 0, 1, 0);
//    transformMatrix = GLKMatrix4MakeRotation(elValue, 1, 0, 0);

//    transformMatrix = GLKMatrix4Multiply(zRotateMatrix, pMatrix);

//    transformMatrix = rotateMatrix;
//    GLKMatrix4 scaleMatrix = GLKMatrix4MakeScale(elValue, elValue, elValue);
//    transformMatrix = scaleMatrix;

//    transformMatrix = GLKMatrix4RotateZ(GLKMatrix4Identity, 0.3);

//    transformMatrix = GLKMatrix4Multiply(scaleMatrix, zRotateMatrix);
}

@end
