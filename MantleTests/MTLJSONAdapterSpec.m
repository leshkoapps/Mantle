//
//  LSMTLJSONAdapterSpec.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2013-02-13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <Nimble/Nimble.h>
#import <Quick/Quick.h>

#import "LSMTLTestJSONAdapter.h"
#import "LSMTLTestModel.h"
#import "LSMTLTransformerErrorExamples.h"

@interface LSMTLJSONAdapter (SpecExtensions)

// Used for testing transformer lifetimes.
+ (NSValueTransformer *)NSDateJSONTransformer;

@end

@implementation LSMTLJSONAdapter (SpecExtensions)

+ (NSValueTransformer *)NSDateJSONTransformer {
	return [[NSValueTransformer alloc] init];
}

@end

QuickSpecBegin(LSMTLJSONAdapterSpec)

it(@"should initialize with a model class", ^{
	NSDictionary *values = @{
		@"username": NSNull.null,
		@"count": @"5",
	};

	LSMTLJSONAdapter *adapter = [[LSMTLJSONAdapter alloc] initWithModelClass:LSMTLTestModel.class];
	expect(adapter).notTo(beNil());

	NSError *error = nil;
	LSMTLTestModel *model = [adapter modelFromJSONDictionary:values error:&error];
	expect(error).to(beNil());

	expect(model).notTo(beNil());
	expect(model.name).to(beNil());
	expect(@(model.count)).to(equal(@5));

	NSDictionary *JSONDictionary = @{
		@"username": NSNull.null,
		@"count": @"5",
		@"nested": @{ @"name": NSNull.null },
	};

	__block NSError *serializationError;
	expect([adapter JSONDictionaryFromModel:model error:&serializationError]).to(equal(JSONDictionary));
	expect(serializationError).to(beNil());
});

it(@"should initialize nested key paths from JSON", ^{
	NSDictionary *values = @{
		@"username": @"foo",
		@"nested": @{ @"name": @"bar" },
		@"count": @"0"
	};

	NSError *error = nil;
	LSMTLTestModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLTestModel.class fromJSONDictionary:values error:&error];
	expect(model).notTo(beNil());
	expect(error).to(beNil());

	expect(model.name).to(equal(@"foo"));
	expect(@(model.count)).to(equal(@0));
	expect(model.nestedName).to(equal(@"bar"));

	__block NSError *serializationError;
	expect([LSMTLJSONAdapter JSONDictionaryFromModel:model error:&serializationError]).to(equal(values));
	expect(serializationError).to(beNil());
});

it(@"it should initialize properties with multiple key paths from JSON", ^{
	NSDictionary *values = @{
		@"location": @20,
		@"length": @12,
		@"nested": @{
			@"location": @12,
			@"length": @34
		}
	};

	NSError *error = nil;
	LSMTLMultiKeypathModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLMultiKeypathModel.class fromJSONDictionary:values error:&error];
	expect(model).notTo(beNil());
	expect(error).to(beNil());

	expect(@(model.range.location)).to(equal(@20));
	expect(@(model.range.length)).to(equal(@12));

	expect(@(model.nestedRange.location)).to(equal(@12));
	expect(@(model.nestedRange.length)).to(equal(@34));

	__block NSError *serializationError;
	expect([LSMTLJSONAdapter JSONDictionaryFromModel:model error:&serializationError]).to(equal(values));
	expect(serializationError).to(beNil());
});

it(@"should return nil and error with an invalid key path from JSON",^{
	NSDictionary *values = @{
		@"username": @"foo",
		@"nested": @"bar",
		@"count": @"0"
	};

	NSError *error = nil;
	LSMTLTestModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLTestModel.class fromJSONDictionary:values error:&error];
	expect(model).to(beNil());
	expect(error).notTo(beNil());
	expect(error.domain).to(equal(LSMTLJSONAdapterErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLJSONAdapterErrorInvalidJSONDictionary)));
});

