//
//  LSMTLPredefinedTransformerAdditionsSpec.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-27.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <Nimble/Nimble.h>
#import <Quick/Quick.h>
#import "LSMTLTransformerErrorExamples.h"

#import "LSMTLTestModel.h"

enum : NSInteger {
	LSMTLPredefinedTransformerAdditionsSpecEnumNegative = -1,
	LSMTLPredefinedTransformerAdditionsSpecEnumZero = 0,
	LSMTLPredefinedTransformerAdditionsSpecEnumPositive = 1,
	LSMTLPredefinedTransformerAdditionsSpecEnumDefault = 42,
} LSMTLPredefinedTransformerAdditionsSpecEnum;

QuickSpecBegin(LSMTLPredefinedTransformerAdditions)

describe(@"The URL transformer", ^{
	__block NSValueTransformer *transformer;

	beforeEach(^{
		transformer = [NSValueTransformer valueTransformerForName:LSMTLURLValueTransformerName];

		expect(transformer).notTo(beNil());
		expect(@([transformer.class allowsReverseTransformation])).to(beTruthy());
	});

	it(@"should convert NSStrings to NSURLs and back", ^{
		NSString *URLString = @"http://www.github.com/";
		expect([transformer transformedValue:URLString]).to(equal([NSURL URLWithString:URLString]));
		expect([transformer reverseTransformedValue:[NSURL URLWithString:URLString]]).to(equal(URLString));

		expect([transformer transformedValue:nil]).to(beNil());
		expect([transformer reverseTransformedValue:nil]).to(beNil());
	});

	itBehavesLike(LSMTLTransformerErrorExamples, ^{
		return @{
			LSMTLTransformerErrorExamplesTransformer: transformer,
			LSMTLTransformerErrorExamplesInvalidTransformationInput: @"not a valid URL",
			LSMTLTransformerErrorExamplesInvalidReverseTransformationInput: NSNull.null
		};
	});
});

describe(@"The number transformer", ^{
	__block NSValueTransformer *transformer;

	beforeEach(^{
		transformer = [NSValueTransformer valueTransformerForName:LSMTLBooleanValueTransformerName];
		expect(transformer).notTo(beNil());
		expect(@([transformer.class allowsReverseTransformation])).to(beTruthy());
	});

	it(@"it convert int- to boolean-backed NSNumbers and back", ^{
		// Back these NSNumbers with ints, rather than booleans,
		// to ensure that the value transformers are actually transforming.
		NSNumber *booleanYES = @(1);
		NSNumber *booleanNO = @(0);

		expect([transformer transformedValue:booleanYES]).to(equal([NSNumber numberWithBool:YES]));
		expect([transformer transformedValue:booleanYES]).to(beIdenticalTo((id)kCFBooleanTrue));

		expect([transformer reverseTransformedValue:booleanYES]).to(equal([NSNumber numberWithBool:YES]));
		expect([transformer reverseTransformedValue:booleanYES]).to(beIdenticalTo((id)kCFBooleanTrue));

		expect([transformer transformedValue:booleanNO]).to(equal([NSNumber numberWithBool:NO]));
		expect([transformer transformedValue:booleanNO]).to(beIdenticalTo((id)kCFBooleanFalse));

		expect([transformer reverseTransformedValue:booleanNO]).to(equal([NSNumber numberWithBool:NO]));
		expect([transformer reverseTransformedValue:booleanNO]).to(beIdenticalTo((id)kCFBooleanFalse));

		expect([transformer transformedValue:nil]).to(beNil());
		expect([transformer reverseTransformedValue:nil]).to(beNil());
	});

	itBehavesLike(LSMTLTransformerErrorExamples, ^{
		return @{
			LSMTLTransformerErrorExamplesTransformer: transformer,
			LSMTLTransformerErrorExamplesInvalidTransformationInput: NSNull.null,
			LSMTLTransformerErrorExamplesInvalidReverseTransformationInput: NSNull.null
		};
	});
});

