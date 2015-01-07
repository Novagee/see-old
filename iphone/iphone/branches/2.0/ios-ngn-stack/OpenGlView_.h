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


//#define		imageWidth			352 
//#define		imageHeight			288 
//#define		imageWidth			320
//#define		imageHeight			240 


typedef struct {
    float Position[3];
    float TexCoord[2]; // New
} Vertex;

@interface OpenGlView : UIView {
    
    GLuint _indexBuffer;
    GLuint colorRenderBuffer;
    GLuint  defaultFrameBuffer;
    GLuint _vertexBuffer;    
    GLuint _positionSlot;
    GLuint _depthRenderBuffer;
    GLuint _texCoordSlot;
    unsigned int aligned_yuv_w, aligned_yuv_h;
    
    ////
    //context
    EAGLContext* _context;
    CAEAGLLayer* _eaglLayer;
    // context size
    int allocatedTexturesW, allocatedTexturesH;
    
    unsigned int WIDTH;
    unsigned int HEIGHT;
    double_t TEX_COORD_Height;
    double_t TEX_COORD_Width;
    // real screen size
    double_t SCREAN_WIDTH;			 
    double_t SCREAN_HEIGHT;			 
    // current ratio
    float ratio;
    
    //uniforms
    GLuint UNIFORM_MATRIX;
    GLuint UNIFORM_TEXTURE_Y;
    GLuint UNIFORM_TEXTURE_U;
    GLuint UNIFORM_TEXTURE_V;
    // texture
    GLuint program;
    GLuint textures[3];
    // position coodinate 
    
    float uframeWidth;
    float uframeHeight;
    int glV_x,glV_y,glV_w,glV_h;
    Vertex Vertices[4];
    float uvx , uvy;
    
    uint temWidth ;
    uint temHeight ;
   
    int realWidth;
    int realHeigh;
    
    float widthKayficent;
    float heightKayficent;
}
-(void)setSize:(int)width height:(int)height;
- (void) updatesize:(unsigned int) w h:(unsigned int) h;
- (void) initParameters;
- (void) updateorintation:(int)position;
- (void) chengeSettings;
- (void) render:(CADisplayLink*)sender ;
- (void) renderImage:(void*)fileName Width:(int)width Height:(int)height;
- (void)setupTexture:(void *)context width:(uint)width_ height:(uint)height_;
-(void) stopDisplayLink;
@end