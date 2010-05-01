//
//  BrominetInitializer.m
//  SimpleiPhoneApp
//
//  Created by Zach Holt on 4/30/10.
//  Copyright 2010 ProxyObjects. All rights reserved.
//

#import "BrominetInitializer.h"
#import "HTTPServer.h"
#import <objc/runtime.h>

static char httpServerKey;

#if TARGET_IPHONE_SIMULATOR
// http://stackoverflow.com/questions/1916130/objc-setassociatedobject-unavailable-in-iphone-simulator
#include <dlfcn.h>
void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy) {
    ((void (*)(id, void *, id, objc_AssociationPolicy)) dlsym(RTLD_NEXT, "objc_setAssociatedObject")) (object, key, value, policy);
}
id objc_getAssociatedObject(id object, void *key) {
    return ((id (*)(id, void *)) dlsym(RTLD_NEXT, "objc_getAssociatedObject"))(object, key);
}
void objc_removeAssociatedObjects(id object) {
    ((void (*)(id)) dlsym(RTLD_NEXT, "objc_removeAssociatedObjects"))(object);
}
#endif


HTTPServer *httpServerGetterImplementation( id self, SEL cmd ) {
	if ( !self ) {
		return nil;
	}

	if ( ![self isKindOfClass:[[[UIApplication sharedApplication] delegate] class]] ) {
		NSLog( @"self is not a %@ class", NSStringFromClass( [[[UIApplication sharedApplication] delegate] class] ) );
		return nil;
	}

	HTTPServer *theServer = objc_getAssociatedObject( self, &httpServerKey );
	NSLog( @"The server: %@", theServer );
	if ( !theServer ) {
		NSString *root = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
		theServer = [HTTPServer new];
		[theServer setName:@"the iPhone"];
		[theServer setType:@"_http._tcp."];
		[theServer setConnectionClass:[MyHTTPConnection class]];
		[theServer setDocumentRoot:[NSURL fileURLWithPath:root]];
		[theServer setPort:50000];
		NSLog( @"Creating the server: %@", theServer );
		
		ScriptRunner *runner = [[[ScriptRunner alloc] init] autorelease];
		[MyHTTPConnection setSharedObserver:runner];
		
		NSError *error;
		if( ![theServer start:&error] ) {
			NSLog(@"Error starting HTTP Server: %@", error);
		}

		objc_setAssociatedObject( self, &httpServerKey, theServer, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
	}
	return theServer;
}

void httpServerSetterImplementation( id self, SEL cmd ) {
	if ( !self ) {
		return;
	}
	
	if ( ![self isKindOfClass:[[[UIApplication sharedApplication] delegate] class]] ) {
		NSLog( @"self is not a %@ class", NSStringFromClass( [[[UIApplication sharedApplication] delegate] class] ) );
		return;
	}
	
	objc_setAssociatedObject( self, &httpServerKey, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC );
}


@implementation BrominetInitializer

+(void)initializeBrominet {
	// Listen for incoming instructions coming from the GUI tests.
	httpServerKey = *"httpServerKey";

	Class delegateClass = [[[UIApplication sharedApplication] delegate] class];
	class_addMethod( delegateClass, @selector( httpServer ), ( IMP )httpServerGetterImplementation, "@@:" );
	class_addMethod( delegateClass, @selector( setHttpServer: ), ( IMP )httpServerSetterImplementation, "@@:@" );
}


@end
