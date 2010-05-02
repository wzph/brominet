//
//  SimpleiPhoneAppAppDelegate+Brominet.m
//  SimpleiPhoneApp
//
//  Created by Zach Holt on 5/2/10.
//  Copyright 2010 ProxyObjects. All rights reserved.
//

#import "SimpleiPhoneAppAppDelegate.h"
#import "SimpleiPhoneAppAppDelegate+Brominet.h"


@implementation SimpleiPhoneAppAppDelegate(Brominet)

- (NSString *)terminateApp:(NSDictionary *)ignored {
	exit(0);
	return @"pass"; // This is odd.
}

@end