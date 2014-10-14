//
//  DisplayImageView.m
//  CameraStation
//
//  Created by Peter Lee on 14/9/13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

//#define kVideoWidth  640
//#define kVideoHeight 480

#import "DisplayImageView.h"
#import "YUVFrame.h"

//static void mat4f_LoadOrtho(float left, float right, float bottom, float top, float near, float far, float* mout)
//{
//	float r_l = right - left;
//	float t_b = top - bottom;
//	float f_n = far - near;
//	float tx = - (right + left) / (right - left);
//	float ty = - (top + bottom) / (top - bottom);
//	float tz = - (far + near) / (far - near);
//    
//	mout[0] = 2.0f / r_l;
//	mout[1] = 0.0f;
//	mout[2] = 0.0f;
//	mout[3] = 0.0f;
//	
//	mout[4] = 0.0f;
//	mout[5] = 2.0f / t_b;
//	mout[6] = 0.0f;
//	mout[7] = 0.0f;
//	
//	mout[8] = 0.0f;
//	mout[9] = 0.0f;
//	mout[10] = -2.0f / f_n;
//	mout[11] = 0.0f;
//	
//	mout[12] = tx;
//	mout[13] = ty;
//	mout[14] = tz;
//	mout[15] = 1.0f;
//}

static const GLfloat squareVertices[] = {
    -1.0f, -1.0f,
    1.0f, -1.0f,
    -1.0f,  1.0f,
    1.0f,  1.0f,
};

static const GLfloat textureVertices[] = {
    0.0f, 1.0f,
    1.0f, 1.0f,
    0.0f, 0.0f,
    1.0f, 0.0f,
};
static const GLfloat modelviewProj[16] = {
    1.0, 0.0,
    0.0, 0.0,
    0.0, 1.0,
    0.0, 0.0,
    0.0, 0.0,
    -1.0, 0.0,
    0.0, 0.0,
    0.0, 1.0
};
// Shaders.
typedef enum {
    PASSTHROUGH_SHADER,
    TEST_SHADER,
    BLUR_SHADER,
    LOTR_SHADER,
} Shader;

// Uniform index.
enum {
    UNIFORM_Y,
    UNIFORM_U,
    UNIFORM_V,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_TEXTUREPOSITON,
    NUM_ATTRIBUTES
};
@interface DisplayImageView()
{
//    GLubyte _textureData[kVideoWidth * kVideoHeight * 4];
    GLuint _videoFrameTextures[3];
    GLint  _uniformMatrix;
}
@property(nonatomic,assign) Shader currentShader;
@property(nonatomic,assign) GLuint testProgram;

@property(nonatomic,strong) GLView *glView;

@end
@implementation DisplayImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self setUserInteractionEnabled:YES];
        [self setMultipleTouchEnabled:YES];
        
        _currentShader = TEST_SHADER;
        
        _glView = [[GLView alloc] initWithFrame:self.bounds];
        [self addSubview:_glView];

        [_glView setBackgroundColor:[UIColor whiteColor]];
        
        [self loadShaders:@"YUVShader" forProgram:&_testProgram];
        
        UITapGestureRecognizer *oneFingerOneTaps =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(oneFingerOneTap:)];
        
        [oneFingerOneTaps setNumberOfTapsRequired:1];
        [oneFingerOneTaps setNumberOfTouchesRequired:1];
        
        [_glView addGestureRecognizer:oneFingerOneTaps];
    }
    return self;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [_glView setFrame:self.bounds];
}

#pragma mark - OpenGL ES 2.0 rendering methods

- (void)drawFrame {
    
	// Use shader program.
    
    [_glView setDisplayFramebuffer];
    glUseProgram(_testProgram);
    
    if (_videoFrameTextures[0] == 0)
        return;
    
    for (int i = 0; i < 3; ++i) {
        glActiveTexture(GL_TEXTURE0 + i);
        glBindTexture(GL_TEXTURE_2D, _videoFrameTextures[i]);
        glUniform1i(uniforms[i], i);
    }
    
	// Update attribute values.
//    mat4f_LoadOrtho(-1.0f, 1.0f, -1.0f, 1.0f, -1.0f, 1.0f, modelviewProj);
    
    glUniformMatrix4fv(_uniformMatrix, 1, GL_FALSE, modelviewProj);
    
	glVertexAttribPointer(ATTRIB_VERTEX, 2, GL_FLOAT, 0, 0, squareVertices);
	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, 0, 0, textureVertices);
	glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
        
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    [_glView presentFramebuffer];
}

#pragma mark - OpenGL ES 2.0 setup methods

