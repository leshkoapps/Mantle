//
//  Mantle.h
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-04.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for Mantle.
FOUNDATION_EXPORT double MantleVersionNumber;

//! Project version string for Mantle.
FOUNDATION_EXPORT const unsigned char MantleVersionString[];

#import <Mantle/LSMTLJSONAdapter.h>
#import <Mantle/LSMTLModel.h>
#import <Mantle/LSMTLModel+NSCoding.h>
#import <Mantle/LSMTLValueTransformer.h>
#import <Mantle/LSMTLTransformerErrorHandling.h>
#import <Mantle/NSArray+LSMTLManipulationAdditions.h>
#import <Mantle/NSDictionary+LSMTLManipulationAdditions.h>
#import <Mantle/NSDictionary+LSMTLMappingAdditions.h>
#import <Mantle/NSObject+LSMTLComparisonAdditions.h>
#import <Mantle/NSValueTransformer+LSMTLInversionAdditions.h>
#import <Mantle/NSValueTransformer+LSMTLPredefinedTransformerAdditions.h>
