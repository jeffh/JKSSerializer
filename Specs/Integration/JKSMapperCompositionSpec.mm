// DO NOT any other library headers here to simulate an API user.
#import "JKSSerializer.h"
#import "JKSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSMapperCompositionSpec)

xdescribe(@"Mapper Composition", ^{
    __block id<JKSMapper> mapper;
    __block JKSPerson *expectedObjectGraph;
    __block NSDictionary *expectedObjectStructure;
    __block JKSError *error;
    __block id parsedObject;

    beforeEach(^{
        JKSDotNetDateFormatter *dotNetDateFormatter = [[JKSDotNetDateFormatter alloc] init];

        mapper = JKSMapKeyValuesTo(nil, [NSDictionary class], [JKSPerson class],
                                   @{@"person": JKSMapKeyValuePathsTo(@"parent", [NSDictionary class], [JKSPerson class],
                                                                      @{@"id": @"identifier",
                                                                        @"name.first": @"firstName",
                                                                        @"name.last": @"lastName",
                                                                        @"age": JKSStringToNumber(@"age"),
                                                                        @"birth_date": JKSStringToDateWithFormatter(@"birthDate", dotNetDateFormatter)}),
                                     @"identifier": JKSOptional([[JKSIdentityMapper alloc] initWithDestinationKey:@"identifier"]),
                                     @"gender": JKSEnum(@"gender", @{@"unknown": @(JKSPersonGenderUnknown),
                                                                     @"male": @(JKSPersonGenderMale),
                                                                     @"female": @(JKSPersonGenderFemale)})});
        expectedObjectStructure = @{@"person": @{@"id": @1,
                                                 @"name": @{@"first": @"John",
                                                            @"last": @"Doe"},
                                                 @"age": @"22",
                                                 @"birth_date": @"/Date(1390186634595)/"},
                                    @"identifier": @42,
                                    @"gender": @"male"};
        expectedObjectGraph = [[JKSPerson alloc] init];
        expectedObjectGraph.identifier = 42;
        expectedObjectGraph.gender = JKSPersonGenderMale;
        expectedObjectGraph.parent = ({
            JKSPerson *parent = [[JKSPerson alloc] init];
            parent.identifier = 1;
            parent.firstName = @"John";
            parent.lastName = @"Doe";
            parent.age = 22;
            parent.birthDate = [NSDate dateWithTimeIntervalSince1970:1390186634.595];
            parent;
        });
    });

    describe(@"mapping from dictionaries to an object graph", ^{
        beforeEach(^{
            parsedObject = [mapper objectFromSourceObject:expectedObjectStructure error:&error];
        });

        it(@"should not error", ^{
            NSLog(@"================> %@", error);
            error should be_nil;
        });

        it(@"should map json correctly", ^{
            parsedObject should equal(expectedObjectGraph);
        });
    });

});

SPEC_END
