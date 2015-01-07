/*
 *
 *  Created by Grigori Jlavyan on 01/16/12.
 *  Copyright 2012 BeInteractive. All rights reserved.
 *
 */


#import "OpenGlView.h"
#import "OpenGlViewResource.h"
#import "OpenGLViewHelper.h"

typedef GLubyte type;

@implementation OpenGlView

#undef CHECK_GL_ERROR
#ifdef CHECK_GL_ERROR
#define GL_OPERATION(x)	\
(x); \
check_GL_errors(#x);
#else
#define GL_OPERATION(x) \
(x);
#endif



//unsigned char* yuvs;
//int length;



- (id) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    if (self) {
        isPrepared = NO;
        displayLink = nil;
        scaleRetina=[OpenGlView scaleRetina];
        
       // [self setAutoresizingMask:UIViewAutoresizingNone];
        [self setAutoresizingMask:UIViewContentModeScaleAspectFit];
        rateScreen = 1.0f;
        rateMain = 1.0f;
        rateVideo = 1.0f;
        _texstureWidth = 288;
        _texstureHeight = 352;
    }
    return self;
}

+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    ((CAEAGLLayer*) self.layer).opaque = YES;
    
    ((CAEAGLLayer*) self.layer).drawableProperties = [NSDictionary dictionaryWithObjectsAndKeys:
                                                      [NSNumber numberWithBool:YES],
                                                      kEAGLDrawablePropertyRetainedBacking,
                                                      kEAGLColorFormatRGB565, kEAGLDrawablePropertyColorFormat, nil];
}

- (void)setupContext {
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    
    if (!self.context) {
    }
    
    if (![EAGLContext setCurrentContext:self.context]){
    }
}
-(void)restart{
    [self tearDownGL];
    [self setUP];
}

-(void)setUP
{
    [self setupLayer];
    [self setupContext];
    [self setupDepthBuffer];
    [self setupRenderBuffer];
    [self setupFrameBuffer];
    [self compileShaders];
    
    // Init openGL
    [self setupVBOs];
    // Init Textures
    [self allocate_gl_textures:_texstureWidth h:_texstureHeight];
    
    
}



- (void)setupRenderBuffer {
    GL_OPERATION(glGenRenderbuffers(1, &_colorRenderBuffer));
    GL_OPERATION(glBindRenderbuffer(GL_RENDERBUFFER, _colorRenderBuffer));
    [self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*) self.layer];
}

- (void)setupDepthBuffer {
    GL_OPERATION(glGenRenderbuffers(1, &_depthRenderBuffer));
    GL_OPERATION(glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer));
    GL_OPERATION(glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, 320, 480));
}

- (void)setupFrameBuffer {
    _depthRenderBuffer = 0;
    GLuint framebuffer;
    GL_OPERATION(glGenFramebuffers(1, &framebuffer));
    GL_OPERATION(glBindFramebuffer(GL_FRAMEBUFFER, framebuffer));
    GL_OPERATION(glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorRenderBuffer));
    GL_OPERATION(glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer));
}

- (void)compileShaders {
    
    [self compileBlank];
    [self compileYUVShader];
    
}
-(void)compileYUVShader
{
    _program=[OpenGLViewHelper compileShaders:@"SimpleVertex" fragment:@"SimpleFragment"];
    _positionSlot = glGetAttribLocation(_program, "position");
    glEnableVertexAttribArray(_positionSlot);
    
    _texCoordSlot = glGetAttribLocation(_program, "uv");
    glEnableVertexAttribArray(_texCoordSlot);
    glUseProgram(_program);
    uniforms[UNIFORM_TEXTURE_Y] = glGetUniformLocation(_program, "t_texture_y");
    uniforms[UNIFORM_TEXTURE_U] = glGetUniformLocation(_program, "t_texture_u");
    uniforms[UNIFORM_TEXTURE_V] = glGetUniformLocation(_program, "t_texture_v");
}

-(void)compileBlank
{
    _programBlank=[OpenGLViewHelper compileShaders:@"SimpleVertex" fragment:@"SimpleFragment"];
    _positionSlotBlank = glGetAttribLocation(_programBlank, "position");
    glEnableVertexAttribArray(_positionSlotBlank);
    
    _texCoordSlotBlank = glGetAttribLocation(_programBlank, "uv");
    glEnableVertexAttribArray(_texCoordSlotBlank);
}