it(@"should support key paths across arrays", ^{
	NSDictionary *values = @{
		@"users": @[
			@{
				@"name": @"foo"
			},
			@{
				@"name": @"bar"
			},
			@{
				@"name": @"baz"
			}
		]
	};

	NSError *error = nil;
	LSMTLArrayTestModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLArrayTestModel.class fromJSONDictionary:values error:&error];
	expect(model).to(beNil());
	expect(error).notTo(beNil());

	expect(error.domain).to(equal(LSMTLJSONAdapterErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLJSONAdapterErrorInvalidJSONDictionary)));
});

it(@"should initialize without returning any error when using a JSON dictionary which Null.null as value",^{
	NSDictionary *values = @{
		@"username": @"foo",
		@"nested": NSNull.null,
		@"count": @"0"
	};

	NSError *error = nil;
	LSMTLTestModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLTestModel.class fromJSONDictionary:values error:&error];
	expect(model).notTo(beNil());
	expect(error).to(beNil());

	expect(model.name).to(equal(@"foo"));
	expect(@(model.count)).to(equal(@0));
	expect(model.nestedName).to(beNil());
});

it(@"should ignore unrecognized JSON keys", ^{
	NSDictionary *values = @{
		@"foobar": @"foo",
		@"count": @"2",
		@"_": NSNull.null,
		@"username": @"buzz",
		@"nested": @{ @"name": @"bar", @"stuffToIgnore": @5, @"moreNonsense": NSNull.null },
	};

	NSError *error = nil;
	LSMTLTestModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLTestModel.class fromJSONDictionary:values error:&error];
	expect(model).notTo(beNil());
	expect(error).to(beNil());

	expect(model.name).to(equal(@"buzz"));
	expect(@(model.count)).to(equal(@2));
	expect(model.nestedName).to(equal(@"bar"));
});

it(@"should fail to initialize if JSON dictionary validation fails", ^{
	NSDictionary *values = @{
		@"username": @"this is too long a name",
	};

	NSError *error = nil;
	LSMTLTestModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLTestModel.class fromJSONDictionary:values error:&error];
	expect(model).to(beNil());
	expect(error.domain).to(equal(LSMTLTestModelErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTestModelNameTooLong)));
});

it(@"should implicitly transform URLs", ^{
	LSMTLURLModel *model = [[LSMTLURLModel alloc] init];

	NSError *error = nil;
	NSDictionary *JSONDictionary = [LSMTLJSONAdapter JSONDictionaryFromModel:model error:&error];

	expect(JSONDictionary[@"URL"]).to(equal(@"http://github.com"));
	expect(error).to(beNil());
});

it(@"should implicitly transform BOOLs", ^{
	LSMTLBoolModel *model = [[LSMTLBoolModel alloc] init];

	NSError *error = nil;
	NSDictionary *JSONDictionary = [LSMTLJSONAdapter JSONDictionaryFromModel:model error:&error];

	expect(JSONDictionary[@"flag"]).to(beIdenticalTo((id)kCFBooleanFalse));
	expect(error).to(beNil());
});

it(@"should not invoke implicit transformers for property keys not actually backed by properties", ^{
	LSMTLNonPropertyModel *model = [[LSMTLNonPropertyModel alloc] init];

	NSError *error = nil;
	NSDictionary *JSONDictionary = [LSMTLJSONAdapter JSONDictionaryFromModel:model error:&error];

	expect(error).to(beNil());
	expect(JSONDictionary[@"homepage"]).to(equal(model.homepage));
});

it(@"should fail to initialize if JSON transformer fails", ^{
	NSDictionary *values = @{
		@"URL": @666,
	};

	NSError *error = nil;
	LSMTLModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLURLModel.class fromJSONDictionary:values error:&error];
	expect(model).to(beNil());
	expect(error.domain).to(equal(LSMTLTransformerErrorHandlingErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTransformerErrorHandlingErrorInvalidInput)));
	expect(error.userInfo[LSMTLTransformerErrorHandlingInputValueErrorKey]).to(equal(@666));
});

