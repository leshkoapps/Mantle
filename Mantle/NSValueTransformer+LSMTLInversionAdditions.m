//
//  NSValueTransformer+LSMTLInversionAdditions.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2013-05-18.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "NSValueTransformer+LSMTLInversionAdditions.h"
#import "LSMTLTransformerErrorHandling.h"
#import "LSMTLValueTransformer.h"

@implementation NSValueTransformer (LSMTLInversionAdditions)

- (NSValueTransformer *)mtl_invertedTransformer {
	NSParameterAssert(self.class.allowsReverseTransformation);

	if ([self conformsToProtocol:@protocol(LSMTLTransformerErrorHandling)]) {
		NSParameterAssert([self respondsToSelector:@selector(reverseTransformedValue:success:error:)]);

		id<LSMTLTransformerErrorHandling> errorHandlingSelf = (id)self;

		return [LSMTLValueTransformer transformerUsingForwardBlock:^(id value, BOOL *success, NSError **error) {
			return [errorHandlingSelf reverseTransformedValue:value success:success error:error];
		} reverseBlock:^(id value, BOOL *success, NSError **error) {
			return [errorHandlingSelf transformedValue:value success:success error:error];
		}];
	} else {
		return [LSMTLValueTransformer transformerUsingForwardBlock:^(id value, BOOL *success, NSError **error) {
			return [self reverseTransformedValue:value];
		} reverseBlock:^(id value, BOOL *success, NSError **error) {
			return [self transformedValue:value];
		}];
	}
}

@end
