//
//  GLView.m
//
//  Created by Andreas Areschoug on 4/6/13.
//  Copyright (c) 2013 Andreas Areschoug. All rights reserved.
//


#import "GLView.h"
#import <OpenGLES/EAGLDrawable.h>
#import <QuartzCore/QuartzCore.h>

@interface GLView(){
}
@end

@implementation GLView

#pragma mark - Initialization and teardown

// Override the class method to return the OpenGL layer, as opposed to the normal CALayer
+ (Class) layerClass  {
	return [CAEAGLLayer class];
}

+ (EAGLContext *)sharedContext
{
    static  EAGLContext *sharedInstance = nil ;
    static  dispatch_once_t onceToken;
    dispatch_once (& onceToken, ^ {
        sharedInstance = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    });
    return sharedInstance;
}


- (id)initWithFrame:(CGRect)frame  {
    if ((self = [super initWithFrame:frame])){

		CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
		
		eaglLayer.opaque = YES;
		eaglLayer.drawableProperties = @{kEAGLDrawablePropertyRetainedBacking: @NO,
                                         kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
		_context = [GLView sharedContext];
		
		if (!_context || ![EAGLContext setCurrentContext:_context] || ![self createFramebuffers]) {
            return nil;
		}
    }
    return self;
}
- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    [EAGLContext setCurrentContext:_context];
}
- (void)dealloc
{
    [self destroyFramebuffer];
    
    if ([EAGLContext currentContext] == _context)
    {
        [EAGLContext setCurrentContext:nil];
    }
}
#pragma mark - OpenGL drawing

- (BOOL)createFramebuffers {	
	glEnable(GL_TEXTURE_2D);
	glDisable(GL_DEPTH_TEST);

	// Onscreen framebuffer object
	glGenFramebuffers(1, &_viewFramebuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, _viewFramebuffer);
	
	glGenRenderbuffers(1, &_viewRenderbuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderbuffer);
	
	[_context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer*)self.layer];
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_backingWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_backingHeight);
	DLog(@"Backing width: %d, height: %d", _backingWidth, _backingHeight);
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _viewRenderbuffer);
	
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE)  {
		DLog(@"Failure with framebuffer generation");
		return NO;
	}
	
	return YES;
}

- (void)destroyFramebuffer {
	if (_viewFramebuffer) {
		glDeleteFramebuffers(1, &_viewFramebuffer);
		_viewFramebuffer = 0;
	}
	
	if (_viewRenderbuffer) {
		glDeleteRenderbuffers(1, &_viewRenderbuffer);
		_viewRenderbuffer = 0;
	}
}

- (void)setDisplayFramebuffer {
    if (_context) {
        if (!_viewFramebuffer)
            [self createFramebuffers];
        
        glBindFramebuffer(GL_FRAMEBUFFER, _viewFramebuffer);
        
        glViewport(self.frame.origin.x, self.frame.origin.y, _backingWidth, _backingHeight);
    }
    
}

- (BOOL)presentFramebuffer {
    
    BOOL success = NO;
    
    if (_context) {
        glBindRenderbuffer(GL_RENDERBUFFER, _viewRenderbuffer);
        success = [_context presentRenderbuffer:GL_RENDERBUFFER];
    }
    
    return success;
}


@end