it(@"should fail to deserialize if the JSON types don't match the primitive properties", ^{
	NSDictionary *values = @{
		@"flag": @"Potentially"
	};

	NSError *error = nil;
	LSMTLModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLBoolModel.class fromJSONDictionary:values error:&error];
	expect(model).to(beNil());

	expect(error.domain).to(equal(LSMTLTransformerErrorHandlingErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTransformerErrorHandlingErrorInvalidInput)));
	expect(error.userInfo[LSMTLTransformerErrorHandlingInputValueErrorKey]).to(equal(@"Potentially"));
});

it(@"should fail to deserialize if the JSON types don't match the properties", ^{
	NSDictionary *values = @{
		@"string": @666
	};

	NSError *error = nil;
	LSMTLModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLStringModel.class fromJSONDictionary:values error:&error];
	expect(model).to(beNil());

	expect(error.domain).to(equal(LSMTLTransformerErrorHandlingErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTransformerErrorHandlingErrorInvalidInput)));
	expect(error.userInfo[LSMTLTransformerErrorHandlingInputValueErrorKey]).to(equal(@666));
});

it(@"should allow subclasses to filter serialized property keys", ^{
	NSDictionary *values = @{
		@"username": @"foo",
		@"count": @"5",
		@"nested": @{ @"name": NSNull.null }
	};

	LSMTLTestJSONAdapter *adapter = [[LSMTLTestJSONAdapter alloc] initWithModelClass:LSMTLTestModel.class];

	NSError *error;
	LSMTLTestModel *model = [adapter modelFromJSONDictionary:values error:&error];
	expect(model).notTo(beNil());
	expect(error).to(beNil());

	NSDictionary *complete = [adapter JSONDictionaryFromModel:model error:&error];
	NSDictionary *expected = [values mtl_dictionaryByAddingEntriesFromDictionary:@{ @"test": @YES }];

	expect(complete).to(equal(expected));
	expect(error).to(beNil());

	adapter.ignoredPropertyKeys = [NSSet setWithObjects:@"count", @"nestedName", nil];

	NSDictionary *partial = [adapter JSONDictionaryFromModel:model error:&error];
	expected = @{
		@"username": @"foo",
		@"test": @YES,
	};

	expect(partial).to(equal(expected));
	expect(error).to(beNil());
});

it(@"should accept any object for id properties", ^{
	NSDictionary *values = @{
		@"anyObject": @"Not an NSValue"
	};

	NSError *error = nil;
	LSMTLIDModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLIDModel.class fromJSONDictionary:values error:&error];
	expect(model).notTo(beNil());
	expect(model.anyObject).to(equal(@"Not an NSValue"));

	expect(error.domain).to(beNil());
});

it(@"should fail to serialize if a JSON transformer errors", ^{
	LSMTLURLModel *model = [[LSMTLURLModel alloc] init];

	[model setValue:@"totallyNotAnNSURL" forKey:@"URL"];

	NSError *error;
	NSDictionary *dictionary = [LSMTLJSONAdapter JSONDictionaryFromModel:model error:&error];
	expect(dictionary).to(beNil());
	expect(error.domain).to(equal(LSMTLTransformerErrorHandlingErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTransformerErrorHandlingErrorInvalidInput)));
	expect(error.userInfo[LSMTLTransformerErrorHandlingInputValueErrorKey]).to(equal(@"totallyNotAnNSURL"));
});

it(@"should parse a different model class", ^{
	NSDictionary *values = @{
		@"username": @"foo",
		@"nested": @{ @"name": @"bar" },
		@"count": @"0"
	};

	NSError *error = nil;
	LSMTLTestModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLSubstitutingTestModel.class fromJSONDictionary:values error:&error];
	expect(model).to(beAnInstanceOf(LSMTLTestModel.class));
	expect(error).to(beNil());

	expect(model.name).to(equal(@"foo"));
	expect(@(model.count)).to(equal(@0));
	expect(model.nestedName).to(equal(@"bar"));

	__block NSError *serializationError;
	expect([LSMTLJSONAdapter JSONDictionaryFromModel:model error:&serializationError]).to(equal(values));
	expect(serializationError).to(beNil());
});

