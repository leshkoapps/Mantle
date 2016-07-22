//
//  LSMTLTestModel.m
//  Mantle
//
//  Created by Justin Spahr-Summers on 2012-09-11.
//  Copyright (c) 2012 GitHub. All rights reserved.
//

#import "NSDictionary+LSMTLManipulationAdditions.h"

#import "LSMTLTestModel.h"
#import "NSDictionary+LSMTLMappingAdditions.h"

NSString * const LSMTLTestModelErrorDomain = @"LSMTLTestModelErrorDomain";
const NSInteger LSMTLTestModelNameTooLong = 1;
const NSInteger LSMTLTestModelNameMissing = 2;

static NSUInteger modelVersion = 1;

@implementation LSMTLEmptyTestModel
@end

@implementation LSMTLTestModel

#pragma mark Properties

- (BOOL)validateName:(NSString **)name error:(NSError **)error {
	if ([*name length] < 10) return YES;
	if (error != NULL) {
		*error = [NSError errorWithDomain:LSMTLTestModelErrorDomain code:LSMTLTestModelNameTooLong userInfo:nil];
	}

	return NO;
}

- (NSString *)dynamicName {
	return self.name;
}

#pragma mark Versioning

+ (void)setModelVersion:(NSUInteger)version {
	modelVersion = version;
}

+ (NSUInteger)modelVersion {
	return modelVersion;
}

#pragma mark Lifecycle

- (instancetype)init {
	self = [super init];
	if (self == nil) return nil;

	self.count = 1;
	return self;
}

#pragma mark LSMTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	NSMutableDictionary *mapping = [[NSDictionary mtl_identityPropertyMapWithModel:self] mutableCopy];

	[mapping removeObjectForKey:@"weakModel"];
	[mapping addEntriesFromDictionary:@{
		@"name": @"username",
		@"nestedName": @"nested.name"
	}];

	return mapping;
}

+ (NSValueTransformer *)countJSONTransformer {
	return [LSMTLValueTransformer
		transformerUsingForwardBlock:^(NSString *str, BOOL *success, NSError **error) {
			return @(str.integerValue);
		}
		reverseBlock:^(NSNumber *num, BOOL *success, NSError **error) {
			return num.stringValue;
		}];
}

#pragma mark NSCoding

- (void)encodeWithCoder:(NSCoder *)coder {
	[super encodeWithCoder:coder];

	if (modelVersion == 0) {
		[coder encodeObject:self.name forKey:@"mtl_name"];
	}
}

+ (NSDictionary *)encodingBehaviorsByPropertyKey {
	return [super.encodingBehaviorsByPropertyKey mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"nestedName": @(LSMTLModelEncodingBehaviorExcluded)
	}];
}

- (id)decodeValueForKey:(NSString *)key withCoder:(NSCoder *)coder modelVersion:(NSUInteger)fromVersion {
	NSParameterAssert(key != nil);
	NSParameterAssert(coder != nil);

	if ([key isEqual:@"name"] && fromVersion == 0) {
		return [@"M: " stringByAppendingString:[coder decodeObjectForKey:@"mtl_name"]];
	}

	return [super decodeValueForKey:key withCoder:coder modelVersion:fromVersion];
}

+ (NSDictionary *)dictionaryValueFromArchivedExternalRepresentation:(NSDictionary *)externalRepresentation version:(NSUInteger)fromVersion {
	NSParameterAssert(externalRepresentation != nil);
	NSParameterAssert(fromVersion == 1);

	return @{
		@"name": externalRepresentation[@"username"],
		@"nestedName": externalRepresentation[@"nested"][@"name"],
		@"count": @([externalRepresentation[@"count"] integerValue])
	};
}

#pragma mark Property Storage Behavior

+ (LSMTLPropertyStorage)storageBehaviorForPropertyWithKey:(NSString *)propertyKey {
	if ([propertyKey isEqual:@"weakModel"]) {
		return LSMTLPropertyStorageTransitory;
	} else {
		return [super storageBehaviorForPropertyWithKey:propertyKey];
	}
}

