#import "HYDReversedValueTransformer.h"


@interface HYDReversedValueTransformer ()

@property (strong, nonatomic) NSValueTransformer *valueTransformer;

@end


@implementation HYDReversedValueTransformer

- (id)initWithValueTransformer:(NSValueTransformer *)valueTransformer
{
    self = [super init];
    if (self) {
        self.valueTransformer = valueTransformer;
    }
    return self;
}

- (id)transformedValue:(id)value
{
    return [self.valueTransformer reverseTransformedValue:value];
}

- (id)reverseTransformedValue:(id)value
{
    return [self.valueTransformer transformedValue:value];
}

@end