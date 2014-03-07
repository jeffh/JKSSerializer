#import "Hydrant.h"
#import "HYDSFakeMapper.h"
#import "HYDDefaultAccessor.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SHARED_EXAMPLE_GROUPS_BEGIN(HYDSharedMapperExamplesSpec)

sharedExamplesFor(@"a mapper that does the inverse of the original", ^(NSDictionary *scope) {
    __block id<HYDMapper> mapper;
    __block NSArray *childMappers;
    __block id sourceObject;
    __block id<HYDAccessor> reverseAccessor;

    beforeEach(^{
        mapper = scope[@"mapper"];
        sourceObject = scope[@"sourceObject"];
        childMappers = scope[@"childMappers"];

        reverseAccessor = scope[@"reverseAccessor"] ?: HYDAccessDefault(@"otherKey");
    });

    __block HYDError *error;
    __block id<HYDMapper> reverseMapper;

    beforeEach(^{
        error = nil;
        reverseMapper = [mapper reverseMapperWithDestinationAccessor:reverseAccessor];
    });

    it(@"should have the given key as its new destination key", ^{
        reverseMapper.destinationAccessor should equal(reverseAccessor);
    });

    it(@"should invert all its child mappers", ^{
        for (HYDSFakeMapper *childMapper in childMappers) {
            childMapper.reverseMapperDestinationAccessorReceived should equal([childMapper.reverseMapperToReturn destinationAccessor]);
        }
    });

    it(@"should be the inverse of the current mapper", ^{
        id parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        error should be_nil;

        id result = [reverseMapper objectFromSourceObject:parsedObject error:&error];
        error should be_nil;

        result should equal(sourceObject);
    });
});

sharedExamplesFor(@"a mapper that converts from one value to another", ^(NSDictionary *scope) {
    __block id<HYDMapper> mapper;
    __block id validSourceObject;
    __block id invalidSourceObject;
    __block id expectedParsedObject;
    __block NSString *destinationKey;

    beforeEach(^{
        mapper = scope[@"mapper"];
        destinationKey = scope[@"destinationAccessor"];
        validSourceObject = scope[@"validSourceObject"];
        invalidSourceObject = scope[@"invalidSourceObject"];
        expectedParsedObject = scope[@"expectedParsedObject"];
    });

    __block id sourceObject;
    __block id parsedObject;
    __block HYDError *error;

    it(@"should report the same destination key", ^{
        [mapper destinationAccessor] should equal(HYDAccessDefault(destinationKey));
    });

    describe(@"parsing the source object", ^{
        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when a valid source object is provided", ^{
            beforeEach(^{
                sourceObject = validSourceObject;
            });

            it(@"should produce a value parsed object", ^{
                parsedObject should equal(expectedParsedObject);
            });

            it(@"should return a nil error", ^{
                error should be_nil;
            });
        });

        context(@"when invalid source object is provided", ^{
            beforeEach(^{
                sourceObject = invalidSourceObject;
            });

            it(@"should provide a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
                error.userInfo[HYDDestinationAccessorKey] should equal(HYDAccessDefault(destinationKey));
            });

            it(@"should return nil", ^{
                parsedObject should be_nil;
            });
        });

        context(@"when nil is provided", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should produce nil", ^{
                parsedObject should be_nil;
            });

            it(@"should produce a fatal error", ^{
                error should be_a_fatal_error.with_code(HYDErrorInvalidSourceObjectValue);
                error.userInfo[HYDDestinationAccessorKey] should equal(HYDAccessDefault(destinationKey));
            });
        });
    });

    describe(@"errornously parsing an object without an error pointer", ^{
        it(@"should not explode", ^{
            sourceObject = invalidSourceObject;
            [mapper objectFromSourceObject:sourceObject error:nil];
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            [SpecHelper specHelper].sharedExampleContext[@"mapper"] = mapper;
            [SpecHelper specHelper].sharedExampleContext[@"sourceObject"] = validSourceObject;
        });

        itShouldBehaveLike(@"a mapper that does the inverse of the original");
    });
});

SHARED_EXAMPLE_GROUPS_END