- (void)setupVBOs {
    
    GL_OPERATION(glGenBuffers(1, &_vertexBuffer));
    GL_OPERATION(glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer));
    GL_OPERATION(glBufferData(GL_ARRAY_BUFFER, sizeof(Verticies), Verticies, GL_STREAM_DRAW));
    
    GL_OPERATION(glGenBuffers(1, &_indexBuffer));
    GL_OPERATION(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer));
    GL_OPERATION(glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STREAM_DRAW));
    
    GL_OPERATION(glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0));
    GL_OPERATION(glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3)));
    
    //    GL_OPERATION(glVertexAttribPointer(_positionSlotBlank, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0));
    //    GL_OPERATION(glVertexAttribPointer(_texCoordSlotBlank, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3)));
    
    glClearColor(0.5, 0.5, 0.5, 1.0);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
}

- (void) renderFromRect:(CGRect)rect program:(GLuint) program
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        rect=[self recalculateRect:rect];
        
        glViewport(rect.origin.x, rect.origin.y,rect.size.width,rect.size.height);
        
        glDrawElements(GL_TRIANGLES,6, GL_UNSIGNED_BYTE, 0);
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        
        
    }
}



- (void)allocate_gl_textures:(int)w h:(int)h {
	glDeleteTextures(GL_TEXTURE_2D,&textures[0]);
    glDeleteTextures(GL_TEXTURE_2D,&textures[1]);
    glDeleteTextures(GL_TEXTURE_2D,&textures[2]);
    
    GL_OPERATION(glActiveTexture(GL_TEXTURE1));
    GL_OPERATION(glGenBuffers(1, &textures[1]));
    GL_OPERATION(glBindTexture(GL_TEXTURE_2D, textures[1]));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));
    GL_OPERATION(glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, w >> 1, h >> 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0));
    
    GL_OPERATION(glGenBuffers(1, &textures[2]));
    GL_OPERATION(glActiveTexture(GL_TEXTURE2));
    GL_OPERATION(glBindTexture(GL_TEXTURE_2D, textures[2]));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));
    GL_OPERATION(glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, w >> 1, h >> 1, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0));
    
    GL_OPERATION(glGenBuffers(1, &textures[0]));
    GL_OPERATION(glActiveTexture(GL_TEXTURE0));
    GL_OPERATION(glBindTexture(GL_TEXTURE_2D, textures[0]));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE));
    GL_OPERATION(glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE));
    GL_OPERATION(glTexImage2D(GL_TEXTURE_2D, 0, GL_LUMINANCE, w, h, 0, GL_LUMINANCE, GL_UNSIGNED_BYTE, 0));
    
}

- (void)setupTexture:(void *)context width:(uint)width_ height:(uint)height_ {
    uint width_text=width_;
    uint height_text=height_;
    Byte *Y = (uint8_t*)context;
    Byte *U = Y+(width_text*height_text);
    Byte *V = Y+(width_text*height_text)+(width_text*height_text)/4;
    float uframeWidth = width_text >> 1;
    float uframeHeight = height_text >> 1;
    
    //    /* upload V plane */
	GL_OPERATION(glBindTexture(GL_TEXTURE_2D, textures[2]));
	GL_OPERATION(glTexSubImage2D(GL_TEXTURE_2D, 0,
                                 0, 0, uframeWidth, uframeHeight,
                                 GL_LUMINANCE, GL_UNSIGNED_BYTE, V));
	glUniform1i(uniforms[UNIFORM_TEXTURE_V], 2);
    
    /* upload U plane */
    glBindTexture(GL_TEXTURE_2D, textures[1]);
    glTexSubImage2D(GL_TEXTURE_2D, 0,
                    0, 0, uframeWidth, uframeHeight,
                    GL_LUMINANCE, GL_UNSIGNED_BYTE,U);
    glUniform1i(uniforms[UNIFORM_TEXTURE_U], 1);
    //
    /* upload Y plane */
    glBindTexture(GL_TEXTURE_2D, textures[0]);
    glTexSubImage2D(GL_TEXTURE_2D, 0,
                    0, 0, width_text, height_text,
                    GL_LUMINANCE, GL_UNSIGNED_BYTE, Y);
    glUniform1i(uniforms[UNIFORM_TEXTURE_Y], 0);
}

