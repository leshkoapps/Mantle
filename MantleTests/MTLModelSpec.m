//
//  LSMTLModelSpec.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <Nimble/Nimble.h>
#import <Quick/Quick.h>

#import "LSMTLTestModel.h"

QuickSpecBegin(LSMTLModelSpec)

it(@"should not loop infinitely in +propertyKeys without any properties", ^{
	expect(LSMTLEmptyTestModel.propertyKeys).to(equal([NSSet set]));
});

it(@"should not include dynamic readonly properties in +propertyKeys", ^{
	NSSet *expectedKeys = [NSSet setWithObjects:@"name", @"count", @"nestedName", @"weakModel", nil];
	expect(LSMTLTestModel.propertyKeys).to(equal(expectedKeys));
});

it(@"should initialize with default values", ^{
	LSMTLTestModel *model = [[LSMTLTestModel alloc] init];
	expect(model).notTo(beNil());

	expect(model.name).to(beNil());
	expect(@(model.count)).to(equal(@1));

	NSDictionary *expectedValues = @{
		@"name": NSNull.null,
		@"count": @(1),
		@"nestedName": NSNull.null,
		@"weakModel": NSNull.null,
	};

	expect(model.dictionaryValue).to(equal(expectedValues));
	expect([model dictionaryWithValuesForKeys:expectedValues.allKeys]).to(equal(expectedValues));
});

it(@"should initialize to default values with a nil dictionary", ^{
	NSError *error = nil;
	LSMTLTestModel *dictionaryModel = [[LSMTLTestModel alloc] initWithDictionary:nil error:&error];
	expect(dictionaryModel).notTo(beNil());
	expect(error).to(beNil());

	LSMTLTestModel *defaultModel = [[LSMTLTestModel alloc] init];
	expect(dictionaryModel).to(equal(defaultModel));
});

describe(@"with a dictionary of values", ^{
	__block LSMTLEmptyTestModel *emptyModel;
	__block NSDictionary *values;
	__block LSMTLTestModel *model;

	beforeEach(^{
		emptyModel = [[LSMTLEmptyTestModel alloc] init];
		expect(emptyModel).notTo(beNil());

		values = @{
			@"name": @"foobar",
			@"count": @(5),
			@"nestedName": @"fuzzbuzz",
			@"weakModel": emptyModel,
		};

		NSError *error = nil;
		model = [[LSMTLTestModel alloc] initWithDictionary:values error:&error];
		expect(model).notTo(beNil());
		expect(error).to(beNil());
	});

	it(@"should initialize with the given values", ^{
		expect(model.name).to(equal(@"foobar"));
		expect(@(model.count)).to(equal(@5));
		expect(model.nestedName).to(equal(@"fuzzbuzz"));
		expect(model.weakModel).to(equal(emptyModel));

		expect(model.dictionaryValue).to(equal(values));
		expect([model dictionaryWithValuesForKeys:values.allKeys]).to(equal(values));
	});

	it(@"should compare equal to a matching model", ^{
		expect(model).to(equal(model));

		LSMTLTestModel *matchingModel = [[LSMTLTestModel alloc] initWithDictionary:values error:NULL];
		expect(model).to(equal(matchingModel));
		expect(@(model.hash)).to(equal(@(matchingModel.hash)));
		expect(model.dictionaryValue).to(equal(matchingModel.dictionaryValue));
	});

	it(@"should not compare equal to different model", ^{
		LSMTLTestModel *differentModel = [[LSMTLTestModel alloc] init];
		expect(model).notTo(equal(differentModel));
		expect(model.dictionaryValue).notTo(equal(differentModel.dictionaryValue));
	});

	it(@"should implement <NSCopying>", ^{
		LSMTLTestModel *copiedModel = [model copy];
		expect(copiedModel).to(equal(model));
		expect(copiedModel).notTo(beIdenticalTo(model));
	});

	it(@"should not consider -weakModel for equality", ^{
		LSMTLTestModel *copiedModel = [model copy];
		copiedModel.weakModel = nil;

		expect(model).to(equal(copiedModel));
	});
});

