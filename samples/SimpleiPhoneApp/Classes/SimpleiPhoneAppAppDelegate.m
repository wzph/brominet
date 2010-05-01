//
//  SimpleiPhoneAppAppDelegate.m
//  SimpleiPhoneApp
//
//  Created by Zach Holt on 4/30/10.
//  Copyright ProxyObjects 2010. All rights reserved.
//

#import "SimpleiPhoneAppAppDelegate.h"
#import "SimpleiPhoneAppViewController.h"

@implementation SimpleiPhoneAppAppDelegate

@synthesize window;
@synthesize viewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
