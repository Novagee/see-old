//
//  NSObject_OpenGlViewResource.h
//  Protime
//
//  Created by Grigori Jlavyan on 10/24/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#ifndef OpenGlViewResource_h
#define OpenGlViewResource_h


// Uniform index.
enum
{
    UNIFORM_MATRIX,
    UNIFORM_TEXTURE_Y,
    UNIFORM_TEXTURE_U,
    UNIFORM_TEXTURE_V,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

static const GLfloat Verticies[] = {
    -1.0f,-1.0f , 0.0f,    0, 1,
    -1.0f, 1.0f , 0.0f,    0, 0,
    1.0f , 1.0f , 0.0f,    1, 0,
    1.0f , -1.0f, 0.0f,    1, 1,
};
//static const GLfloat Verticies[] = {
//    1.0f, 0.0f,
//    1.0f, 0.0f,
//    0.0f , 1.0f,
//    0.0f , 1.0f
//};

static const GLfloat VerticiesBlank[] = {
    -1.0f,-1.0f , 0.0f,    0, 1,
    -1.0f, 1.0f , 0.0f,    0, 0,
    1.0f , 1.0f , 0.0f,    1, 0,
    1.0f , -1.0f, 0.0f,    1, 1,
};





const GLubyte Indices[] = {
    // Front
    0, 1, 2,
    2, 3, 0,
};


// Error
#undef CHECK_GL_ERROR
#ifdef CHECK_GL_ERROR
#define GL_OPERATION(x)	\
(x); \
check_GL_errors(#x);
#else
#define GL_OPERATION(x) \
(x);
#endif

#endif


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