it(@"should fail to initialize if dictionary validation fails", ^{
	NSError *error = nil;
	LSMTLTestModel *model = [[LSMTLTestModel alloc] initWithDictionary:@{ @"name": @"this is too long a name" } error:&error];
	expect(model).to(beNil());

	expect(error).notTo(beNil());
	expect(error.domain).to(equal(LSMTLTestModelErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTestModelNameTooLong)));
});

it(@"should merge two models together", ^{
	LSMTLTestModel *target = [[LSMTLTestModel alloc] initWithDictionary:@{ @"name": @"foo", @"count": @(5) } error:NULL];
	expect(target).notTo(beNil());

	LSMTLTestModel *source = [[LSMTLTestModel alloc] initWithDictionary:@{ @"name": @"bar", @"count": @(3) } error:NULL];
	expect(source).notTo(beNil());

	[target mergeValuesForKeysFromModel:source];

	expect(target.name).to(equal(@"bar"));
	expect(@(target.count)).to(equal(@8));
});

it(@"should consider primitive properties permanent", ^{
	expect(@([LSMTLStorageBehaviorModel storageBehaviorForPropertyWithKey:@"primitive"])).to(equal(@(LSMTLPropertyStoragePermanent)));
});

it(@"should consider object-type assign properties permanent", ^{
	expect(@([LSMTLStorageBehaviorModel storageBehaviorForPropertyWithKey:@"assignProperty"])).to(equal(@(LSMTLPropertyStoragePermanent)));
});

it(@"should consider object-type strong properties permanent", ^{
	expect(@([LSMTLStorageBehaviorModel storageBehaviorForPropertyWithKey:@"strongProperty"])).to(equal(@(LSMTLPropertyStoragePermanent)));
});

it(@"should ignore readonly properties without backing ivar", ^{
	expect(@([LSMTLStorageBehaviorModel storageBehaviorForPropertyWithKey:@"notIvarBacked"])).to(equal(@(LSMTLPropertyStorageNone)));
});

it(@"should consider properties declared in subclass with storage in superclass permanent", ^{
	expect(@([LSMTLStorageBehaviorModelSubclass storageBehaviorForPropertyWithKey:@"shadowedInSubclass"])).to(equal(@(LSMTLPropertyStoragePermanent)));
	expect(@([LSMTLStorageBehaviorModelSubclass storageBehaviorForPropertyWithKey:@"declaredInProtocol"])).to(equal(@(LSMTLPropertyStoragePermanent)));
});

it(@"should ignore optional protocol properties not implemented", ^{
	expect(@([LSMTLOptionalPropertyModel storageBehaviorForPropertyWithKey:@"optionalUnimplementedProperty"])).to(equal(@(LSMTLPropertyStorageNone)));
	expect(@([LSMTLOptionalPropertyModel storageBehaviorForPropertyWithKey:@"optionalImplementedProperty"])).to(equal(@(LSMTLPropertyStoragePermanent)));
});

describe(@"merging with model subclasses", ^{
	__block LSMTLTestModel *superclass;
	__block LSMTLSubclassTestModel *subclass;

	beforeEach(^{
		superclass = [LSMTLTestModel modelWithDictionary:@{
			@"name": @"foo",
			@"count": @5
		} error:NULL];

		expect(superclass).notTo(beNil());

		subclass = [LSMTLSubclassTestModel modelWithDictionary:@{
			@"name": @"bar",
			@"count": @3,
			@"generation": @1,
			@"role": @"subclass"
		} error:NULL];

		expect(subclass).notTo(beNil());
	});

	it(@"should merge from subclass model", ^{
		[superclass mergeValuesForKeysFromModel:subclass];

		expect(superclass.name).to(equal(@"bar"));
		expect(@(superclass.count)).to(equal(@8));
	});

	it(@"should merge from superclass model", ^{
		[subclass mergeValuesForKeysFromModel:superclass];

		expect(subclass.name).to(equal(@"foo"));
		expect(@(subclass.count)).to(equal(@8));
		expect(subclass.generation).to(equal(@1));
		expect(subclass.role).to(equal(@"subclass"));
	});
});


QuickSpecEnd