describe(@"+mtl_arrayMappingTransformerWithTransformer:", ^{
	__block NSValueTransformer *transformer;

	NSArray *URLStrings = @[
		@"https://github.com/",
		@"https://github.com/MantleFramework",
		@"http://apple.com"
	];
	NSArray *URLs = @[
		[NSURL URLWithString:@"https://github.com/"],
		[NSURL URLWithString:@"https://github.com/MantleFramework"],
		[NSURL URLWithString:@"http://apple.com"]
	];

	describe(@"when called with a reversible transformer", ^{
		beforeEach(^{
			NSValueTransformer *appliedTransformer = [NSValueTransformer valueTransformerForName:LSMTLURLValueTransformerName];
			transformer = [NSValueTransformer mtl_arrayMappingTransformerWithTransformer:appliedTransformer];
			expect(transformer).notTo(beNil());
		});

		it(@"should allow reverse transformation", ^{
			expect(@([transformer.class allowsReverseTransformation])).to(beTruthy());
		});

		it(@"should apply the transformer to each element", ^{
			expect([transformer transformedValue:URLStrings]).to(equal(URLs));
		});

		it(@"should apply the transformer to each element in reverse", ^{
			expect([transformer reverseTransformedValue:URLs]).to(equal(URLStrings));
		});
	});

	describe(@"when called with a non-reversible transformer", ^{
		beforeEach(^{
			NSValueTransformer *appliedTransformer = [LSMTLValueTransformer transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error) {
				return [NSURL URLWithString:str];
			}];
			transformer = [NSValueTransformer mtl_arrayMappingTransformerWithTransformer:appliedTransformer];
			expect(transformer).notTo(beNil());
		});

		it(@"should not allow reverse transformation", ^{
			expect(@([transformer.class allowsReverseTransformation])).to(beFalsy());
		});

		it(@"should apply the transformer to each element", ^{
			expect([transformer transformedValue:URLStrings]).to(equal(URLs));
		});
	});

	itBehavesLike(LSMTLTransformerErrorExamples, ^{
		return @{
			LSMTLTransformerErrorExamplesTransformer: transformer,
			LSMTLTransformerErrorExamplesInvalidTransformationInput: NSNull.null,
			LSMTLTransformerErrorExamplesInvalidReverseTransformationInput: NSNull.null
		};
	});
});

describe(@"value mapping transformer", ^{
	__block NSValueTransformer *transformer;

	NSDictionary *dictionary = @{
		@"negative": @(LSMTLPredefinedTransformerAdditionsSpecEnumNegative),
		@[ @"zero" ]: @(LSMTLPredefinedTransformerAdditionsSpecEnumZero),
		@"positive": @(LSMTLPredefinedTransformerAdditionsSpecEnumPositive),
	};

	beforeEach(^{
		transformer = [NSValueTransformer mtl_valueMappingTransformerWithDictionary:dictionary];
	});

	it(@"should transform enum values into strings", ^{
		expect([transformer transformedValue:@"negative"]).to(equal(@(LSMTLPredefinedTransformerAdditionsSpecEnumNegative)));
		expect([transformer transformedValue:@[ @"zero" ]]).to(equal(@(LSMTLPredefinedTransformerAdditionsSpecEnumZero)));
		expect([transformer transformedValue:@"positive"]).to(equal(@(LSMTLPredefinedTransformerAdditionsSpecEnumPositive)));
	});

	it(@"should transform strings into enum values", ^{
		expect(@([transformer.class allowsReverseTransformation])).to(beTruthy());

		expect([transformer reverseTransformedValue:@(LSMTLPredefinedTransformerAdditionsSpecEnumNegative)]).to(equal(@"negative"));
		expect([transformer reverseTransformedValue:@(LSMTLPredefinedTransformerAdditionsSpecEnumZero)]).to(equal(@[ @"zero" ]));
		expect([transformer reverseTransformedValue:@(LSMTLPredefinedTransformerAdditionsSpecEnumPositive)]).to(equal(@"positive"));
	});

	describe(@"default values", ^{
		beforeEach(^{
			transformer = [NSValueTransformer mtl_valueMappingTransformerWithDictionary:dictionary defaultValue:@(LSMTLPredefinedTransformerAdditionsSpecEnumDefault) reverseDefaultValue:@"default"];
		});

		it(@"should transform unknown strings into the default enum value", ^{
			expect([transformer transformedValue:@"unknown"]).to(equal(@(LSMTLPredefinedTransformerAdditionsSpecEnumDefault)));
		});

		it(@"should transform the default enum value into the default string", ^{
			expect([transformer reverseTransformedValue:@(LSMTLPredefinedTransformerAdditionsSpecEnumDefault)]).to(equal(@"default"));
		});
	});
});

QuickSpecEnd
