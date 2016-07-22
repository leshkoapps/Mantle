//
//  LSMTLValueTransformer.h
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "LSMTLTransformerErrorHandling.h"

/// A block that represents a transformation.
///
/// value   - The value to transform.
/// success - The block must set this parameter to indicate whether the
///           transformation was successful.
///           LSMTLValueTransformer will always call this block with *success
///           initialized to YES.
/// error   - If not NULL, this may be set to an error that occurs during
///           transforming the value.
///
/// Returns the result of the transformation, which may be nil.
typedef id (^LSMTLValueTransformerBlock)(id value, BOOL *success, NSError **error);

///
/// A value transformer supporting block-based transformation.
///
@interface LSMTLValueTransformer : NSValueTransformer <LSMTLTransformerErrorHandling>

/// Returns a transformer which transforms values using the given block. Reverse
/// transformations will not be allowed.
+ (instancetype)transformerUsingForwardBlock:(LSMTLValueTransformerBlock)transformation;

/// Returns a transformer which transforms values using the given block, for
/// forward or reverse transformations.
+ (instancetype)transformerUsingReversibleBlock:(LSMTLValueTransformerBlock)transformation;

/// Returns a transformer which transforms values using the given blocks.
+ (instancetype)transformerUsingForwardBlock:(LSMTLValueTransformerBlock)forwardTransformation reverseBlock:(LSMTLValueTransformerBlock)reverseTransformation;

@end

@interface LSMTLValueTransformer (Deprecated)

+ (NSValueTransformer *)transformerWithBlock:(id (^)(id))transformationBlock __attribute__((deprecated("Replaced by +transformerUsingForwardBlock:")));

+ (NSValueTransformer *)reversibleTransformerWithBlock:(id (^)(id))transformationBlock __attribute__((deprecated("Replaced by +transformerUsingReversibleBlock:")));

+ (NSValueTransformer *)reversibleTransformerWithForwardBlock:(id (^)(id))forwardBlock reverseBlock:(id (^)(id))reverseBlock __attribute__((deprecated("Replaced by +transformerUsingForwardBlock:reverseBlock:")));

@end
