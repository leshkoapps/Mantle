//
//  NSError+LSMTLModelException.m
//  Mantle
//
//  Created by Robert Böhnke on 7/6/13.
//  Copyright (c) 2013 GitHub. All rights reserved.
//

#import "LSMTLModel.h"

#import "NSError+LSMTLModelException.h"

// The domain for errors originating from LSMTLModel.
static NSString * const LSMTLModelErrorDomain = @"LSMTLModelErrorDomain";

// An exception was thrown and caught.
static const NSInteger LSMTLModelErrorExceptionThrown = 1;

// Associated with the NSException that was caught.
static NSString * const LSMTLModelThrownExceptionErrorKey = @"LSMTLModelThrownException";

@implementation NSError (LSMTLModelException)

+ (instancetype)mtl_modelErrorWithException:(NSException *)exception {
	NSParameterAssert(exception != nil);

	NSDictionary *userInfo = @{
		NSLocalizedDescriptionKey: exception.description,
		NSLocalizedFailureReasonErrorKey: exception.reason,
		LSMTLModelThrownExceptionErrorKey: exception
	};

	return [NSError errorWithDomain:LSMTLModelErrorDomain code:LSMTLModelErrorExceptionThrown userInfo:userInfo];
}

@end
