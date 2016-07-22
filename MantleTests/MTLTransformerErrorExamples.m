//
//  LSMTLTransformerErrorExamples.m
//  Mantle
//
//  Created by Robert Böhnke on 10/9/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Quick/Quick.h>
#import <Nimble/Nimble.h>
#import "LSMTLTransformerErrorExamples.h"

#import "LSMTLTransformerErrorHandling.h"

NSString * const LSMTLTransformerErrorExamples = @"LSMTLTransformerErrorExamples";

NSString * const LSMTLTransformerErrorExamplesTransformer = @"LSMTLTransformerErrorExamplesTransformer";
NSString * const LSMTLTransformerErrorExamplesInvalidTransformationInput = @"LSMTLTransformerErrorExamplesInvalidTransformationInput";
NSString * const LSMTLTransformerErrorExamplesInvalidReverseTransformationInput = @"LSMTLTransformerErrorExamplesInvalidReverseTransformationInput";

QuickConfigurationBegin(LSMTLTransformerErrorExamplesConfiguration)

+ (void)configure:(Configuration *)configuration {
	sharedExamples(LSMTLTransformerErrorExamples, ^(QCKDSLSharedExampleContext data) {
		__block NSValueTransformer<LSMTLTransformerErrorHandling> *transformer;
		__block id invalidTransformationInput;
		__block id invalidReverseTransformationInput;

		beforeEach(^{
			transformer = data()[LSMTLTransformerErrorExamplesTransformer];
			invalidTransformationInput = data()[LSMTLTransformerErrorExamplesInvalidTransformationInput];
			invalidReverseTransformationInput = data()[LSMTLTransformerErrorExamplesInvalidReverseTransformationInput];

			expect(@([transformer conformsToProtocol:@protocol(LSMTLTransformerErrorHandling)])).to(beTruthy());
		});

		it(@"should return errors occurring during transformation", ^{
			__block NSError *error;
			__block BOOL success = NO;

			expect([transformer transformedValue:invalidTransformationInput success:&success error:&error]).to(beNil());
			expect(@(success)).to(beFalsy());
			expect(error).notTo(beNil());
			expect(error.domain).to(equal(LSMTLTransformerErrorHandlingErrorDomain));
			expect(@(error.code)).to(equal(@(LSMTLTransformerErrorHandlingErrorInvalidInput)));
			expect(error.userInfo[LSMTLTransformerErrorHandlingInputValueErrorKey]).to(equal(invalidTransformationInput));
		});

		it(@"should return errors occurring during reverse transformation", ^{
			if (![transformer.class allowsReverseTransformation]) return;

			__block NSError *error;
			__block BOOL success = NO;

			expect([transformer reverseTransformedValue:invalidReverseTransformationInput success:&success error:&error]).to(beNil());
			expect(@(success)).to(beFalsy());
			expect(error).notTo(beNil());
			expect(error.domain).to(equal(LSMTLTransformerErrorHandlingErrorDomain));
			expect(@(error.code)).to(equal(@(LSMTLTransformerErrorHandlingErrorInvalidInput)));
			expect(error.userInfo[LSMTLTransformerErrorHandlingInputValueErrorKey]).to(equal(invalidReverseTransformationInput));
		});
	});
}

QuickConfigurationEnd