- (BOOL)loadShaders:(NSString *)shadersName forProgram:(GLuint *)programPointer {
    
    GLuint vertexShader;
    GLuint fragShader;
    
    // Create shader program.
    *programPointer = glCreateProgram();
    
    // Create and compile vertex shader.
    NSString *vertShaderPathname = [[NSBundle mainBundle] pathForResource:shadersName ofType:@"vsh"];
    if (![self compileShader:&vertexShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
        DLog(@"Failed to compile vertex shader");
        return NO;
    }
    
    // Create and compile fragment shader.
    NSString *fragShaderPathname = [[NSBundle mainBundle] pathForResource:shadersName ofType:@"fsh"];
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
        DLog(@"Failed to compile fragment shader");
        return NO;
    }
    
    // Attach vertex shader to program.
    glAttachShader(*programPointer, vertexShader);
    
    // Attach fragment shader to program.
    glAttachShader(*programPointer, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(*programPointer, ATTRIB_VERTEX, "position");
    glBindAttribLocation(*programPointer, ATTRIB_TEXTUREPOSITON, "texcoord");

    
    // Link program.
    if (![self linkProgram:*programPointer]) {
        DLog(@"Failed to link program: %d", *programPointer);
        
        if (vertexShader) {
            glDeleteShader(vertexShader);
            vertexShader = 0;
        }
        
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        
        if (*programPointer) {
            glDeleteProgram(*programPointer);
            *programPointer = 0;
        }
        
        return NO;
    }
    
    // Get uniform locations.
    
    _uniformMatrix = glGetUniformLocation(*programPointer, "modelViewProjectionMatrix");
    uniforms[UNIFORM_Y] = glGetUniformLocation(*programPointer, "s_texture_y");
    uniforms[UNIFORM_U] = glGetUniformLocation(*programPointer, "s_texture_u");
    uniforms[UNIFORM_V] = glGetUniformLocation(*programPointer, "s_texture_v");
    
    // Release vertex and fragment shaders.
    if (vertexShader) {
        glDeleteShader(vertexShader);
	}
    
    if (fragShader) {
        glDeleteShader(fragShader);
	}
    
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file {
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        DLog(@"Failed to load vertex shader");
        return YES;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, nil);
    glCompileShader(*shader);
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    
    return YES;
}

- (BOOL)linkProgram:(GLuint)program{
    GLint status;
    
    glLinkProgram(program);
    
    glGetProgramiv(program, GL_LINK_STATUS, &status);
    if (status == 0) return NO;
    
    return YES;
}

- (BOOL)validateProgram:(GLuint)program {
    GLint logLength;
    GLint status;
    
    glValidateProgram(program);
    glGetProgramiv(program, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(program, logLength, &logLength, log);
        DLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(program, GL_VALIDATE_STATUS, &status);
    if (status == 0) return NO;
    
    return YES;
}


#pragma mark - Image processing

- (void)processFrameBuffer:(id)frame{
    
    YUVFrame *yuvFrame = (YUVFrame *)frame;
    
//    if (yuvFrame.luma.length != yuvFrame.width * yuvFrame.height ||
//        yuvFrame.chromaB.length != (yuvFrame.width * yuvFrame.height) * 0.25 ||
//        yuvFrame.chromaR.length != (yuvFrame.width * yuvFrame.height) * 0.25) {
//        return;
//    }
    
    assert(yuvFrame.luma.length == yuvFrame.width * yuvFrame.height);
    assert(yuvFrame.chromaB.length == (yuvFrame.width * yuvFrame.height) * 0.25);
    assert(yuvFrame.chromaR.length == (yuvFrame.width * yuvFrame.height) * 0.25);
    
    const NSUInteger frameWidth = yuvFrame.width;
    const NSUInteger frameHeight = yuvFrame.height;
    
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    
    if (0 == _videoFrameTextures[0])
        glGenTextures(3, _videoFrameTextures);
    
    const UInt8 *pixels[3] = { yuvFrame.luma.bytes, yuvFrame.chromaB.bytes, yuvFrame.chromaR.bytes };
    const NSUInteger widths[3]  = { frameWidth, frameWidth * 0.5f, frameWidth * 0.5f};
    const NSUInteger heights[3] = { frameHeight, frameHeight * 0.5f, frameHeight * 0.5f};
    
    for (int i = 0; i < 3; ++i) {
        
        glBindTexture(GL_TEXTURE_2D, _videoFrameTextures[i]);
        
        glTexImage2D(GL_TEXTURE_2D,
                     0,
                     GL_LUMINANCE,
                     widths[i],
                     heights[i],
                     0,
                     GL_LUMINANCE,
                     GL_UNSIGNED_BYTE,
                     pixels[i]);
        
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
        glTexParameterf(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    }
	[self drawFrame];
}


#pragma mark - Tap Gesture

- (void)oneFingerOneTap:(id)sender
{
    [self.delegate displayImageViewTaped:self];
}
@end