- (void)dealloc
{
    [self tearDownGL];
}

- (void) cleanRect:(CGRect)rect
{
    [self renderFromRect:rect program:_programBlank];
}

- (CGRect) calculateAndCreateRectFitByWidth:(CGFloat)_width height:(CGFloat)_height texstureWidth:(CGFloat)texstureWidth texstureHeight:(CGFloat)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange {
    
    
    BOOL change = NO ;
    
    if(_texstureWidth != texstureWidth || _texstureHeight != texstureHeight || isDisplayStateChange){
        change = YES;
    }
    
    _texstureWidth = texstureWidth;
    _texstureHeight = texstureHeight;
    
    if(change){
        //[self cleanRect:CGRectMake(0, 0, _texstureWidth*rate, _texstureHeight*rate)];
        [self allocate_gl_textures:(GLuint)_texstureWidth h:(GLuint)_texstureHeight];
    }
    currentSize = CGSizeMake(_width, _height);
    CGFloat w = 0;
    CGFloat h = 0;
    CGFloat x = 0 ;
    CGFloat y = 0 ;
    
    if(_width==_height){
        
        // workground now cant calculate dip rate
        CGFloat rateVideo1 =  2.8;
        if(!(rateVideo1>1)){
            rateVideo1 = 1;
        }
        
        
        rateVideo =  _texstureHeight/_texstureWidth < _texstureWidth/_texstureHeight ? _texstureHeight/_texstureWidth : _texstureWidth/_texstureHeight;
        
        
        
        w = _texstureWidth*rateVideo*rateVideo1;
        //w = _texstureWidth*rateVideo*rateVideo1;
        
        rateScreen = _texstureWidth/_width > _texstureHeight/_height ? _texstureWidth/_width  :  _texstureHeight/_height;
        //h = _texstureHeight*rateScreen*rateVideo1;
        h=_texstureHeight*rateScreen*rateVideo*rateScreen*rateVideo1;
        
    }
    else if(_width>_height)
    {
        if(_texstureHeight>_texstureWidth){
            CGFloat rateVideo1 =  2.6;
            if(!(rateVideo1>1)){
                rateVideo1 = 1;
            }
            
            rateVideo =  _texstureHeight/_texstureWidth > _texstureWidth/_texstureHeight ? _texstureHeight/_texstureWidth : _texstureWidth/_texstureHeight;
            rateScreen = _texstureHeight/_width > _texstureHeight/_height ? _texstureHeight/_width  :  _texstureHeight/_height;
            
            w = _texstureHeight*rateScreen*rateVideo1;
            h = _texstureHeight*rateVideo*rateVideo*rateVideo1;
        }else{
            rateVideo =  _texstureHeight/_texstureWidth > _texstureWidth/_texstureHeight ? _texstureHeight/_texstureWidth : _texstureWidth/_texstureHeight;
            rateScreen = _texstureHeight/_width > _texstureHeight/_height ? _texstureHeight/_width  :  _texstureHeight/_height;
            
            w = _texstureHeight;
            h = _texstureHeight*rateVideo*rateVideo*rateScreen;
        }
    }
//    rateVideo = _texstureWidth/_height;
//    
//    w = _width*rateVideo;
//    
//    rateVideo = _texstureHeight/_width;
//    h = _height*rateVideo;
    
    return CGRectMake(x, y, w, h);
}
//- (CGRect) calculateAndCreateRectFitByHeight:(CGFloat)_width height:(CGFloat)_height texstureWidth:(CGFloat)texstureWidth texstureHeight:(CGFloat)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange {
//    
//    BOOL change = NO ;
//    
//    if(_texstureWidth != texstureWidth || _texstureHeight != texstureHeight || isDisplayStateChange){
//        change = YES;
//    }
//    
//    _texstureWidth = texstureWidth;
//    _texstureHeight = texstureHeight;
//    
//    if(change){
//        //[self cleanRect:CGRectMake(0, 0, _texstureWidth*rate, _texstureHeight*rate)];
//        [self allocate_gl_textures:(GLuint)_texstureWidth h:(GLuint)_texstureHeight];
//    }
//    
//    //    CGFloat w ;
//    //    CGFloat h ;
//    //    CGFloat x = 0 ;
//    //    CGFloat y = 0 ;
//    //
//    //    rateVideo =  _texstureHeight/_texstureWidth > _texstureWidth/_texstureHeight ? _texstureHeight/_texstureWidth : _texstureWidth/_texstureHeight;
//    //    rateScreen = _texstureWidth/_width < _texstureHeight/_height ? _texstureWidth/_width  :  _texstureHeight/_height;
//    //
//    //    w = _texstureWidth*rateVideo;
//    //    h = _texstureHeight*rateScreen*(_texstureHeight/_texstureWidth);
//    
//    
//    
//    CGFloat w ;
//    CGFloat h ;
//    CGFloat x = 0 ;
//    CGFloat y = 0 ;
//    
//    if(_width != _height && _width < _texstureWidth){
//        texstureHeight =(_texstureHeight/(_height*(CGFloat)((int)(_texstureHeight/_height)-1)));
//        
//        texstureWidth =(_texstureWidth/(_width*(CGFloat)((int)(_texstureWidth/_width)-1)));
//        
//        
//        rateVideo =  texstureHeight > texstureWidth ? texstureHeight :texstureWidth ;
//        
//        //rateVideo = 1/rateVideo;
//        w = _texstureWidth*rateVideo;
//        h = _texstureHeight*rateVideo;
//    }
//    else{
//        //texstureHeight =(_texstureHeight/(_height*(CGFloat)((int)(_texstureHeight/_height))));
//        
//        //texstureWidth =(_texstureWidth/(_width*(CGFloat)((int)(_texstureWidth/_width)-1)));
//        
//        rateVideo =  _texstureHeight/_texstureWidth > _texstureWidth/_texstureHeight ? _texstureHeight/_texstureWidth : _texstureWidth/_texstureHeight;
//        
//        //rateVideo =  texstureHeight < texstureWidth ? texstureHeight :texstureWidth ;
//        
//        rateScreen = _texstureWidth/_width < _texstureHeight/_height ? _texstureWidth/_width  :  _texstureHeight/_height;
//        
//        w = _texstureWidth*rateVideo;
//        h = _texstureHeight*rateScreen*(_texstureWidth/_texstureHeight);
//    }
//    
//    
//    
//    
//    
//    
//    return CGRectMake(x, y, w, h);
//}