it(@"should serialize different model classes", ^{
	LSMTLJSONAdapter *adapter = [[LSMTLJSONAdapter alloc] initWithModelClass:LSMTLClassClusterModel.class];

	LSMTLChocolateClassClusterModel *chocolate = [LSMTLChocolateClassClusterModel modelWithDictionary:@{
		@"bitterness": @100
	} error:NULL];

	NSError *error = nil;
	NSDictionary *chocolateValues = [adapter JSONDictionaryFromModel:chocolate error:&error];

	expect(error).to(beNil());
	expect(chocolateValues).to(equal((@{
		@"flavor": @"chocolate",
		@"chocolate_bitterness": @"100"
	})));

	LSMTLStrawberryClassClusterModel *strawberry = [LSMTLStrawberryClassClusterModel modelWithDictionary:@{
		@"freshness": @20
	} error:NULL];

	NSDictionary *strawberryValues = [adapter JSONDictionaryFromModel:strawberry error:&error];

	expect(error).to(beNil());
	expect(strawberryValues).to(equal((@{
		@"flavor": @"strawberry",
		@"strawberry_freshness": @20
	})));
});

it(@"should parse model classes not inheriting from LSMTLModel", ^{
	NSDictionary *values = @{
		@"name": @"foo",
	};

	NSError *error = nil;
	LSMTLConformingModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLConformingModel.class fromJSONDictionary:values error:&error];
	expect(model).to(beAnInstanceOf(LSMTLConformingModel.class));
	expect(error).to(beNil());

	expect(model.name).to(equal(@"foo"));
});

it(@"should return an error when no suitable model class is found", ^{
	NSError *error = nil;
	LSMTLTestModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLSubstitutingTestModel.class fromJSONDictionary:@{} error:&error];
	expect(model).to(beNil());

	expect(error).notTo(beNil());
	expect(error.domain).to(equal(LSMTLJSONAdapterErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLJSONAdapterErrorNoClassFound)));
});

it(@"should validate models", ^{
	NSError *error = nil;
	LSMTLValidationModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLValidationModel.class fromJSONDictionary:@{} error:&error];

	expect(model).to(beNil());

	expect(error).notTo(beNil());
	expect(error.domain).to(equal(LSMTLTestModelErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTestModelNameMissing)));
});

