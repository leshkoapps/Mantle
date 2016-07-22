//
//  LSMTLTestJSONAdapter.h
//  Mantle
//
//  Created by Robert Böhnke on 03/04/14.
//  Copyright (c) 2014 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>

// Adds a custom key "test" to constructed JSON.
@interface LSMTLTestJSONAdapter : LSMTLJSONAdapter

// These property keys are not serialized.
@property (readwrite, nonatomic, strong) NSSet *ignoredPropertyKeys;

@end
