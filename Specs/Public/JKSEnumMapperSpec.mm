#import "JKSEnumMapper.h"
#import "JKSPerson.h"
#import "JKSError.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSEnumMapperSpec)

describe(@"JKSEnumMapper", ^{
    __block JKSEnumMapper *mapper;
    __block NSError *error;

    beforeEach(^{
        error = nil;
        mapper = JKSEnum(@"dest", @{@(JKSPersonGenderUnknown): @"Unknown",
                                    @(JKSPersonGenderMale): @"Male",
                                    @(JKSPersonGenderFemale): @"Female"});
    });

    it(@"should have the destination key equal to what it was given", ^{
        mapper.destinationKey should equal(@"dest");
    });

    describe(@"parsing the source object", ^{
        __block id sourceObject;
        __block id parsedObject;

        subjectAction(^{
            parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
        });

        context(@"when an enumerable value is provided", ^{
            beforeEach(^{
                sourceObject = @(JKSPersonGenderFemale);
            });

            it(@"should not have any error", ^{
                error should be_nil;
            });

            it(@"should produce the string equivalent", ^{
                parsedObject should equal(@"Female");
            });
        });

        context(@"when an unknown value is provided", ^{
            beforeEach(^{
                sourceObject = @(99);
            });

            it(@"should produce an error", ^{
                error.domain should equal(JKSErrorDomain);
                error.code should equal(JKSErrorInvalidSourceObjectValue);
            });
        });

        context(@"when nil is provided", ^{
            beforeEach(^{
                sourceObject = nil;
            });

            it(@"should not have any error", ^{
                error should_not be_nil;
            });

            it(@"should produce nil", ^{
                parsedObject should be_nil;
            });
        });
    });

    describe(@"reverse mapper", ^{
        beforeEach(^{
            mapper = [mapper reverseMapperWithDestinationKey:@"otherKey"];
        });

        it(@"should have its given key as its new destination key", ^{
            mapper.destinationKey should equal(@"otherKey");
        });

        describe(@"parsing the source object", ^{
            __block id sourceObject;
            __block id parsedObject;

            subjectAction(^{
                parsedObject = [mapper objectFromSourceObject:sourceObject error:&error];
            });

            context(@"when an enumerable value is provided", ^{
                beforeEach(^{
                    sourceObject = @"Female";
                });

                it(@"should not have any error", ^{
                    error should be_nil;
                });

                it(@"should produce the string equivalent", ^{
                    parsedObject should equal(@(JKSPersonGenderFemale));
                });
            });

            context(@"when an unknown value is provided", ^{
                beforeEach(^{
                    sourceObject = @"Pizza";
                });

                it(@"should produce an error", ^{
                    error.domain should equal(JKSErrorDomain);
                    error.code should equal(JKSErrorInvalidSourceObjectValue);
                });
            });

            context(@"when nil is provided", ^{
                beforeEach(^{
                    sourceObject = nil;
                });

                it(@"should not have any error", ^{
                    error should_not be_nil;
                });
                
                it(@"should produce nil", ^{
                    parsedObject should be_nil;
                });
            });
        });
    });
});

SPEC_END