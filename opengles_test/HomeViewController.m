//
//  HomeViewController.m
//  opengles_test
//
//  Created by liuzhe on 2019/11/1.
//  Copyright © 2019 LZ. All rights reserved.
//

#import "HomeViewController.h"
#import "TriangleController.h"
#import "TextureViewController.h"
#import "GLSViewController.h"
#import "GLShaderViewController.h"
#import "CubicViewController.h"
#import "CameraViewController.h"
#import "MosaicViewController.h"

@interface HomeViewController ()

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)showGLKitView:(id)sender {
    [self.navigationController pushViewController: [[TriangleController alloc] init] animated:true];
}

- (IBAction)showEAGLView:(id)sender {
    [self.navigationController pushViewController: [[GLSViewController alloc] init] animated:true];
}

- (IBAction)showTextureView:(id)sender {
//    [self.navigationController pushViewController: [[TextureViewController alloc] init] animated:true];
//    [self.navigationController pushViewController: [[GLShaderViewController alloc] init] animated:true];
    [self.navigationController pushViewController:[[MosaicViewController alloc] init] animated: true];
}

- (IBAction)showCubicView:(id)sender {
    [self.navigationController pushViewController: [[CubicViewController alloc] init] animated:true];
}

- (IBAction)showCameraView:(id)sender {
    [self.navigationController pushViewController: [[CameraViewController alloc] init] animated:true];
}


@end