#pragma mark Merging

- (void)mergeCountFromModel:(LSMTLTestModel *)model {
	self.count += model.count;
}

@end

@implementation LSMTLSubclassTestModel
@end

@implementation LSMTLArrayTestModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"names": @"users.name"
	};
}

@end

@implementation LSMTLSubstitutingTestModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
	NSParameterAssert(JSONDictionary != nil);

	if (JSONDictionary[@"username"] == nil) {
		return nil;
	} else {
		return LSMTLTestModel.class;
	}
}

@end

@implementation LSMTLValidationModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"name": @"name"
	};
}

- (BOOL)validateName:(NSString **)name error:(NSError **)error {
	if (*name != nil) return YES;
	if (error != NULL) {
		*error = [NSError errorWithDomain:LSMTLTestModelErrorDomain code:LSMTLTestModelNameMissing userInfo:nil];
	}

	return NO;
}

@end

@implementation LSMTLSelfValidatingModel

- (BOOL)validateName:(NSString **)name error:(NSError **)error {
	if (*name != nil) return YES;

	*name = @"foobar";

	return YES;
}

@end

@implementation LSMTLURLModel

- (instancetype)init {
	self = [super init];
	if (self == nil) return nil;

	self.URL = [NSURL URLWithString:@"http://github.com"];
	return self;
}

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

@end

@implementation LSMTLBoolModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

@end

@implementation LSMTLStringModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

@end

@implementation LSMTLIDModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [NSDictionary mtl_identityPropertyMapWithModel:self];
}

@end

@implementation LSMTLNonPropertyModel

+ (NSSet *)propertyKeys {
	return [NSSet setWithObject:@"homepage"];
}

- (NSURL *)homepage {
	return [NSURL URLWithString:@"about:blank"];
}

+ (LSMTLPropertyStorage)storageBehaviorForPropertyWithKey:(NSString *)propertyKey {
	if ([propertyKey isEqual:@"homepage"]) {
		return LSMTLPropertyStoragePermanent;
	}

	return [super storageBehaviorForPropertyWithKey:propertyKey];
}

#pragma mark - LSMTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"homepage": @"homepage"
	};
}

@end

@interface LSMTLConformingModel ()

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error;

@end

@implementation LSMTLConformingModel

#pragma mark Lifecycle

+ (instancetype)modelWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
	return [[self alloc] initWithDictionary:dictionaryValue error:error];
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionaryValue error:(NSError **)error {
	self = [super init];
	if (self == nil) return nil;

	_name = dictionaryValue[@"name"];

	return self;
}

- (BOOL)validate:(NSError **)error {
	return YES;
}

#pragma mark LSMTLModel

- (NSDictionary *)dictionaryValue {
	if (self.name == nil) return @{};

	return @{
		@"name": self.name
	};
}

+ (NSSet *)propertyKeys {
	return [NSSet setWithObject:@"name"];
}

- (void)mergeValueForKey:(NSString *)key fromModel:(id<LSMTLModel>)model {
	if ([key isEqualToString:@"name"]) {
		self.name = [model dictionaryValue][@"name"];
	}
}

- (void)mergeValuesForKeysFromModel:(id<LSMTLModel>)model {
	self.name = [model dictionaryValue][@"name"];
}

#pragma mark LSMTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"name": @"name"
	};
}

#pragma mark NSObject

- (NSUInteger)hash {
	return self.name.hash;
}

- (BOOL)isEqual:(LSMTLConformingModel *)model {
	if (self == model) return YES;
	if (![model isMemberOfClass:self.class]) return NO;

	return self.name == model.name || [self.name isEqual:model.name];
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	return self;
}

@end

@implementation LSMTLStorageBehaviorModel

- (id)notIvarBacked {
	return self;
}

@end

@implementation LSMTLStorageBehaviorModelSubclass

@dynamic shadowedInSubclass;

@end

@implementation LSMTLMultiKeypathModel

#pragma mark LSMTLJSONSerializing

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"range": @[ @"location", @"length" ],
		@"nestedRange": @[ @"nested.location", @"nested.length" ]
	};
}

