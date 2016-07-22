//
//  NSDictionary+LSMTLMappingAdditions.m
//  Mantle
//
//  Created by Robert Böhnke on 10/31/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "LSMTLModel.h"

#import "NSDictionary+LSMTLMappingAdditions.h"

@implementation NSDictionary (LSMTLMappingAdditions)

+ (NSDictionary *)mtl_identityPropertyMapWithModel:(Class)modelClass {
	NSCParameterAssert([modelClass conformsToProtocol:@protocol(LSMTLModel)]);

	NSArray *propertyKeys = [modelClass propertyKeys].allObjects;

	return [NSDictionary dictionaryWithObjects:propertyKeys forKeys:propertyKeys];
}

@end