- (CGRect) calculateAndCreateRectFitByHeight:(CGFloat)_width height:(CGFloat)_height texstureWidth:(CGFloat)texstureWidth texstureHeight:(CGFloat)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange {
    
    BOOL change = NO ;
    
    if(_texstureWidth != texstureWidth || _texstureHeight != texstureHeight || isDisplayStateChange){
        change = YES;
    }
    
    _texstureWidth = texstureWidth;
    _texstureHeight = texstureHeight;
    
    if(change){
        //[self cleanRect:CGRectMake(0, 0, _texstureWidth*rate, _texstureHeight*rate)];
        [self allocate_gl_textures:(GLuint)_texstureWidth h:(GLuint)_texstureHeight];
    }
    
//    CGFloat w ;
//    CGFloat h ;
//    CGFloat x = 0 ;
//    CGFloat y = 0 ;
//    
//    rateVideo =  _texstureHeight/_texstureWidth > _texstureWidth/_texstureHeight ? _texstureHeight/_texstureWidth : _texstureWidth/_texstureHeight;
//    rateScreen = _texstureWidth/_width < _texstureHeight/_height ? _texstureWidth/_width  :  _texstureHeight/_height;
//    
//    w = _texstureWidth*rateVideo;
//    h = _texstureHeight*rateScreen*(_texstureHeight/_texstureWidth);
    
currentSize = CGSizeMake(_width, _height);
    
    CGFloat w ;
    CGFloat h ;
    CGFloat x = 0 ;
    CGFloat y = 0 ;
    
//    if(_width != _height && _width < _texstureWidth){
//        texstureHeight =(_texstureHeight/(_height*(CGFloat)((int)(_texstureHeight/_height)-1)));
//        
//        texstureWidth =(_texstureWidth/(_width*(CGFloat)((int)(_texstureWidth/_width)-1)));
//        
//        
//        rateVideo =  texstureHeight > texstureWidth ? texstureHeight :texstureWidth ;
//        
//        //rateVideo = 1/rateVideo;
//        w = _texstureWidth*rateVideo;
//        h = _texstureHeight*rateVideo;
//    }
//    else{
//        //texstureHeight =(_texstureHeight/(_height*(CGFloat)((int)(_texstureHeight/_height))));
//        
//        //texstureWidth =(_texstureWidth/(_width*(CGFloat)((int)(_texstureWidth/_width)-1)));
//        
//        rateVideo =  _texstureHeight/_texstureWidth > _texstureWidth/_texstureHeight ? _texstureHeight/_texstureWidth : _texstureWidth/_texstureHeight;
//        
//        //rateVideo =  texstureHeight < texstureWidth ? texstureHeight :texstureWidth ;
//        
//        rateScreen = _texstureWidth/_width < _texstureHeight/_height ? _texstureWidth/_width  :  _texstureHeight/_height;
//        
//        w = _texstureWidth*rateVideo;
//        h = _texstureHeight*rateScreen*(_texstureWidth/_texstureHeight);
//    }
//    
        if(_width>_height){
            if(_texstureHeight>_texstureWidth){
                rateVideo =  _width/_texstureHeight ;
                rateScreen =  _texstureWidth/_width ;
                w = _texstureWidth*rateScreen;
                h = _texstureHeight*rateVideo;
            }else{
                rateVideo = _texstureWidth/_texstureHeight*_texstureWidth/_texstureHeight*_texstureWidth/_texstureHeight;


                h = _height*rateVideo;
                w = _width;
            }
        }else{
            if(_texstureHeight>_texstureWidth){
//                rateVideo =  _texstureWidth/_height < _height/_texstureWidth ? _texstureWidth/_height : _height/_texstureWidth;
//                rateScreen =  _height/_texstureHeight < _texstureHeight/_height ?  _height/_texstureHeight : _texstureHeight/_height;
//                //int k = _texstureHeight/_height>_texstureWidth/_width ?_texstureHeight/_height: _texstureWidth/_width;
//
////                if(rateScreen<1){
////                    rateScreen+=1;
////                    rateVideo+=1;
////                }
//                
//                w = _texstureWidth*rateScreen;
//                h = _texstureHeight*rateVideo*(_texstureWidth/_texstureHeight);
                
                rateVideo =  _texstureWidth/_height < _height/_texstureWidth ? _texstureWidth/_height : _height/_texstureWidth;
                rateScreen =  _height/_texstureHeight < _texstureHeight/_height ?  _height/_texstureHeight : _texstureHeight/_height;
                
                //int k = _texstureHeight/_height>_texstureWidth/_width ?_texstureHeight/_height: _texstureWidth/_width;
                
                //                if(rateScreen<1){
                //                    rateScreen+=1;
                //                    rateVideo+=1;
                //                }
                
                rateVideo = _texstureHeight/_texstureWidth;
                
                CGFloat rateVideo1 =  _width/_texstureWidth > _height/_texstureWidth ? _width/_texstureWidth : _height/_texstureWidth;
                
                
                if(!(rateVideo1>1)){
                    rateVideo1 =  _texstureWidth/_width > _texstureWidth/_height ? _texstureWidth/_width : _texstureWidth/_height;
                    rateVideo1*=1.4;
                    
                    w = _texstureHeight*rateVideo1;
                    h = _texstureWidth*rateVideo*rateVideo*rateVideo1;
                }else{
                    w = _texstureHeight*rateVideo1;
                    h = _texstureHeight*rateVideo*rateVideo*rateVideo1;
                }
                
            }else{
                CGFloat rateVideo1 =  1.9;
                if(!(rateVideo1>1)){
                    rateVideo1 = 1;
                }

                rateVideo =  _texstureHeight/_height < _height/_texstureHeight ? _texstureHeight/_height : _height/_texstureHeight;
                rateScreen =  _height/_texstureWidth < _texstureWidth/_height ?  _height/_texstureWidth : _texstureWidth/_height;
                rateVideo = _texstureWidth/_texstureHeight;
                if(_texstureHeight<_texstureWidth && _height!=_width){
                    rateVideo1 = 2.4;
                    w = _texstureWidth*rateVideo*rateVideo1;
                    h = _texstureWidth*rateVideo*rateVideo1;
                }else{
                    w = _texstureWidth*rateVideo*rateVideo1;
                    h = _texstureWidth*rateVideo*rateVideo*rateVideo1;
                }
                
//                rateVideo = _texstureWidth/_texstureHeight;
//                
//                
//                w = _texstureWidth*rateVideo;
//                h = _texstureWidth*rateVideo*(_texstureWidth/_texstureHeight);
            }
        }
    
    
    
    
    return CGRectMake(x, y, w, h);
}