+ (NSValueTransformer *)rangeJSONTransformer {
	return [LSMTLValueTransformer
		transformerUsingForwardBlock:^(NSDictionary *value, BOOL *success, NSError **error) {
			NSUInteger location = [value[@"location"] unsignedIntegerValue];
			NSUInteger length = [value[@"length"] unsignedIntegerValue];

			return [NSValue valueWithRange:NSMakeRange(location, length)];
		} reverseBlock:^(NSValue *value, BOOL *success, NSError **error) {
			NSRange range = value.rangeValue;

			return @{
				@"location": @(range.location),
				@"length": @(range.length)
			};
		}];
}

+ (NSValueTransformer *)nestedRangeJSONTransformer {
	return [LSMTLValueTransformer
		transformerUsingForwardBlock:^(NSDictionary *value, BOOL *success, NSError **error) {
			NSUInteger location = [value[@"nested.location"] unsignedIntegerValue];
			NSUInteger length = [value[@"nested.length"] unsignedIntegerValue];

			return [NSValue valueWithRange:NSMakeRange(location, length)];
		} reverseBlock:^(NSValue *value, BOOL *success, NSError **error) {
			NSRange range = value.rangeValue;

			return @{
				@"nested.location": @(range.location),
				@"nested.length": @(range.length)
			};
		}];
}
@end

@implementation LSMTLClassClusterModel : LSMTLModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"flavor": @"flavor"
	};
}

+ (Class)classForParsingJSONDictionary:(NSDictionary *)JSONDictionary {
	if ([JSONDictionary[@"flavor"] isEqualToString:@"chocolate"]) {
		return LSMTLChocolateClassClusterModel.class;
	}

	if ([JSONDictionary[@"flavor"] isEqualToString:@"strawberry"]) {
		return LSMTLStrawberryClassClusterModel.class;
	}

	return nil;
}

@end

@implementation LSMTLChocolateClassClusterModel : LSMTLClassClusterModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"bitterness": @"chocolate_bitterness"
	}];
}

- (NSString *)flavor {
	return @"chocolate";
}

+ (NSValueTransformer *)bitternessJSONTransformer {
	return [LSMTLValueTransformer
		transformerUsingForwardBlock:^(NSString *string, BOOL *success, NSError **error) {
			NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];

			return [formatter numberFromString:string];
		}
		reverseBlock:^(NSNumber *value, BOOL *success, NSError **error) {
			return [value description];
		}];
}

@end

@implementation LSMTLStrawberryClassClusterModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return [[super JSONKeyPathsByPropertyKey] mtl_dictionaryByAddingEntriesFromDictionary:@{
		@"freshness": @"strawberry_freshness"
	}];
}

- (NSString *)flavor {
	return @"strawberry";
}

@end

@implementation LSMTLOptionalPropertyModel

@end

@implementation LSMTLRecursiveUserModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"name": @"name",
		@"groups": @"groups",
	};
}

+ (NSValueTransformer *)groupsJSONTransformer {
	return [LSMTLJSONAdapter arrayTransformerWithModelClass:LSMTLRecursiveGroupModel.class];
}

@end

@implementation LSMTLRecursiveGroupModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"owner": @"owner",
		@"users": @"users",
	};
}

+ (NSValueTransformer *)ownerJSONTransformer {
	return [LSMTLJSONAdapter dictionaryTransformerWithModelClass:LSMTLRecursiveUserModel.class];
}

+ (NSValueTransformer *)usersJSONTransformer {
	return [LSMTLJSONAdapter arrayTransformerWithModelClass:LSMTLRecursiveUserModel.class];
}

@end

@implementation LSMTLPropertyDefaultAdapterModel

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
	return @{
		@"conformingLSMTLJSONSerializingProperty": @"conformingLSMTLJSONSerializingProperty",
		@"nonConformingLSMTLJSONSerializingProperty": @"nonConformingLSMTLJSONSerializingProperty",
		@"property": @"property"
	};
}

@end
