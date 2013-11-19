#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, JKSPersonGender) {
    JKSPersonGenderUnknown,
    JKSPersonGenderMale,
    JKSPersonGenderFemale,
};

@interface JKSPerson : NSObject

@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (assign, nonatomic) NSUInteger age;
@property (strong, nonatomic) JKSPerson *parent;
@property (strong, nonatomic) NSArray *siblings;
@property (assign, nonatomic) NSInteger identifier;
@property (strong, nonatomic) NSDate *birthDate;
@property (assign, nonatomic) JKSPersonGender gender;

- (id)initWithFixtureData;

@end