- (CGRect) calculateAndCreateRectCriterionIn:(CGFloat)_width height:(CGFloat)_height texstureWidth:(GLuint)texstureWidth texstureHeight:(GLuint)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange {
    
    
    BOOL change = NO ;
    
    if(_texstureWidth != texstureWidth || _texstureHeight != texstureHeight || isDisplayStateChange){
        change = YES;
    }
    
    _texstureWidth = texstureWidth;
    _texstureHeight = texstureHeight;
    
    if(change){
        //[self cleanRect:CGRectMake(0, 0, _texstureWidth*rate, _texstureHeight*rate)];
        [self allocate_gl_textures:_texstureWidth h:_texstureHeight];
    }
    
    CGFloat w = 0;
    CGFloat h = 0;
    CGFloat x = 0 ;
    CGFloat y = 0 ;
    currentSize = CGSizeMake(_width, _height);
    
//    rate = _texstureWidth/_width < _texstureHeight/_height ? _texstureWidth/_width : _texstureHeight/_height;
//    w = (_texstureWidth)*rate;
//    h = (_texstureHeight)*rate;
//
//    return CGRectMake(x, y, w, h);
//    
//    if(_width<_height){
//        if(_texstureWidth < _texstureHeight){
//            rate =  _width/_texstureWidth > _height/_texstureHeight ? _width/_texstureWidth : _height/_texstureHeight;
//            w = _texstureWidth*rate;
//            h = _texstureHeight*rate;
//        }
//        else{
//            rate = _height/_texstureHeight < _width/_texstureWidth ? _height/_texstureHeight : _width/_texstureWidth;
//            rate = 1/rate;
//            
//            w = (_texstureWidth)*rate;
//            h = (_texstureHeight)*rate;
//            
//        }
//    }else{
//        if(_texstureWidth < _texstureHeight){
//            rate = _width/_texstureHeight > _height/_texstureWidth ? _width/_texstureHeight : _height/_texstureWidth;
//            CGFloat rateh = _width/_texstureWidth > _height/_texstureHeight ? _width/_texstureWidth  :  _height/_texstureHeight;
//            
//            rate = 1/rate;
//            rateh = 1/rateh;
//            
//            w = _texstureWidth*rate;
//            h = _texstureHeight*rateh;
//        }
//        else{
//            rate = _width/_texstureHeight < _height/_texstureWidth ? _width/_texstureHeight : _height/_texstureWidth;
//            CGFloat rateh = _width/_texstureWidth > _height/_texstureHeight ? _width/_texstureWidth  :  _height/_texstureHeight;
//            
//            w = _texstureWidth*rate;
//            h = _texstureHeight*(_width/_height)*rateh;
//        }
//    }
//    
    return CGRectMake(x, y, w, h);
}

