//
//  LSMTLTestModel.h
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import <Mantle/Mantle.h>

extern NSString * const LSMTLTestModelErrorDomain;
extern const NSInteger LSMTLTestModelNameTooLong;
extern const NSInteger LSMTLTestModelNameMissing;



@interface LSMTLEmptyTestModel : LSMTLModel
@end

@interface LSMTLTestModel : LSMTLModel <LSMTLJSONSerializing>

// Defaults to 1. This changes the behavior of some of the receiver's methods to
// emulate a migration.
+ (void)setModelVersion:(NSUInteger)version;

// Must be less than 10 characters.
//
// This property is associated with a "username" key in JSON.
@property (nonatomic, copy) NSString *name;

// Defaults to 1. When two models are merged, their counts are added together.
//
// This property is a string in JSON.
@property (nonatomic, assign) NSUInteger count;

// This property is associated with a "nested.name" key path in JSON. This
// property should not be encoded into new archives.
@property (nonatomic, copy) NSString *nestedName;

// Should not be stored in the dictionary value or JSON.
@property (nonatomic, copy, readonly) NSString *dynamicName;

// Should not be stored in JSON, has LSMTLPropertyStorageTransitory.
@property (nonatomic, weak) LSMTLEmptyTestModel *weakModel;

@end

@interface LSMTLSubclassTestModel : LSMTLTestModel

// Properties to test merging between subclass and superclass
@property (nonatomic, copy) NSString *role;
@property (nonatomic, copy) NSNumber *generation;

@end

@interface LSMTLArrayTestModel : LSMTLModel <LSMTLJSONSerializing>

// This property is associated with a "users.username" key in JSON.
@property (nonatomic, copy) NSString *names;

@end

// Parses LSMTLTestModel objects from JSON instead.
@interface LSMTLSubstitutingTestModel : LSMTLModel <LSMTLJSONSerializing>
@end

@interface LSMTLValidationModel : LSMTLModel <LSMTLJSONSerializing>

// Defaults to nil, which is not considered valid.
@property (nonatomic, copy) NSString *name;

@end

// Returns a default name of 'foobar' when validateName:error: is invoked
@interface LSMTLSelfValidatingModel : LSMTLValidationModel
@end

@interface LSMTLURLModel : LSMTLModel <LSMTLJSONSerializing>

// Defaults to http://github.com.
@property (nonatomic, strong) NSURL *URL;

@end

// Conforms to LSMTLJSONSerializing but does not inherit from the LSMTLModel class.
@interface LSMTLConformingModel : NSObject <LSMTLJSONSerializing>

@property (nonatomic, copy) NSString *name;

@end

@interface LSMTLStorageBehaviorModel : LSMTLModel

@property (readonly, nonatomic, assign) BOOL primitive;

@property (readonly, nonatomic, assign) id assignProperty;
@property (readonly, nonatomic, weak) id weakProperty;
@property (readonly, nonatomic, strong) id strongProperty;

@property (readonly, nonatomic, strong) id shadowedInSubclass;
@property (readonly, nonatomic, strong) id declaredInProtocol;

@end

@protocol LSMTLDateProtocol <NSObject>

@property (readonly, nonatomic, strong) id declaredInProtocol;

@end

@interface LSMTLStorageBehaviorModelSubclass : LSMTLStorageBehaviorModel <LSMTLDateProtocol>

@property (readonly, nonatomic, strong) id shadowedInSubclass;

@end

@interface LSMTLBoolModel : LSMTLModel <LSMTLJSONSerializing>

@property (nonatomic, assign) BOOL flag;

@end

@interface LSMTLStringModel : LSMTLModel <LSMTLJSONSerializing>

@property (readwrite, nonatomic, copy) NSString *string;

@end

@interface LSMTLIDModel : LSMTLModel <LSMTLJSONSerializing>

@property (nonatomic, strong) id anyObject;

@end

@interface LSMTLNonPropertyModel : LSMTLModel <LSMTLJSONSerializing>

- (NSURL *)homepage;

@end

@interface LSMTLMultiKeypathModel : LSMTLModel <LSMTLJSONSerializing>

// This property is associated with the "location" and "length" keys in JSON.
@property (readonly, nonatomic, assign) NSRange range;

// This property is associated with the "nested.location" and "nested.length"
// keys in JSON.
@property (readonly, nonatomic, assign) NSRange nestedRange;

@end

@interface LSMTLClassClusterModel : LSMTLModel <LSMTLJSONSerializing>

@property (readonly, nonatomic, copy) NSString *flavor;

@end

@interface LSMTLChocolateClassClusterModel : LSMTLClassClusterModel

// Associated with the "chocolate_bitterness" JSON key and transformed to a
// string.
@property (readwrite, nonatomic, assign) NSUInteger bitterness;

@end

@interface LSMTLStrawberryClassClusterModel : LSMTLClassClusterModel

// Associated with the "strawberry_freshness" JSON key.
@property (readwrite, nonatomic, assign) NSUInteger freshness;

@end


@protocol LSMTLOptionalPropertyProtocol

@optional
@property (readwrite, nonatomic, strong) id optionalUnimplementedProperty;
@property (readwrite, nonatomic, strong) id optionalImplementedProperty;

@end

@interface LSMTLOptionalPropertyModel : LSMTLModel <LSMTLOptionalPropertyProtocol>

@property (readwrite, nonatomic, strong) id optionalImplementedProperty;

@end


@interface LSMTLRecursiveUserModel : LSMTLModel <LSMTLJSONSerializing>

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSArray *groups;

@end

@interface LSMTLRecursiveGroupModel : LSMTLModel <LSMTLJSONSerializing>

@property (nonatomic, readonly) LSMTLRecursiveUserModel *owner;
@property (nonatomic, readonly) NSArray *users;
@end

@interface LSMTLPropertyDefaultAdapterModel : LSMTLModel<LSMTLJSONSerializing>

@property (readwrite, nonatomic, strong) LSMTLEmptyTestModel *nonConformingLSMTLJSONSerializingProperty;
@property (readwrite, nonatomic, strong) LSMTLTestModel *conformingLSMTLJSONSerializingProperty;
@property (readwrite, nonatomic, strong) NSString *property;

@end
