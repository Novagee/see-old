/*
 *
 *  Created by Grigori Jlavyan on 01/16/12.
 *  Copyright 2012 BeInteractive. All rights reserved.
 *
 */


#import "OpenGlView.h"


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


const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
};


+ (Class)layerClass {
    return [CAEAGLLayer class];
}

- (void)setupLayer {
    _eaglLayer = (CAEAGLLayer*) self.layer;
    _eaglLayer.opaque = YES;
}

- (void)setupContext {   
    EAGLRenderingAPI api = kEAGLRenderingAPIOpenGLES2;
    _context = [[EAGLContext alloc] initWithAPI:api];
    if (!_context) {
//        NSLog(@"Failed to initialize OpenGLES 2.0 context");
        exit(1);
    }
    
    if (![EAGLContext setCurrentContext:_context]) {
//        NSLog(@"Failed to set current OpenGL context");
        exit(1);
    }
}

- (void)setupRenderBuffer {
    GL_OPERATION(glGenRenderbuffers(1, &colorRenderBuffer));
    GL_OPERATION(glBindRenderbuffer(GL_RENDERBUFFER, colorRenderBuffer));        
    [_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:_eaglLayer];    
}

- (void)setupDepthBuffer {
    GL_OPERATION(glGenRenderbuffers(1, &_depthRenderBuffer));
    GL_OPERATION(glBindRenderbuffer(GL_RENDERBUFFER, _depthRenderBuffer));
    GL_OPERATION(glRenderbufferStorage(GL_RENDERBUFFER, GL_DEPTH_COMPONENT16, self.frame.size.width, self.frame.size.height));    
}

- (void)setupFrameBuffer {    
    GLuint framebuffer;
    GL_OPERATION(glGenFramebuffers(1, &framebuffer));
    GL_OPERATION(glBindFramebuffer(GL_FRAMEBUFFER, framebuffer));   
    GL_OPERATION(glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderBuffer));
    GL_OPERATION(glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, _depthRenderBuffer));
}

- (GLuint)compileShader:(NSString*)shaderName withType:(GLenum)shaderType {
    
    // 1
    NSString* shaderPath = [[NSBundle mainBundle] pathForResource:shaderName ofType:@"glsl"];
    NSError* error;
    NSString* shaderString = [NSString stringWithContentsOfFile:shaderPath encoding:NSUTF8StringEncoding error:&error];
    if (!shaderString) {
//        NSLog(@"Error loading shader: %@", error.localizedDescription);
        exit(1);
    }
    
    // 2
    GLuint shaderHandle = glCreateShader(shaderType);    
    
    // 3
    const char * shaderStringUTF8 = [shaderString UTF8String];    
    int shaderStringLength = [shaderString length];
    glShaderSource(shaderHandle, 1, &shaderStringUTF8, &shaderStringLength);
    
    // 4
    glCompileShader(shaderHandle);
    
    // 5
    GLint compileSuccess;
    glGetShaderiv(shaderHandle, GL_COMPILE_STATUS, &compileSuccess);
    if (compileSuccess == GL_FALSE) {
        GLchar messages[256];
        GL_OPERATION(glGetShaderInfoLog(shaderHandle, sizeof(messages), 0, &messages[0]));
//        NSString *messageString = [NSString stringWithUTF8String:messages];
//        NSLog(@"%@", messageString);
        exit(1);
    }
    
    return shaderHandle;
}