- (CGRect) calculateAndCreateRectCriterionFit:(CGFloat)_width height:(CGFloat)_height texstureWidth:(CGFloat)texstureWidth texstureHeight:(CGFloat)texstureHeight isDisplayStateChange:(BOOL)isDisplayStateChange {
    
    
    BOOL change = NO ;
    
    if(_texstureWidth != texstureWidth || _texstureHeight != texstureHeight || isDisplayStateChange){
        change = YES;
    }
    
    _texstureWidth = texstureWidth;
    _texstureHeight = texstureHeight;
    
    if(change){
        //[self cleanRect:CGRectMake(0, 0, _texstureWidth*rate, _texstureHeight*rate)];
        [self allocate_gl_textures:(GLuint)(_texstureWidth) h:(GLuint)(_texstureHeight)];
    }
    
    currentSize = CGSizeMake(_width, _height);
    
    CGFloat w = 0;
    CGFloat h = 0;
    CGFloat x = 0 ;
    CGFloat y = 0 ;
    
//    rateVideo =  _texstureHeight/_texstureWidth > _texstureWidth/_texstureHeight ?_texstureHeight/_texstureWidth : _texstureWidth/_texstureHeight;
//    rateVideo =  _width/_texstureWidth > _height/_texstureHeight ? _width/_texstureWidth : _height/_texstureHeight;
//    rateScreen =  _width/_height > _height/_width ? _width/_height : _height/_width;
//    
//    rateMain = rateVideo < rateScreen ? rateVideo : rateScreen;
//    w = _texstureWidth*rateMain;
//    h = _texstureHeight*rateMain;
    
    
    if(_width<_height){
        if(_texstureWidth < _texstureHeight){
            rateVideo =  _width/_texstureWidth > _height/_texstureHeight ? _width/_texstureWidth : _height/_texstureHeight;
            w = _texstureWidth*rateVideo;
            h = _texstureHeight*rateVideo;
        }
        else{
            rateVideo =  _width/_texstureWidth < _height/_texstureHeight ? _width/_texstureWidth : _height/_texstureHeight;
            w = (_texstureWidth)*rateVideo;
            h = (_texstureHeight)*rateVideo;

        }
    }else{
        if(_texstureWidth < _texstureHeight){
            rateVideo = _width/_texstureHeight < _height/_texstureWidth ? _width/_texstureHeight : _height/_texstureWidth;
            CGFloat rateh = _width/_texstureWidth > _height/_texstureHeight ? _width/_texstureWidth  :  _height/_texstureHeight;
            
            w = _texstureWidth*rateVideo;
            h = _texstureHeight*(_width/_height)*(rateh);

            
        }
        else{
            rateVideo = _width/_texstureHeight < _height/_texstureWidth ? _width/_texstureHeight : _height/_texstureWidth;
            CGFloat rateh = _width/_texstureWidth > _height/_texstureHeight ? _width/_texstureWidth  :  _height/_texstureHeight;
            
            w = _texstureWidth*rateVideo;
            h = _texstureHeight*(_width/_height)*rateh;
        }
    }

    
    return CGRectMake(x, y, w, h);
}

