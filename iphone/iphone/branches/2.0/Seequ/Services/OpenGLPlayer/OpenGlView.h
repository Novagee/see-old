/*
 *
 *  Created by Grigori Jlavyan on 01/16/12.
 *  Copyright 2012 BeInteractive. All rights reserved.
 *
 */


#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#import <Foundation/Foundation.h>
#import <GLKit/GLKit.h>



typedef struct {
    float Position[3];
    float TexCoord[2]; // New
} Vertex;

@interface OpenGlView : GLKView {
    
    GLuint _indexBuffer;
    
    GLuint _vertexBuffer;
    GLuint _positionSlot;
    GLuint _depthRenderBuffer;
    GLuint _texCoordSlot;
    
    // position coodinate
    GLuint _program;
    // texture
    GLuint textures[3];
    
    BOOL isPrepared;
    
    CADisplayLink* displayLink;
    
    // Retina Defect
    CGFloat scaleRetina;
    
    GLuint _colorRenderBuffer;
    GLuint _programBlank;
    GLuint _positionSlotBlank;
    GLuint _texCoordSlotBlank;
    
    CGFloat _texstureWidth;
    CGFloat _texstureHeight;
//    CGFloat _screenWidth;
//    CGFloat _screenHeight;
    
    CGFloat rateVideo;
    CGFloat rateScreen;
    CGFloat rateMain;
    
    CGSize currentSize;
    
}


- (void) renderImage:(void*)buffer rect:(CGRect)rect;
- (CGRect) calculateAndCreateRectCriterionFit:(CGFloat)_width height:(CGFloat)_height texstureWidth:(CGFloat)texstureWidth texstureHeight:(CGFloat)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange ;
- (CGRect) calculateAndCreateRectCriterionIn:(CGFloat)_width height:(CGFloat)_height texstureWidth:(GLuint)texstureWidth texstureHeight:(GLuint)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange ;

- (CGRect) calculateAndCreateRectFitByHeight:(CGFloat)_width height:(CGFloat)_height texstureWidth:(CGFloat)texstureWidth texstureHeight:(CGFloat)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange ;
- (CGRect) calculateAndCreateRectFitByWidth:(CGFloat)_width height:(CGFloat)_height texstureWidth:(CGFloat)texstureWidth texstureHeight:(CGFloat)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange ;

-(void)restart;

@end