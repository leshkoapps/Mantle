//
//  LSMTLDictionaryMappingSpec.m
//  Mantle
//
//  Created by Robert Böhnke on 10/23/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import "LSMTLTestModel.h"

#import "NSDictionary+LSMTLMappingAdditions.h"

QuickSpecBegin(LSMTLDictionaryMappingAdditions)

it(@"should return a mapping", ^{
	NSDictionary *mapping = @{
		@"name": @"name",
		@"count": @"count",
		@"nestedName": @"nestedName",
		@"weakModel": @"weakModel"
	};

	expect([NSDictionary mtl_identityPropertyMapWithModel:LSMTLTestModel.class]).to(equal(mapping));
});

QuickSpecEnd