- (void) renderImage:(void*)buffer rect:(CGRect)rect
{
    if(!isPrepared)
    {
        [self setUP];
        isPrepared = YES;
    }
    [self setupTexture:buffer width:_texstureWidth height:_texstureHeight];
    [self renderFromRect:rect program:_program];
}

-(CGRect)recalculateRect:(CGRect)rect
{
    
    CGFloat w=scaleRetina*rect.size.width;
    CGFloat h=scaleRetina*rect.size.height;
    
    
    CGFloat x;
    CGFloat y;
    
    // TODO: JSC - Which one of these to use?
    x = -1*(w - CGRectGetWidth(self.bounds)*scaleRetina)/2;
    y = -1*(h - CGRectGetHeight(self.bounds)*scaleRetina)/2;
    
//    x = 0;
//    y = 0;
    
    return CGRectMake(x, y, w, h);
    
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    glDeleteBuffers(1, &_vertexBuffer);
    glDeleteVertexArraysOES(1, &_vertexBuffer);
    
    glDeleteBuffers(1, &_indexBuffer);
    glDeleteVertexArraysOES(1, &_indexBuffer);
    
    if (_program) {
        glDeleteProgram(_program);
        _program = 0;
    }
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    
    self.context=nil;
}

+(float) scaleRetina
{
    return [UIScreen mainScreen].scale  ;
}

@end