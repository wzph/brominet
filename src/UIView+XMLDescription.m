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

+(NSArray *)gettersForXML {
	return [NSArray arrayWithObjects:
	@"tag",
	@"frame",
	@"bounds",
	@"center",
	@"transform",
	@"subviews",
	@"autoresizesSubviews",
	@"autoresizingMask",
	@"contentMode",
	@"contentStretch",
	@"clipsToBounds",
	@"backgroundColor",
	@"alpha",
	@"isOpaque",
	@"clearsContextBeforeDrawing",
	@"isHidden",
	@"isMultipleTouchEnabled",
	@"isExclusiveTouch",
	nil];
}

- (NSMutableString *) xmlAttributesWithPadding:(NSString *)padding {
	NSMutableString *attributes = [NSMutableString stringWithFormat:@"\n%@\t<address>%lu</address>", padding, (NSUInteger)self];

	for ( NSString *getterName in [[self class] gettersForXML] ) {
		Method theMethod = class_getInstanceMethod( [self class], NSSelectorFromString( getterName ) );
		char *returnType = method_copyReturnType( theMethod );

		NSString *formatString = nil;
		if ( returnType ) {
			switch ( returnType[0] ) {
				case 'i':
				case 'c':
					formatString = [NSString stringWithFormat:@"%d", [self performSelector:NSSelectorFromString( getterName )]];
					break;
				case 'd': {
					continue;
					double theDouble;
					objc_msgSend_fpret( (void*)&theDouble, (id)self, NSSelectorFromString( getterName ) );
					formatString = [NSString stringWithFormat:@"%.6f", theDouble];
					break;
				}
				case 'f': {
					continue;
					float theFloat;
					NSLog( @"About to hit %@", getterName );
					objc_msgSend_fpret( (void*)&theFloat, (id)self, NSSelectorFromString( getterName ) );
					formatString = [NSString stringWithFormat:@"%.6f", theFloat];
					break;
				}
				case '{': {
					[attributes appendFormat:@"\n%@\t<%@>", padding, getterName];
					if ( strnstr( returnType , "{CGRect", 7 ) ) {
						CGRect (*getter)(id, SEL);
						
						getter = (CGRect (*)(id, SEL))[self methodForSelector:NSSelectorFromString( getterName )];
						CGRect theRect = getter( self, NSSelectorFromString( getterName ) );
// //#if TARGET_IPHONE_SIMULATOR
////						CGRect theRect = (CGRect)objc_msgSend( (id)self, NSSelectorFromString( getterName ) );
////#else
//			
//						CGRect theRect = (*(CGRect(*)(void*, void*, ...)) objc_msgSend_stret)( (void*)&theRect, (id)self, NSSelectorFromString( getterName ) );
////#endif
////						structInvocation = [NSInvocation invocationWithMethodSignature:[self methodSignatureForSelector:NSSelectorFromString( getterName )]];
////						[structInvocation setSelector:NSSelectorFromString( getterName )];
////						[structInvocation invokeWithTarget:self];
////
////						
////						
////						NSUInteger length = [[structInvocation methodSignature] methodReturnLength];
////						void *buffer = (void *)malloc(length);
////						[structInvocation getReturnValue:buffer];
////						CGRect theRect = (CGRect)buffer;
////
					
						
						[attributes appendFormat:@"\n%@\t\t<x>%.6f</x>", padding, theRect.origin.x];
						[attributes appendFormat:@"\n%@\t\t<y>%.6f</y>", padding, theRect.origin.y];
						[attributes appendFormat:@"\n%@\t\t<width>%.6f</width>", padding, theRect.size.width];
						[attributes appendFormat:@"\n%@\t\t<height>%.6f</height>", padding, theRect.size.height];
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

			if ( [getterName isEqualToString:@"alpha"] ) {
				CGFloat theAlpha = [self alpha];
				NSLog( @"theAlpha = %.6f", theAlpha );
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

- (NSString *) xmlDescriptionWithStringPadding:(NSString *)padding {
	NSMutableString *resultingXML = [NSMutableString stringWithFormat:@"\n%@<%s>", padding, NAMEOF(self)];
	[resultingXML appendString:[self xmlAttributesWithPadding:padding]];
	
	//TODO: delegate those to subclasses
	if ([self respondsToSelector:@selector(text)])
	{
		[resultingXML appendFormat:@"\n%@\t<text><![CDATA[%@]]></text>", padding, [self performSelector:@selector(text)]];
	}
	if ([self respondsToSelector:@selector(title)])
	{
		[resultingXML appendFormat:@"\n%@\t<title><![CDATA[%@]]></title>", padding, [self performSelector:@selector(title)]];
	}
	if ([self respondsToSelector:@selector(currentTitle)])
	{
		[resultingXML appendFormat:@"\n%@\t<currentTitle><![CDATA[%@]]></currentTitle>", padding, [self performSelector:@selector(currentTitle)]];
	}
	if ([self respondsToSelector:@selector(isKeyWindow)])
	{
		if([self performSelector:@selector(isKeyWindow)]) {
			[resultingXML appendFormat:@"\n%@\t<keyWindow>YES</keyWindow>", padding];			
		}
		else {
			[resultingXML appendFormat:@"\n%@\t<keyWindow>NO</keyWindow>", padding];			
		}
	}
	if ([self respondsToSelector:@selector(isOn)])
	{
		if(((UISwitch *)self).on) {
			[resultingXML appendFormat:@"\n%@\t<on>YES</on>", padding];			
		}
		else {
			[resultingXML appendFormat:@"\n%@\t<on>NO</on>", padding];
		}
	}
	
//	[resultingXML appendFormat:@"\n%@\t<frame>", padding];
//	[resultingXML appendFormat:@"\n%@\t\t<x>%f</x>", padding, self.frame.origin.x];
//	[resultingXML appendFormat:@"\n%@\t\t<y>%f</y>", padding, self.frame.origin.y];
//	[resultingXML appendFormat:@"\n%@\t\t<width>%f</width>", padding, self.frame.size.width];
//	[resultingXML appendFormat:@"\n%@\t\t<height>%f</height>", padding, self.frame.size.height];
//	[resultingXML appendFormat:@"\n%@\t</frame>", padding];
	if(self.subviews.count > 0) {
		[resultingXML appendFormat:@"\n%@\t<subviews>", padding];
		for (UIView *subview in [self subviews]) {
			[resultingXML appendString:[subview xmlDescriptionWithStringPadding:[NSString stringWithFormat:@"%@\t\t", padding]]];
		}
		[resultingXML appendFormat:@"\n%@\t</subviews>", padding];
	}
	else {
		[resultingXML appendFormat:@"\n%@\t<subviews />", padding];
	}
	[resultingXML appendFormat:@"\n%@</%s>", padding, NAMEOF(self)];
	return resultingXML;
}


@end

@implementation UITableViewCell (XMLDescription)

- (NSMutableString *) xmlAttributesWithPadding:(NSString *) padding {
	NSMutableString *attributes = [super xmlAttributesWithPadding:padding];
	[attributes appendFormat:@"\n%@\t<accessoryType>%d</accessoryType>", padding, [self accessoryType]];
	return attributes;
}

@end
