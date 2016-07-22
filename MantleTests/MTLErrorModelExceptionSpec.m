//
//  LSMTLErrorModelExceptionSpec.m
//  Mantle
//
//  Created by Robert Böhnke on 7/6/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>
#import <Nimble/Nimble.h>
#import <Quick/Quick.h>

#import "NSError+LSMTLModelException.h"

QuickSpecBegin(LSMTLErrorModelException)

describe(@"+mtl_modelErrorWithException:", ^{
	it(@"should return a new error for that exception", ^{
		NSException *exception = [NSException exceptionWithName:@"LSMTLTestException" reason:@"Just Testing" userInfo:nil];

		NSError *error = [NSError mtl_modelErrorWithException:exception];

		expect(error).notTo(beNil());
		expect(error.localizedDescription).to(equal(@"Just Testing"));
		expect(error.localizedFailureReason).to(equal(@"Just Testing"));
	});
});

QuickSpecEnd
