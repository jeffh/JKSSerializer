#import "HYDBlockMapper.h"
#import "HYDFunctions.h"
#import "HYDError.h"
#import "HYDAccessor.h"
#import "HYDIdentityMapper.h"


@interface HYDBlockMapper : NSObject <HYDMapper>

@property (strong, nonatomic) HYDConversionBlock convertBlock;
@property (strong, nonatomic) HYDConversionBlock reverseConvertBlock;

- (id)initWithConvertBlock:(HYDConversionBlock)convertBlock
              reverseBlock:(HYDConversionBlock)reverseConvertBlock;

@end


@implementation HYDBlockMapper

- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithConvertBlock:(HYDConversionBlock)convertBlock reverseBlock:(HYDConversionBlock)reverseConvertBlock
{
    self = [super init];
    if (self) {
        self.convertBlock = convertBlock;
        self.reverseConvertBlock = reverseConvertBlock;
    }
    return self;
}

#pragma mark - <NSObject>

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@>", NSStringFromClass(self.class)];
}

#pragma mark - HYDMapper

- (id)objectFromSourceObject:(id)sourceObject error:(__autoreleasing HYDError **)error
{
    HYDSetObjectPointer(error, nil);
    HYDError *blockError = nil;
    id result = self.convertBlock(sourceObject, &blockError);
    if (blockError) {
        HYDSetObjectPointer(error, [HYDError errorWithCode:blockError.code ?: HYDErrorInvalidSourceObjectValue
                                              sourceObject:blockError.sourceObject
                                            sourceAccessor:blockError.sourceAccessor
                                         destinationObject:blockError.destinationObject
                                       destinationAccessor:nil
                                                   isFatal:blockError.isFatal
                                          underlyingErrors:blockError.underlyingErrors]);
    }
    return result;
}

- (id<HYDMapper>)reverseMapper
{
    return [[[self class] alloc] initWithConvertBlock:self.reverseConvertBlock
                                         reverseBlock:self.convertBlock];
}

@end


HYD_EXTERN_OVERLOADED
HYDBlockMapper *HYDMapWithBlock(HYDConversionBlock convertBlock)
{
    return HYDMapWithBlock(convertBlock, convertBlock);
}

HYD_EXTERN_OVERLOADED
HYDBlockMapper *HYDMapWithBlock(HYDConversionBlock convertBlock, HYDConversionBlock reverseConvertBlock)
{
    return [[HYDBlockMapper alloc] initWithConvertBlock:convertBlock
                                           reverseBlock:reverseConvertBlock];
}