- (void)compileShaders {
    
    // 1
    GLuint vertShader = [self compileShader:@"SimpleVertex" withType:GL_VERTEX_SHADER];
    GLuint fragShader = [self compileShader:@"SimpleFragment" withType:GL_FRAGMENT_SHADER];
    
    // 2
    GLuint programHandle = glCreateProgram();
    GL_OPERATION(glAttachShader(programHandle, vertShader));
    GL_OPERATION(glAttachShader(programHandle, fragShader));
    GL_OPERATION(glLinkProgram(programHandle));
    
    // 3
    GLint linkSuccess;
    glGetProgramiv(programHandle, GL_LINK_STATUS, &linkSuccess);
    if (linkSuccess == GL_FALSE) {
        GLchar messages[256];
        glGetProgramInfoLog(programHandle, sizeof(messages), 0, &messages[0]);
        NSString *messageString = [NSString stringWithUTF8String:messages];
        NSLog(@"%@", messageString);
        exit(1);
    }
    
    // 4
    glUseProgram(programHandle);
    
    // 5
    _positionSlot = glGetAttribLocation(programHandle, "position");
    glEnableVertexAttribArray(_positionSlot);
    
    _texCoordSlot = glGetAttribLocation(programHandle, "uv");
    glEnableVertexAttribArray(_texCoordSlot);
    
    UNIFORM_TEXTURE_Y = glGetUniformLocation(programHandle, "t_texture_y");
    UNIFORM_TEXTURE_U = glGetUniformLocation(programHandle, "t_texture_u");
    UNIFORM_TEXTURE_V = glGetUniformLocation(programHandle, "t_texture_v");
    
    
}

- (void)setupVBOs {
    
    GL_OPERATION(glGenBuffers(1, &_vertexBuffer));
    GL_OPERATION(glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer));
    GL_OPERATION(glBufferData(GL_ARRAY_BUFFER, sizeof(Vertices), Vertices, GL_STATIC_DRAW));
    
    GL_OPERATION(glGenBuffers(1, &_indexBuffer));
    GL_OPERATION(glBindBuffer(GL_ELEMENT_ARRAY_BUFFER, _indexBuffer));
    GL_OPERATION( glBufferData(GL_ELEMENT_ARRAY_BUFFER, sizeof(Indices), Indices, GL_STATIC_DRAW));
    
    GL_OPERATION(glVertexAttribPointer(_positionSlot, 3, GL_FLOAT, GL_FALSE, sizeof(Vertex), 0));
    GL_OPERATION(glVertexAttribPointer(_texCoordSlot, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (GLvoid*) (sizeof(float) * 3)));    
    GL_OPERATION(glViewport(0, 0, self.frame.size.width, self.frame.size.height));
    
}

