//
//  SimpleiPhoneAppAppDelegate.m
//  SimpleiPhoneApp
//
//  Created by Zach Holt on 4/30/10.
//  Copyright ProxyObjects 2010. All rights reserved.
//

#import "SimpleiPhoneAppAppDelegate.h"
#import "SimpleiPhoneAppViewController.h"

#ifdef BROMINET_ENABLED
#import "BrominetInitializer.h"
// #import Your App Delegate Category Here
#endif

@implementation SimpleiPhoneAppAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	
#ifdef BROMINET_ENABLED
	[BrominetInitializer initializeBrominet];
	[self performSelector:@selector( httpServer )];
#endif
}

- (void)dealloc {
#ifdef BROMINET_ENABLED
	[self performSelector:@selector( setHttpServer: ) withObject:nil];
	[MyHTTPConnection setSharedObserver:nil];
#endif

    [viewController release];
    [window release];
    [super dealloc];
}


@end