describe(@"JSON transformers", ^{
	describe(@"dictionary transformer", ^{
		__block NSValueTransformer *transformer;
		
		__block LSMTLTestModel *model;
		__block NSDictionary *JSONDictionary;
		
		beforeEach(^{
			model = [[LSMTLTestModel alloc] init];
			JSONDictionary = [LSMTLJSONAdapter JSONDictionaryFromModel:model error:NULL];
			
			transformer = [LSMTLJSONAdapter dictionaryTransformerWithModelClass:LSMTLTestModel.class];
			expect(transformer).notTo(beNil());
		});
		
		it(@"should transform a JSON dictionary into a model", ^{
			expect([transformer transformedValue:JSONDictionary]).to(equal(model));
		});
		
		it(@"should transform a model into a JSON dictionary", ^{
			expect(@([transformer.class allowsReverseTransformation])).to(beTruthy());
			expect([transformer reverseTransformedValue:model]).to(equal(JSONDictionary));
		});
		
		itBehavesLike(LSMTLTransformerErrorExamples, ^{
			return @{
				LSMTLTransformerErrorExamplesTransformer: transformer,
				LSMTLTransformerErrorExamplesInvalidTransformationInput: NSNull.null,
				LSMTLTransformerErrorExamplesInvalidReverseTransformationInput: NSNull.null
			};
		});
	});
	
	describe(@"external representation array transformer", ^{
		__block NSValueTransformer *transformer;
		
		__block NSArray *models;
		__block NSArray *JSONDictionaries;
		
		beforeEach(^{
			NSMutableArray *uniqueModels = [NSMutableArray array];
			NSMutableArray *mutableDictionaries = [NSMutableArray array];
			
			for (NSUInteger i = 0; i < 10; i++) {
				LSMTLTestModel *model = [[LSMTLTestModel alloc] init];
				model.count = i;
				
				[uniqueModels addObject:model];
				
				NSDictionary *dict = [LSMTLJSONAdapter JSONDictionaryFromModel:model error:NULL];
				expect(dict).notTo(beNil());
				
				[mutableDictionaries addObject:dict];
			}
			
			uniqueModels[2] = NSNull.null;
			mutableDictionaries[2] = NSNull.null;
			
			models = [uniqueModels copy];
			JSONDictionaries = [mutableDictionaries copy];
			
			transformer = [LSMTLJSONAdapter arrayTransformerWithModelClass:LSMTLTestModel.class];
			expect(transformer).notTo(beNil());
		});
		
		it(@"should transform JSON dictionaries into models", ^{
			expect([transformer transformedValue:JSONDictionaries]).to(equal(models));
		});
		
		it(@"should transform models into JSON dictionaries", ^{
			expect(@([transformer.class allowsReverseTransformation])).to(beTruthy());
			expect([transformer reverseTransformedValue:models]).to(equal(JSONDictionaries));
		});
		
		itBehavesLike(LSMTLTransformerErrorExamples, ^{
			return @{
				LSMTLTransformerErrorExamplesTransformer: transformer,
				LSMTLTransformerErrorExamplesInvalidTransformationInput: NSNull.null,
				LSMTLTransformerErrorExamplesInvalidReverseTransformationInput: NSNull.null
			};
		});
	});

	it(@"should use receiving class for serialization", ^{
		NSDictionary *values = @{
			@"username": @"foo",
			@"count": @"5",
			@"nested": @{ @"name": NSNull.null }
		};
		
		NSValueTransformer *transformer = [LSMTLTestJSONAdapter dictionaryTransformerWithModelClass:LSMTLTestModel.class];

		LSMTLTestModel *model = [transformer transformedValue:values];
		expect(model).to(beAKindOf(LSMTLTestModel.class));
		expect(model).notTo(beNil());

		NSDictionary *serialized = [transformer reverseTransformedValue:model];
		expect(serialized).notTo(beNil());
		expect(serialized[@"test"]).to(beTruthy());
	});
});

describe(@"Deserializing multiple models", ^{
	NSDictionary *value1 = @{
		@"username": @"foo"
	};

	NSDictionary *value2 = @{
		@"username": @"bar"
	};

	NSArray *JSONModels = @[ value1, value2 ];

	it(@"should initialize models from an array of JSON dictionaries", ^{
		NSError *error = nil;
		NSArray *mantleModels = [LSMTLJSONAdapter modelsOfClass:LSMTLTestModel.class fromJSONArray:JSONModels error:&error];

		expect(error).to(beNil());
		expect(mantleModels).notTo(beNil());
		expect(@(mantleModels.count)).to(equal(@2));
		expect([mantleModels[0] name]).to(equal(@"foo"));
		expect([mantleModels[1] name]).to(equal(@"bar"));
	});

	it(@"should not be affected by a NULL error parameter", ^{
		NSError *error = nil;
		NSArray *expected = [LSMTLJSONAdapter modelsOfClass:LSMTLTestModel.class fromJSONArray:JSONModels error:&error];
		NSArray *models = [LSMTLJSONAdapter modelsOfClass:LSMTLTestModel.class fromJSONArray:JSONModels error:NULL];

		expect(models).to(equal(expected));
	});
});

it(@"should return nil and an error if it fails to initialize any model from an array", ^{
	NSDictionary *value1 = @{
		@"username": @"foo",
		@"count": @"1",
	};

	NSDictionary *value2 = @{
		@"count": @[ @"This won't parse" ],
	};

	NSArray *JSONModels = @[ value1, value2 ];

	NSError *error = nil;
	NSArray *mantleModels = [LSMTLJSONAdapter modelsOfClass:LSMTLSubstitutingTestModel.class fromJSONArray:JSONModels error:&error];

	expect(error).notTo(beNil());
	expect(error.domain).to(equal(LSMTLJSONAdapterErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLJSONAdapterErrorNoClassFound)));
	expect(mantleModels).to(beNil());
});

