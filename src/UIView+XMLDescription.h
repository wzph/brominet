//
//  UIView+XMLDescription.h
//  SelfTesting
//
//  Created by Matt Gallagher on 9/10/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (XMLDescription) 

- (NSMutableString *) xmlAttributesWithPadding:(NSString *)padding;
- (NSString *) xmlDescriptionWithStringPadding:(NSString *)padding;
+(NSArray *)gettersForXML;

@end