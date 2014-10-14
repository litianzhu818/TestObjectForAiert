//
//  GLView.h
//  Created by Andreas Areschoug on 4/6/13.
//  Copyright (c) 2013 Andreas Areschoug. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface GLView : UIView  {
	/* The pixel dimensions of the backbuffer */
	GLint _backingWidth;
    GLint _backingHeight;
	
	EAGLContext *_context;
	
	/* OpenGL names for the renderbuffer and framebuffers used to render to this view */
	GLuint _viewRenderbuffer;
	GLuint _viewFramebuffer;
}

// OpenGL drawing
- (BOOL)createFramebuffers;
- (void)destroyFramebuffer;
- (void)setDisplayFramebuffer;
- (BOOL)presentFramebuffer;

@end
