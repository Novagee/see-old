//
//  OpenGLViewHelper.h
//  Protime
//
//  Created by Grigori Jlavyan on 10/24/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OpenGLViewHelper : NSObject
+ (GLuint)compileShaders:(NSString *)vertexShader fragment:(NSString *)fragmentShader;
+ (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
@end
