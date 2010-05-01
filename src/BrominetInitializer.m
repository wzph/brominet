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
#import <objc/runtime.h>
// http://stackoverflow.com/questions/1916130/objc-setassociatedobject-unavailable-in-iphone-simulator

enum {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    OBJC_ASSOCIATION_RETAIN = 01401,
    OBJC_ASSOCIATION_COPY = 01403
};
typedef uintptr_t objc_AssociationPolicy;

@implementation NSObject (OTAssociatedObjectsSimulator)

static CFMutableDictionaryRef theDictionaries = nil;

static void Swizzle(Class c, SEL orig, SEL new) // swizzling by Mike Ash
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if (class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
        class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
        method_exchangeImplementations(origMethod, newMethod);
}

- (NSMutableDictionary *)otAssociatedObjectsDictionary
{
    if (!theDictionaries)
    {
        theDictionaries = CFDictionaryCreateMutable(NULL, 0, NULL, &kCFTypeDictionaryValueCallBacks);
        Swizzle([NSObject class], @selector(dealloc), @selector(otAssociatedObjectSimulatorDealloc));
    }
	
    NSMutableDictionary *dictionary = (id)CFDictionaryGetValue(theDictionaries, self);
    if (!dictionary)
    {
        dictionary = [NSMutableDictionary dictionary];
        CFDictionaryAddValue(theDictionaries, self, dictionary);
    }
	
    return dictionary;
}

- (void)otAssociatedObjectSimulatorDealloc
{
    CFDictionaryRemoveValue(theDictionaries, self);
    [self otAssociatedObjectSimulatorDealloc];
}

@end

void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy)
{
    NSCAssert(policy == OBJC_ASSOCIATION_RETAIN_NONATOMIC, @"Only OBJC_ASSOCIATION_RETAIN_NONATOMIC supported");
	
    [[object otAssociatedObjectsDictionary] setObject:value forKey:[NSValue valueWithPointer:key]];
}

id objc_getAssociatedObject(id object, void *key)
{
    return [[object otAssociatedObjectsDictionary] objectForKey:[NSValue valueWithPointer:key]];
}

void objc_removeAssociatedObjects(id object)
{
    [[object otAssociatedObjectsDictionary] removeAllObjects];
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
