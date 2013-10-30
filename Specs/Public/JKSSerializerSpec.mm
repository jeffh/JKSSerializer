#import "JKSSerializer.h"
#import "JKSPerson.h"

using namespace Cedar::Matchers;
using namespace Cedar::Doubles;

SPEC_BEGIN(JKSSerializerSpec)

describe(@"JKSSerializer", ^{
    __block JKSSerializer *serializer;
    __block JKSPerson *person;

    beforeEach(^{
        person = [[[JKSPerson alloc] initWithFixtureData] autorelease];
        serializer = [[[JKSSerializer alloc] init] autorelease];
    });

    // TODO: needs tests
    it(@"should be able to parse multiple kinds of classes from a dictionary by its keys", PENDING);

    describe(@"deserialize nested structure as one", ^{
        beforeEach(^{
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"firstName": @"user.first",
                                                @"lastName": @"user.last"}];
        });

        it(@"should serialize", ^{
            NSDictionary *output = [serializer objectFromObject:person];
            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"user": @{@"first": @"John",
                                             @"last": @"Doe"}});
        });

        it(@"should deserialize", ^{
            NSDictionary *input = @{@"user": @{@"first": @"James",
                                               @"last": @"Taylor"}};
            person = [serializer objectOfClass:[JKSPerson class] fromObject:input];

            JKSPerson *expectedPerson = [[JKSPerson new] autorelease];
            expectedPerson.firstName = @"James";
            expectedPerson.lastName = @"Taylor";
            person should equal(expectedPerson);
        });
    });

    describe(@"different serialization / deserialization", ^{
        beforeEach(^{
            [serializer serializeClass:[JKSPerson class]
                               toClass:[NSDictionary class]
                           withMapping:@{@"firstName": @"first",
                                         @"lastName": @"last"}];
            [serializer serializeClass:[NSDictionary class]
                               toClass:[JKSPerson class]
                           withMapping:@{@"f": @"firstName",
                                         @"l": @"lastName"}];
        });

        it(@"should serialize", ^{
            NSMutableDictionary *output = [serializer objectFromObject:person];
            output should equal(@{@"first": @"John",
                                  @"last": @"Doe"});
        });

        it(@"should deserialize", ^{
            NSDictionary *input = @{@"f": @"James",
                                    @"l": @"Taylor"};
            person = [serializer objectFromObject:input];

            JKSPerson *expectedPerson = [[JKSPerson new] autorelease];
            expectedPerson.firstName = @"James";
            expectedPerson.lastName = @"Taylor";
            person should be_instance_of([JKSPerson class]);
            person should equal(expectedPerson);
        });
    });

    describe(@"basic serialization", ^{
        beforeEach(^{
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"firstName": @"first",
                                                @"lastName": @"last",
                                                @"age": @"age",
                                                @"parent": @"parent"}];
        });

        it(@"should serialize basic properties", ^{
            serializer.nullObject = [NSNull null];
            NSMutableDictionary *output = [serializer objectFromObject:person];

            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"first": @"John",
                                  @"last": @"Doe",
                                  @"age": @23,
                                  @"parent": [NSNull null]});
        });

        it(@"should deserialize basic properties", ^{
            NSDictionary *input = @{@"first": @"John",
                                    @"last": @"Doe",
                                    @"age": @23,
                                    @"parent": [NSNull null]};
            JKSPerson *outputPerson = [serializer objectFromObject:input];

            outputPerson should be_instance_of([JKSPerson class]);
            outputPerson should equal(person);
        });
    });

    describe(@"collection serialization", ^{
        beforeEach(^{
            person.siblings = @[[[[JKSPerson alloc] initWithFixtureData] autorelease],
                                [[[JKSPerson alloc] initWithFixtureData] autorelease]];
            serializer.nullObject = [NSNull null];
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"firstName": @"first",
                                                @"siblings": JKSArrayOf(@"siblings", [JKSPerson class], [NSDictionary class])}];
        });

        it(@"should serialize collections", ^{
            NSMutableDictionary *output = [serializer objectFromObject:person];

            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"first": @"John",
                                  @"siblings": @[@{@"first": @"John", @"siblings": [NSNull null]},
                                                 @{@"first": @"John", @"siblings": [NSNull null]}]});
        });

        it(@"should deserialize collections", ^{
            serializer.nullObject = nil;
            JKSPerson *outputPerson = [serializer objectFromObject:@{@"first": @"John",
                                                                     @"siblings": @[@{@"first": @"John", @"siblings": [NSNull null]},
                                                                                    @{@"first": @"John", @"siblings": [NSNull null]}]}];

            JKSPerson *expectedPerson = [[[JKSPerson alloc] init] autorelease];
            expectedPerson.firstName = @"John";
            JKSPerson *sibling1 = [[[JKSPerson alloc] init] autorelease];
            sibling1.firstName = @"John";
            JKSPerson *sibling2 = [[[JKSPerson alloc] init] autorelease];
            sibling2.firstName = @"John";
            expectedPerson.siblings = @[sibling1, sibling2];

            outputPerson should equal(expectedPerson);
        });
    });

    describe(@"relationship serialization", ^{
        __block JKSPerson *parent;
        beforeEach(^{
            parent = [[[JKSPerson alloc] init] autorelease];
            parent.firstName = @"James";
            parent.lastName = @"Taylor";
            parent.age = 11;
            person.parent = parent;
            serializer.nullObject = [NSNull null];
            [serializer serializeBetweenClass:[JKSPerson class]
                                     andClass:[NSDictionary class]
                                  withMapping:@{@"firstName": @"first",
                                                @"lastName": @"last",
                                                @"age": @"age",
                                                @"parent": JKSDictionaryRelation(@"aParent", [JKSPerson class])}];
        });

        it(@"should recursively serialize", ^{
            NSMutableDictionary *output = [serializer objectFromObject:person];

            output should be_instance_of([NSDictionary class]).or_any_subclass();
            output should equal(@{@"first": @"John",
                                  @"last": @"Doe",
                                  @"age": @23,
                                  @"aParent": @{@"first": @"James",
                                                @"last": @"Taylor",
                                                @"age": @11,
                                                @"aParent": [NSNull null]}});
        });

        it(@"should recursively deserialize", ^{
            serializer.nullObject = nil;
            NSDictionary *input = @{@"first": @"John",
                                    @"last": @"Doe",
                                    @"age": @23,
                                    @"aParent": @{@"first": @"James",
                                                  @"last": @"Taylor",
                                                  @"age": @11,
                                                  @"aParent": [NSNull null]}};
            JKSPerson *outputPerson = [serializer objectFromObject:input];

            outputPerson should be_instance_of([JKSPerson class]);
            outputPerson should equal(person);
        });
    });
});

SPEC_END
