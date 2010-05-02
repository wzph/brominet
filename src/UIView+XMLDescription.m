//
//  UIView+XMLDescription.m
//  SelfTesting
//
//  Created by Matt Gallagher on 9/10/08.
//  Copyright 2008 Matt Gallagher. All rights reserved.
//

#import "UIView+XMLDescription.h"
#import "NSObject+ClassName.h"
#import <objc/runtime.h>

#ifndef NAMEOF(obj)
#define NAMEOF(obj)     object_getClassName(obj)
#endif

@implementation UIView (XMLDescription)

// If you want to override something in
// a UIView subclass category, override this,
// and return an array composed of [UIView gettersForXML]
// and whatever custom getters you want to add.
+(NSArray *)gettersForXML {
	return [NSArray arrayWithObjects:
			@"alpha",
			@"autoresizingMask",
			@"autoresizesSubviews",
			@"bounds",
			@"backgroundColor",
			@"center",
			@"clearsContextBeforeDrawing",
			@"clipsToBounds",
			@"contentMode",
			@"contentStretch",
			@"currentTitle",
			@"frame",
			@"isExclusiveTouch",
			@"isHidden",
			@"isKeyWindow",
			@"isMultipleTouchEnabled",
			@"isOpaque",
			@"isOn",
			@"subviews",
			@"tag",
			@"text",
			@"title",
			@"transform",
	nil];
}

- (NSString *) xmlDescriptionWithStringPadding:(NSString *)padding {
	NSMutableString *resultingXML = [NSMutableString stringWithFormat:@"\n%@<%s>", padding, NAMEOF(self)];
	[resultingXML appendString:[self xmlAttributesWithPadding:padding]];
	[resultingXML appendFormat:@"\n%@</%s>", padding, NAMEOF(self)];
	return resultingXML;
}

- (NSMutableString *) xmlAttributesWithPadding:(NSString *)padding {
	NSMutableString *attributes = [NSMutableString stringWithFormat:@"\n%@\t<address>%lu</address>", padding, (NSUInteger)self];

	for ( NSString *getterName in [[self class] gettersForXML] ) {
		SEL getterSelector = NSSelectorFromString( getterName );
		if ( ![self respondsToSelector:getterSelector] ) { continue; }

		
		Method theMethod = class_getInstanceMethod( [self class], getterSelector );
		char *returnType = method_copyReturnType( theMethod );

		NSString *formatString = nil;
		if ( returnType ) {
			switch ( returnType[0] ) {
				case '@':
					[attributes appendFormat:@"\n%@\t<%@>", padding, getterName];

					id theValue = [self performSelector:getterSelector];
					if ( [theValue isKindOfClass:[NSArray class]] ) {
						for ( id thing in (NSArray *)theValue ) {
							if ( [thing respondsToSelector:@selector( xmlDescriptionWithStringPadding: )] ) {
								[attributes appendString:[thing xmlDescriptionWithStringPadding:[NSString stringWithFormat:@"%@\t\t", padding]]];
							}
							else {
								[attributes appendFormat:@"\n%@\t\t<%@><![CDATA[%@]]></%@>", padding, NAMEOF( thing ), [thing description], NAMEOF( thing )];
							}
						}
					}
					else {
						// Default to an id's description
						[attributes appendFormat:@"\n%@\t\t<![CDATA[%@]]>", padding, [theValue description]];
					}
					[attributes appendFormat:@"\n%@\t</%@>", padding, getterName];
					break;
				case 'i':
				case 'c':
					formatString = [NSString stringWithFormat:@"%d", [self performSelector:getterSelector]];
					break;
				case 'I':
					formatString = [NSString stringWithFormat:@"%u", [self performSelector:getterSelector]];
					break;
				case 'd': {
					double (*getter)(id, SEL);
					getter = (double (*)(id, SEL))[self methodForSelector:getterSelector];
					double theDouble = getter( self, getterSelector );
					
					formatString = [NSString stringWithFormat:@"%.6f", theDouble];
					break;
				}
				case 'f': {
					float (*getter)(id, SEL);
					getter = (float (*)(id, SEL))[self methodForSelector:getterSelector];
					float theFloat = getter( self, getterSelector );
					
					formatString = [NSString stringWithFormat:@"%.6f", theFloat];
					break;
				}
				case '{': {
					[attributes appendFormat:@"\n%@\t<%@>", padding, getterName];
					if ( strnstr( returnType , "{CGRect", 7 ) ) {
						CGRect (*getter)(id, SEL);
						getter = (CGRect (*)(id, SEL))[self methodForSelector:getterSelector];
						CGRect theRect = getter( self, getterSelector );

						[attributes appendFormat:@"\n%@\t\t<x>%.6f</x>", padding, theRect.origin.x];
						[attributes appendFormat:@"\n%@\t\t<y>%.6f</y>", padding, theRect.origin.y];
						[attributes appendFormat:@"\n%@\t\t<width>%.6f</width>", padding, theRect.size.width];
						[attributes appendFormat:@"\n%@\t\t<height>%.6f</height>", padding, theRect.size.height];
					}
					else if ( strnstr( returnType , "{CGPoint", 8 ) ) {
						CGPoint (*getter)(id, SEL);
						getter = (CGPoint (*)(id, SEL))[self methodForSelector:getterSelector];
						CGPoint thePoint = getter( self, getterSelector );
						
						[attributes appendFormat:@"\n%@\t\t<x>%.6f</x>", padding, thePoint.x];
						[attributes appendFormat:@"\n%@\t\t<y>%.6f</y>", padding, thePoint.y];
					}
					else if ( strnstr( returnType , "{CGAffineTransform", 18 ) ) {
						CGAffineTransform (*getter)(id, SEL);
						getter = (CGAffineTransform (*)(id, SEL))[self methodForSelector:getterSelector];
						CGAffineTransform theTransform = getter( self, getterSelector );
						
						[attributes appendFormat:@"\n%@\t\t<a>%.6f</b>", padding, theTransform.a];
						[attributes appendFormat:@"\n%@\t\t<b>%.6f</b>", padding, theTransform.b];
						[attributes appendFormat:@"\n%@\t\t<c>%.6f</c>", padding, theTransform.c];
						[attributes appendFormat:@"\n%@\t\t<d>%.6f</d>", padding, theTransform.d];
						[attributes appendFormat:@"\n%@\t\t<tx>%.6f</tx>", padding, theTransform.tx];
						[attributes appendFormat:@"\n%@\t\t<ty>%.6f</ty>", padding, theTransform.ty];
					}
					else {
						[attributes appendFormat:@"\n%@\t\t<error>Unknown struct : %s</error>", padding, returnType];
					}
					[attributes appendFormat:@"\n%@\t</%@>", padding, getterName];
					break;
				}
				default:
					[attributes appendFormat:@"\n%@\t<%@ error=\"Unknown return type : %s\"/>", padding, getterName, returnType];
					break;
			}

			if ( formatString ) {
				[attributes appendFormat:@"\n%@\t<%@>%@</%@>",
				 padding,
				 getterName,
				 formatString,
				 getterName];
			}
		}
		else {
			[attributes appendFormat:@"\n%@\t<%@ error=\"Unknown return type.\"/>", padding, getterName];
		}

		free( returnType );
	}

	return attributes;
}

@end

@implementation UITableViewCell (XMLDescription)

+(NSArray *)gettersForXML {
	NSMutableArray *getters = [NSMutableArray arrayWithArray:[UIView gettersForXML]];
	[getters addObject:@"accessoryType"];
	return getters;
}

@end