- (void) render:(CADisplayLink*)sender{
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateBackground){
    GL_OPERATION(glViewport(glV_x, glV_y,glV_w,glV_h));
//    GL_OPERATION(glClearColor(0, 0, 0, 1));
//    GL_OPERATION(glClear(GL_COLOR_BUFFER_BIT));
    //GL_OPERATION(glViewport(glV_x, glV_y, glV_w, glV_h));
    
        glDrawElements(GL_TRIANGLES,6, GL_UNSIGNED_BYTE, 0);
        [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
}

SEL drawSelector;
BOOL resourcesLoaded;

- (void)destroy {

}
- (void)metaLevelDraw {
   [self performSelector:drawSelector];
}


- (void)startDisplayLink {
    drawSelector = @selector(rander);
    CADisplayLink* displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(metaLevelDraw:)];
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

-(void) stopDisplayLink{
    drawSelector = @selector(destroy);
}
- (unsigned int)align_on_power_of_2:(unsigned int)value{
	int i;
	/* browse all power of 2 value, and find the one just >= value */
	for(i=0; i<32; i++) {
		unsigned int c = 1 << i;
		if (value <= c)
			return c;
	}
	return 0;
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
    
    allocatedTexturesW = w;
    allocatedTexturesH = h;
}

- (void)setupTexture:(void *)context width:(uint)width_ height:(uint)height_ {
    uint width_text=width_;
    uint height_text=height_;
    Byte *Y = (uint8_t*)context;
    Byte *U = Y+(width_text*height_text);
    Byte *V = Y+(width_text*height_text)+(width_text*height_text)/4;
    uframeWidth = width_text >> 1;
    uframeHeight = height_text >> 1;
    
    
    /* upload V plane */
	GL_OPERATION(glBindTexture(GL_TEXTURE_2D, textures[2]));
	GL_OPERATION(glTexSubImage2D(GL_TEXTURE_2D, 0,
                                 0, 0, uframeWidth, uframeHeight,
                                 GL_LUMINANCE, GL_UNSIGNED_BYTE, V));
	GL_OPERATION(glUniform1i(UNIFORM_TEXTURE_V, 2));
    
    /* upload U plane */
    GL_OPERATION(glBindTexture(GL_TEXTURE_2D, textures[1]));
    GL_OPERATION(glTexSubImage2D(GL_TEXTURE_2D, 0,
                                 0, 0, uframeWidth, uframeHeight,
                                 GL_LUMINANCE, GL_UNSIGNED_BYTE,U));
    GL_OPERATION(glUniform1i(UNIFORM_TEXTURE_U, 1));
//
    /* upload Y plane */
    GL_OPERATION(glBindTexture(GL_TEXTURE_2D, textures[0]));
    GL_OPERATION(glTexSubImage2D(GL_TEXTURE_2D, 0,
                                 0, 0, width_text, height_text,
                                 GL_LUMINANCE, GL_UNSIGNED_BYTE, Y));
    GL_OPERATION(glUniform1i(UNIFORM_TEXTURE_Y, 0));
}

- (void)dealloc
{
    _context = nil;
}

void check_GL_errors(const char* context) {
    int maxIterations = 10;
    GLenum error;
    while (((error = glGetError()) != GL_NO_ERROR) && maxIterations > 0)
    {
        switch(error)
        {
            case GL_INVALID_ENUM:  NSLog(@"[%2d]GL error: '%s' -> GL_INVALID_ENUM\n", maxIterations, context); break;
            case GL_INVALID_VALUE: NSLog(@"[%2d]GL error: '%s' -> GL_INVALID_VALUE\n", maxIterations, context); break;
            case GL_INVALID_OPERATION: NSLog(@"[%2d]GL error: '%s' -> GL_INVALID_OPERATION\n", maxIterations, context); break;
            case GL_OUT_OF_MEMORY: NSLog(@"[%2d]GL error: '%s' -> GL_OUT_OF_MEMORY\n", maxIterations, context); break;
            case GL_INVALID_FRAMEBUFFER_OPERATION: NSLog(@"[%2d]GL error: '%s' -> GL_INVALID_FRAMEBUFFER_OPERATION\n", maxIterations, context); break;
            default:
                NSLog(@"[%2d]GL error: '%s' -> %x\n", maxIterations, context, error);
        }
        maxIterations--;
    }
}
-(void)setSize:(int)width height:(int)height{
    realHeigh = height;
    realWidth = width;
    switch (realWidth){
        case 176:
        {
            widthKayficent = 256.0;
            heightKayficent = 256.0;
        }
         break;
        case 352:
        {
            widthKayficent = 512.0;
            heightKayficent = 512.0;
        }
         break;
        default:
            break;
    }     
}
- (void) renderImage:(void*)fileName Width:(int)width Height:(int)height {
    static BOOL isPrepared = NO;
    //    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"openyuv" ofType:@"yuv"];  
    //    NSData *myData = [NSData dataWithContentsOfFile:filePath];  
    if(!isPrepared){
        [self initParameters];
        // yuvs = (unsigned char *)malloc([myData length]);
        [self setupLayer];        
        [self setupContext];    
        [self setupDepthBuffer];
        [self setupRenderBuffer];        
        [self setupFrameBuffer];     
        [self compileShaders];
        [self updateorintation:4];
        //[self chengeSettings];
        [self setupVBOs];
        [self updatesize:width h:height];
          isPrepared = YES;
        //[self startDisplayLink];
      
    }
    
    [self setupTexture:fileName width:temWidth height:temHeight];
    [self render:NULL];
}

- (void)updatesize:(unsigned int) w h:(unsigned int) h {
    uframeWidth = temWidth >> 1;
    uframeHeight = temHeight >> 1;
   
    SCREAN_WIDTH = 480 ;
    SCREAN_HEIGHT =	320 ;

//    if (w == 352) {
//        TEX_COORD_Height = ((temWidth)/(widthKayficent+1.3));
//        TEX_COORD_Width = ((temHeight)/(heightKayficent+1.3));
//        glV_w =	480;
//        glV_h =	392;
//        glV_x = 0;
//        glV_y = 0;
//    
//    } else {
        TEX_COORD_Height = ((temWidth)/(widthKayficent+1.3));
        TEX_COORD_Width = ((temHeight)/(heightKayficent+1.3));
        glV_w =	w;
        glV_h =	h;
        glV_x = 0;
        glV_y = 0;
//    }
    
    [self updateorintation:4];

    aligned_yuv_w = [self align_on_power_of_2:temWidth];
    aligned_yuv_h = [self align_on_power_of_2:temHeight];
//    if (aligned_yuv_w != allocatedTexturesW ||
//        aligned_yuv_h != allocatedTexturesH) {
        [self allocate_gl_textures:aligned_yuv_w h:aligned_yuv_h];
//    }
}

- (void) initParameters{
//    landskape    
//    WIDTH=realWidth;
//    HEIGHT=video_height;
//    TEX_COORD_Height=((realWidth/2)/(512.0+1.3));
//    TEX_COORD_Width=((realHeight)/(512.0+1.3));
//    SCREAN_WIDTH=			320;
//    SCREAN_HEIGHT=		480;
    temWidth = realWidth;
    temHeight = realHeigh;
    WIDTH=realWidth;
    HEIGHT=realHeigh;
    TEX_COORD_Height=((realWidth)/(widthKayficent+1.3));
    TEX_COORD_Width=((realHeigh)/(heightKayficent+1.3));
    SCREAN_WIDTH=			320 ;
    SCREAN_HEIGHT=			480 ;

}
- (void) chengeSettings{
    aligned_yuv_w = [self align_on_power_of_2:WIDTH];
    aligned_yuv_h = [self align_on_power_of_2:HEIGHT];
    /* check if we need to adjust texture sizes */
    if (aligned_yuv_w != allocatedTexturesW ||
        aligned_yuv_h != allocatedTexturesH) {
        [self allocate_gl_textures:aligned_yuv_w h:aligned_yuv_h];
    }
    uframeWidth = WIDTH >> 1;
    uframeHeight = HEIGHT >> 1;
    
   if ( SCREAN_WIDTH > SCREAN_HEIGHT) {
        ratio = (float)HEIGHT/WIDTH;
        glV_w = SCREAN_WIDTH;
        glV_h = glV_w * ratio;
        glV_x = 0;
        glV_y = (SCREAN_HEIGHT - glV_h) * 0.5f;
    } else {
        ratio = (float)(WIDTH/HEIGHT);
        glV_h = SCREAN_HEIGHT;
        glV_w= SCREAN_HEIGHT*ratio;
        glV_x = (SCREAN_HEIGHT-glV_w)*ratio;
        glV_y =0;
// v1
//        ratio = 1.8;
//        glV_h = SCREAN_WIDTH+15;
//        glV_w= SCREAN_HEIGHT*ratio;
//        glV_x = -SCREAN_HEIGHT/ratio;
//        glV_y =40;        
// v2
//        ratio = 2;
//        glV_h = SCREAN_WIDTH+40;
//        glV_w= SCREAN_HEIGHT*ratio;
//        glV_x = -SCREAN_HEIGHT/ratio;
//        glV_y =65;
    }
}

- (void) updateorintation:(int)position{
    
//    AVCaptureVideoOrientationPortrait           = 1,
//    AVCaptureVideoOrientationPortraitUpsideDown = 2,
//    AVCaptureVideoOrientationLandscapeRight     = 3,
//    AVCaptureVideoOrientationLandscapeLeft      = 4,

    // defoult inicalization
    Vertices[0].Position[0] = -1; Vertices[0].Position[1] = -1; Vertices[0].Position[2] = 0;
    Vertices[1].Position[0] = -1; Vertices[1].Position[1] =  1; Vertices[1].Position[2] = 0;
    Vertices[2].Position[0] =  1; Vertices[2].Position[1] =  1; Vertices[2].Position[2] = 0;
    Vertices[3].Position[0] =  1; Vertices[3].Position[1] = -1; Vertices[3].Position[2] = 0;
    
    switch (4) {
        case 1:{
            Vertices[0].TexCoord[0] = TEX_COORD_Height ;               Vertices[0].TexCoord[1] = 0;
            Vertices[1].TexCoord[0] = TEX_COORD_Height ;               Vertices[1].TexCoord[1] = 0.95;
            Vertices[2].TexCoord[0] = 0;                               Vertices[2].TexCoord[1] = 0.95;
            Vertices[3].TexCoord[0] = 0;                               Vertices[3].TexCoord[1] = 0;       
            break;
        }
        case 2:{
            Vertices[0].TexCoord[0] = TEX_COORD_Height ;               Vertices[0].TexCoord[1] = 0;
            Vertices[1].TexCoord[0] = TEX_COORD_Height ;               Vertices[1].TexCoord[1] = 0.95;
            Vertices[2].TexCoord[0] = 0;                               Vertices[2].TexCoord[1] = 0.95;
            Vertices[3].TexCoord[0] = 0;                               Vertices[3].TexCoord[1] = 0;      
            break;
        }
        case 3:{
            Vertices[1].TexCoord[0] = TEX_COORD_Width-0.1 ;           Vertices[1].TexCoord[1] = 0;
            Vertices[2].TexCoord[0] = TEX_COORD_Width+0.1 ;           Vertices[2].TexCoord[1] = TEX_COORD_Height-0.1;
            Vertices[3].TexCoord[0] = 0;                              Vertices[3].TexCoord[1] = TEX_COORD_Height-0.1;
            Vertices[0].TexCoord[0] = 0;                              Vertices[0].TexCoord[1] = 0;          
            ratio = (float)WIDTH/HEIGHT;
            [self setupVBOs];
            [self chengeSettings];
            break;
        }
        case 4:{
//            Vertices[1].TexCoord[0] = TEX_COORD_Height ;               Vertices[1].TexCoord[1] = 0;
//            Vertices[0].TexCoord[0] = TEX_COORD_Height ;               Vertices[0].TexCoord[1] = TEX_COORD_Width;
//            Vertices[3].TexCoord[0] = 0;                               Vertices[3].TexCoord[1] = TEX_COORD_Width;
//            Vertices[2].TexCoord[0] = 0;                               Vertices[2].TexCoord[1] = 0;           
//            v1
           // if(WIDTH==320 || HEIGHT ==320){
              Vertices[2].TexCoord[0] = TEX_COORD_Height ;                Vertices[2].TexCoord[1] = 0;
              Vertices[3].TexCoord[0] = TEX_COORD_Height ;                Vertices[3].TexCoord[1] = TEX_COORD_Width;
              Vertices[0].TexCoord[0] = 0;                               Vertices[0].TexCoord[1] = TEX_COORD_Width;
              Vertices[1].TexCoord[0] = 0;                               Vertices[1].TexCoord[1] = 0;           
            //}
//            Vertices[2].TexCoord[0] = 1/1.364 ;                        Vertices[2].TexCoord[1] = 0;
//            Vertices[3].TexCoord[0] = 1/1.364 ;                        Vertices[3].TexCoord[1] = 1/1.364;
//            Vertices[0].TexCoord[0] = 0;                               Vertices[0].TexCoord[1] = 1/1.364;
//            Vertices[1].TexCoord[0] = 0;                               Vertices[1].TexCoord[1] = 0;           
            
//            ratio = (float)WIDTH/HEIGHT;
//            [self setupVBOs];
//            [self chengeSettings];
            break;
        }
        default:
            break;
    }

}

@end