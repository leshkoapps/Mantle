//
//  LSMTLTestJSONAdapter.m
//  Mantle
//
//  Created by Robert Böhnke on 03/04/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import "LSMTLTestJSONAdapter.h"

@implementation LSMTLTestJSONAdapter

- (NSSet *)serializablePropertyKeys:(NSSet *)propertyKeys forModel:(id<LSMTLJSONSerializing>)model {
	NSMutableSet *copy = [propertyKeys mutableCopy];

	[copy minusSet:self.ignoredPropertyKeys];

	return copy;
}

- (NSDictionary *)JSONDictionaryFromModel:(id<LSMTLJSONSerializing>)model error:(NSError **)error {
	NSDictionary *dictionary = [super JSONDictionaryFromModel:model error:error];
	return [dictionary mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"test": @YES
	}];
}

@end
