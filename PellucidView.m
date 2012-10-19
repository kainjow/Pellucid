//
//  PellucidView.m
//  Pellucid
//
//  Created by Kevin Wojniak on 12/27/09.
//  Copyright (c) 2009, 2012 Kevin Wojniak. All rights reserved.
//

#import "PellucidView.h"


@implementation PellucidView

+ (BOOL)performGammaFade
{
	return NO;
}

- (id)initWithFrame:(NSRect)frame isPreview:(BOOL)isPreview
{
    self =[super initWithFrame:frame isPreview:isPreview];
	if (self != nil) {
		[self setAnimationTimeInterval:0.1];
    }
	return self;
}

- (void)finalize
{
	if (color != NULL) {
		CGColorRelease(color);
    }
	[super finalize];
}

- (void)animateOneFrame
{
	[self setNeedsDisplay:YES];
}

- (void)drawRect:(NSRect)rect
{
	// get an image representing the screen. if the "require password" option
	// is enabled in System Preferences > Security, there is a black window shown
	// along with the password window from the process loginwindow. we don't want
	// these in the screenshots, so we get every on-screen window from every process
	// except loginwindow.
	CGImageRef screen = NULL;	
	CFArrayRef allWindowIDs = CGWindowListCreate(kCGWindowListOptionOnScreenBelowWindow, [[self window] windowNumber]);
	if (allWindowIDs != NULL) {
		CFMutableArrayRef windowIDs = CFArrayCreateMutable(NULL, 0, NULL);
		CFArrayRef windowDescs = CGWindowListCreateDescriptionFromArray(allWindowIDs);
        if (windowDescs != NULL) {
            for (CFIndex idx=0; idx<CFArrayGetCount(windowDescs); idx++) {
                CFDictionaryRef dict = CFArrayGetValueAtIndex(windowDescs, idx);
                CFStringRef ownerName = CFDictionaryGetValue(dict, kCGWindowOwnerName);
                if (CFStringCompare(ownerName, CFSTR("loginwindow"), 0) != kCFCompareEqualTo) {
                    CFArrayAppendValue(windowIDs, CFArrayGetValueAtIndex(allWindowIDs, idx));
                }
            }
            CFRelease(windowDescs);
        }
		CFRelease(allWindowIDs);
		screen = CGWindowListCreateImageFromArray(CGRectInfinite, windowIDs, kCGWindowImageDefault);
		CFRelease(windowIDs);
	}
	
	if (screen == NULL) {
		return;
    }
	
	// draw the image
	CGContextRef ctx = (CGContextRef)[[NSGraphicsContext currentContext] graphicsPort];
	CGRect bounds = NSRectToCGRect([self bounds]);
	CGContextDrawImage(ctx, bounds, screen);
	CGImageRelease(screen);
	
	// draw a transparent black
	if (color == NULL) {
		color = CGColorCreateGenericRGB(0.0, 0.0, 0.0, 0.5);
    }
	CGContextSetFillColorWithColor(ctx, color);
	CGContextFillRect(ctx, bounds);
}

@end