it(@"should return an array of dictionaries from models", ^{
	LSMTLTestModel *model1 = [[LSMTLTestModel alloc] init];
	model1.name = @"foo";

	LSMTLTestModel *model2 = [[LSMTLTestModel alloc] init];
	model2.name = @"bar";

	NSError *error;
	NSArray *JSONArray = [LSMTLJSONAdapter JSONArrayFromModels:@[ model1, model2 ] error:&error];

	expect(error).to(beNil());

	expect(JSONArray).notTo(beNil());
	expect(@(JSONArray.count)).to(equal(@2));
	expect(JSONArray[0][@"username"]).to(equal(@"foo"));
	expect(JSONArray[1][@"username"]).to(equal(@"bar"));
});

it(@"should not leak transformers", ^{
	__weak id weakTransformer;

	@autoreleasepool {
		id transformer = [LSMTLJSONAdapter transformerForModelPropertiesOfClass:NSDate.class];
		weakTransformer = transformer;

		expect(transformer).notTo(beNil());
	}

	expect(weakTransformer).toEventually(beNil());
});

it(@"should support recursive models", ^{
	NSDictionary *dictionary = @{
		@"owner": @{ @"name": @"Cameron" },
		@"users": @[
			@{ @"name": @"Dimitri" },
			@{ @"name": @"John" },
		],
	};

	NSError *error = nil;
	LSMTLRecursiveGroupModel *group = [LSMTLJSONAdapter modelOfClass:LSMTLRecursiveGroupModel.class fromJSONDictionary:dictionary error:&error];
	expect(group).notTo(beNil());
	expect(@(group.users.count)).to(equal(@2));
});

it(@"should automatically transform a property that conforms to LSMTLJSONSerializing", ^{
	NSDictionary *JSONDictionary = @{
		@"property": @"property",
		@"conformingLSMTLJSONSerializingProperty":@{
			@"username": @"testName",
			@"count": @"5",
		},
		@"nonConformingLSMTLJSONSerializingProperty": NSNull.null
	};

	LSMTLJSONAdapter *adapter = [[LSMTLJSONAdapter alloc] initWithModelClass:LSMTLPropertyDefaultAdapterModel.class];
	expect(adapter).notTo(beNil());

	NSError *error = nil;
	LSMTLPropertyDefaultAdapterModel *model = [LSMTLJSONAdapter modelOfClass:LSMTLPropertyDefaultAdapterModel.class fromJSONDictionary:JSONDictionary error:&error];
	expect(model).notTo(beNil());
	expect(model.conformingLSMTLJSONSerializingProperty).notTo(beNil());
	expect(model.conformingLSMTLJSONSerializingProperty.name).to(equal(@"testName"));
	expect(model.nonConformingLSMTLJSONSerializingProperty).to(beNil());
	expect(model.property).to(equal(@"property"));
	expect(error).to(beNil());
});

it(@"should not automatically transform a property that conforms to LSMTLModel but not LSMTLJSONSerializing", ^{
	NSDictionary *JSONDictionary = @{
		@"property": @"property",
		@"conformingLSMTLJSONSerializingProperty":@{
			@"username": @"testName",
			@"count": @"5",
		},
		/// Triggers an error since the dictionary is not automatically parsed
		/// and no transformer is supplied.
		@"nonConformingLSMTLJSONSerializingProperty": @{}
	};

	LSMTLJSONAdapter *adapter = [[LSMTLJSONAdapter alloc] initWithModelClass:LSMTLPropertyDefaultAdapterModel.class];
	expect(adapter).notTo(beNil());

	NSError *error = nil;
	LSMTLPropertyDefaultAdapterModel *model = [adapter modelFromJSONDictionary:JSONDictionary error:&error];
	expect(model).to(beNil());
	expect(error).notTo(beNil());
	expect(error.domain).to(equal(LSMTLTransformerErrorHandlingErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTransformerErrorHandlingErrorInvalidInput)));
});

QuickSpecEnd
