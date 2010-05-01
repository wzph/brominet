//
//  SimpleiPhoneAppAppDelegate.h
//  SimpleiPhoneApp
//
//  Created by Zach Holt on 4/30/10.
//  Copyright ProxyObjects 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SimpleiPhoneAppViewController;

@interface SimpleiPhoneAppAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SimpleiPhoneAppViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SimpleiPhoneAppViewController *viewController;

@end

