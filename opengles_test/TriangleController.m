//
//  ViewController.m
//  opengles_test
//
//  Created by liuzhe on 2019/10/25.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "TriangleController.h"

static const float ratio = 414.0/896.0;

/*
     生成: glGenBuffers()
     绑定缓存数据: glBindBuffer()
     缓存数据:glBufferData()
     启用:glEnableVertexAttribArray()
     设置指针:glVertexAttribPointer()
     绘图:glDrawArrays()
     删除:glDeleteBuffers()
 */

typedef struct {
    GLKVector3 potionCoords;
}sceneVertex;
//
//static const sceneVertex vertices[] = {
//    {{0.0f, 0.8f, 0.0f}},
//    {{-1.0, -0.8f, 0.0f}},
//    {{1.0f, -0.8f, 0.0f}},
//};

static const sceneVertex fanVertices[] = {
    {{0.0f, 0.0f, 0.0f}},
    {{0.0, 0.5f, 0.0f}},
    {{0.4, 0.5f, 0.0f}},
    {{0.5f, 0.75f, 0.0f}},
    {{0.8f, 0.25f, 0.0f}},
    {{0.6f, -0.25f, 0.0f}},
};

/*
 use GLKTextureLoader to generate texture from image
 */

typedef struct {
    GLKVector3 positionCoord;
    GLKVector2 texture;
} textureVertex;

static const textureVertex imageVertex[] = {
    {{-1, 1, 0}, {0, 1}},
    {{-1, -1, 0.6}, {0, 0}},
    {{1, 1, 0}, {1, 1}},
    {{1, -1, 0.6}, {1, 0}}
};


@interface TriangleController () {
    GLuint vertexBufferId;
    GLKMatrix4 transformMatrix;
}

@property (nonatomic, strong) GLKView *baseGLView;
@property (nonatomic, strong) GLKBaseEffect *basicEffect;
@property (nonatomic, strong) GLKEffectPropertyTransform *project;

@end

@implementation TriangleController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupGLKView];
    [self setupGLEffect];
    [self generateVertexBuffer];
}

- (void)viewDidAppear:(BOOL)animated {
    [self.baseGLView display];
}

- (void)generateVertexBuffer {
    glGenBuffers(1, &vertexBufferId);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBufferId); // bind bufferId for buffer objects
    //    glBufferData(GL_ARRAY_BUFFER, sizeof(vertices), vertices, GL_STATIC_DRAW);
//        glBufferData(GL_ARRAY_BUFFER, sizeof(fanVertices), fanVertices, GL_STATIC_DRAW);

    glBufferData(GL_ARRAY_BUFFER, sizeof(imageVertex), imageVertex, GL_STATIC_DRAW);
}

- (void)setupGLKView {
    GLKView *glkView = [[GLKView alloc] init];
    glkView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.width);
    glkView.center = self.view.center;
    [self.view addSubview: glkView];

    glkView.context = [[EAGLContext alloc] initWithAPI: kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext: glkView.context];

    glkView.delegate = self;
    self.baseGLView = glkView;
}

- (void)setupGLEffect {
    // draw triangles
//    self.basicEffect = [[GLKBaseEffect alloc] init];
//    self.basicEffect.useConstantColor = GL_TRUE;
//    self.basicEffect.constantColor = GLKVector4Make(0.6f, 1.0f, 1.0f, 1.0f);
//
//    glClearColor(0.6f, 0.6f, 0.7f, 1.0f);

    // render image texture
    NSString *imagePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"res/bricks.jpeg"];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    NSDictionary *options = @{GLKTextureLoaderOriginBottomLeft : @(YES)};
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:[image CGImage]
                                                               options:options
                                                                 error:NULL];

    self.basicEffect = [[GLKBaseEffect alloc] init];
    self.basicEffect.texture2d0.name = textureInfo.name;
    self.basicEffect.texture2d0.target = textureInfo.target;
    self.basicEffect.transform.projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), ratio, 0.1, 20.0);
    self.basicEffect.transform.modelviewMatrix = GLKMatrix4MakeTranslation(0, 0, -3.0);
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [self.basicEffect prepareToDraw];

    //Clear Frame Buffer
    glClear(GL_COLOR_BUFFER_BIT);

    // set attributes
//    glEnableVertexAttribArray(GLKVertexAttribPosition);
//    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(sceneVertex), NULL);

//    GLKMatrix4 translateMatrix = GLKMatrix4MakeTranslation(0, 0, -2.0); // move the object behind the camera
//    float ratio = self.view.bounds.size.width / self.view.bounds.size.height;
//    GLKMatrix4 perspectiveMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(90), ratio, 0.1, 20.0);

    // texture attributes
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, sizeof(textureVertex), NULL + offsetof(textureVertex, positionCoord));
    glEnableVertexAttribArray(GLKVertexAttribTexCoord0);
    glVertexAttribPointer(GLKVertexAttribTexCoord0, 2, GL_FLOAT, GL_FALSE, sizeof(textureVertex), NULL + offsetof(textureVertex, texture));

    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
}




@end
