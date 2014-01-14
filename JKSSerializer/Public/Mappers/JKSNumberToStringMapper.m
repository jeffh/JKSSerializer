#import "JKSNumberToStringMapper.h"
#import "JKSError.h"
#import "JKSStringToNumberMapper.h"

@interface JKSNumberToStringMapper ()
@property (strong, nonatomic) NSNumberFormatter *numberFormatter;
@end

@implementation JKSNumberToStringMapper

#pragma mark - <JKSFieldMapper>

- (id)initWithDestinationKey:(NSString *)destinationKey numberFormatter:(NSNumberFormatter *)numberFormatter
{
    self = [super init];
    if (self) {
        self.destinationKey = destinationKey;
        self.numberFormatter = numberFormatter;
    }
    return self;
}

- (id)objectFromSourceObject:(id)sourceObject error:(NSError *__autoreleasing *)error
{
    id value = [self.numberFormatter stringFromNumber:sourceObject];

    if (!value && sourceObject) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidSourceObjectValue
                                   sourceObject:sourceObject
                                       byMapper:self];
    }
    return value;
}

- (id)objectFromSourceObject:(id)sourceObject toClass:(Class)dstClass error:(NSError *__autoreleasing *)error
{
    id value = [self objectFromSourceObject:sourceObject error:error];
    if (value && ![[value class] isSubclassOfClass:dstClass]) {
        *error = [JKSError mappingErrorWithCode:JKSErrorInvalidResultingObjectType
                                   sourceObject:sourceObject
                                       byMapper:self];
        return nil;
    }
    return value;
}

- (void)setupAsChildMapperWithMapper:(id<JKSMapper>)mapper factory:(id<JKSFactory>)factory
{
}

- (id<JKSMapper>)reverseMapperWithDestinationKey:(NSString *)destinationKey
{
    return [[JKSStringToNumberMapper alloc] initWithDestinationKey:destinationKey numberFormatter:self.numberFormatter];
}

@end


JKS_EXTERN
JKSNumberToStringMapper *JKSNumberToString(NSString *destKey, NSNumberFormatterStyle numberFormatStyle)
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    numberFormatter.numberStyle = numberFormatStyle;
    return [[JKSNumberToStringMapper alloc] initWithDestinationKey:destKey numberFormatter:numberFormatter];
}