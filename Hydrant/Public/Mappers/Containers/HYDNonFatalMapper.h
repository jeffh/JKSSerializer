#import "HYDMapper.h"
#import "HYDBase.h"


@class HYDObjectFactory;

typedef id(^HYDValueBlock)();


@interface HYDNonFatalMapper : NSObject <HYDMapper>

- (id)initWithMapper:(id<HYDMapper>)mapper defaultValue:(HYDValueBlock)defaultValue reverseDefaultValue:(HYDValueBlock)reverseDefaultValue;

@end


HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatally(id<HYDMapper> mapper)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatally(NSString *destinationKey)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefault(id<HYDMapper> mapper, id defaultValue)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefault(NSString *destinationKey, id defaultValue)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefault(id<HYDMapper> mapper, id defaultValue, id reversedDefault)
HYD_REQUIRE_NON_NIL(1);

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory)
HYD_REQUIRE_NON_NIL(1,2);

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefaultFactory(NSString *destinationKey, HYDValueBlock defaultValueFactory)
HYD_REQUIRE_NON_NIL(1,2);

HYD_EXTERN_OVERLOADED
HYDNonFatalMapper *HYDMapNonFatallyWithDefaultFactory(id<HYDMapper> mapper, HYDValueBlock defaultValueFactory, HYDValueBlock reversedDefaultFactory)
HYD_REQUIRE_NON_NIL(1,2,3);