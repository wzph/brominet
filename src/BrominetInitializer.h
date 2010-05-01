//
//  BrominetInitializer.h
//  SimpleiPhoneApp
//
//  Created by Zach Holt on 4/30/10.
//  Copyright 2010 ProxyObjects. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ScriptRunner.h"
#import "MyHTTPConnection.h"
#import "HTTPServer.h"
#import <objc/runtime.h>

#if TARGET_IPHONE_SIMULATOR
// http://stackoverflow.com/questions/1916130/objc-setassociatedobject-unavailable-in-iphone-simulator
enum {
    OBJC_ASSOCIATION_ASSIGN = 0,
    OBJC_ASSOCIATION_RETAIN_NONATOMIC = 1,
    OBJC_ASSOCIATION_COPY_NONATOMIC = 3,
    OBJC_ASSOCIATION_RETAIN = 01401,
    OBJC_ASSOCIATION_COPY = 01403
};
typedef uintptr_t objc_AssociationPolicy;

void objc_setAssociatedObject(id object, void *key, id value, objc_AssociationPolicy policy);
id objc_getAssociatedObject(id object, void *key);
void objc_removeAssociatedObjects(id object);
#endif


@interface BrominetInitializer : NSObject {

}
+(void)initializeBrominet;

@end
