//
//  LSMTLModelValidationSpec.m
//  Mantle
//
//  Created by Robert Böhnke on 7/6/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <Nimble/Nimble.h>
#import <Quick/Quick.h>

#import "LSMTLTestModel.h"

#import "LSMTLModel.h"

QuickSpecBegin(LSMTLModelValidation)

it(@"should fail with incorrect values", ^{
	LSMTLValidationModel *model = [[LSMTLValidationModel alloc] init];

	NSError *error = nil;
	BOOL success = [model validate:&error];
	expect(@(success)).to(beFalsy());

	expect(error).notTo(beNil());
	expect(error.domain).to(equal(LSMTLTestModelErrorDomain));
	expect(@(error.code)).to(equal(@(LSMTLTestModelNameMissing)));
});

it(@"should succeed with correct values", ^{
	LSMTLValidationModel *model = [[LSMTLValidationModel alloc] initWithDictionary:@{ @"name": @"valid" } error:NULL];

	NSError *error = nil;
	BOOL success = [model validate:&error];
	expect(@(success)).to(beTruthy());

	expect(error).to(beNil());
});

it(@"should apply values returned from -validateValue:error:", ^{
	LSMTLSelfValidatingModel *model = [[LSMTLSelfValidatingModel alloc] init];

	NSError *error = nil;
	BOOL success = [model validate:&error];
	expect(@(success)).to(beTruthy());

	expect(model.name).to(equal(@"foobar"));

	expect(error).to(beNil());
});

QuickSpecEnd
