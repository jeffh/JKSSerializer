#import "HYDBase.h"
#import "HYDMapper.h"

typedef NSString *(^KeyTransformBlock)(NSString *propertyName);

@interface HYDReflectiveMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)innerMapper
         sourceClass:(Class)sourceClass
    destinationClass:(Class)destinationClass;

@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^mapClass)(Class destinationClass, id<HYDMapper> mapper);
@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^optional)(NSArray *propertyNames);
@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^excluding)(NSArray *propertyNames);
@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^overriding)(NSDictionary *mappingOverrides);
@property (weak, nonatomic, readonly) HYDReflectiveMapper *(^keyTransformer)(NSValueTransformer *keyTransformer);

@end

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(id<HYDMapper> innerMapper, Class sourceClass, Class destinationClass)
HYD_REQUIRE_NON_NIL(2,3);

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(id<HYDMapper> innerMapper, Class destinationClass)
HYD_REQUIRE_NON_NIL(2);

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(NSString *destinationKey, Class sourceClass, Class destinationClass)
HYD_REQUIRE_NON_NIL(2,3);

HYD_EXTERN_OVERLOADED
HYDReflectiveMapper *HYDMapReflectively(NSString *destinationKey, Class destinationClass)
HYD_REQUIRE_NON_NIL(2);