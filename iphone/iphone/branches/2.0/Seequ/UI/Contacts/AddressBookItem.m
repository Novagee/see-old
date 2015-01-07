//
//  AddressBookItem.m
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/21/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import "AddressBookItem.h"

@implementation AddressBookItem

@synthesize value;
@synthesize itemType;
@synthesize labelType;

- (id) initWithType:(Item_Type)type LabelType:(NSString*)lblType Value:(NSString*)vle {
    self = [super init];
    
    if (self) {
        self.value = [vle stringByReplacingOccurrencesOfString:@" " withString:@""];
        self.itemType = type;
        
        if ([lblType isEqualToString:@"Work"]) {
            self.labelType = Label_Type_Email_Work;
        } else {
            self.labelType = [self GetMobileLabel:lblType];
        }
        
        if (self.itemType == Item_Type_Phone_Number) {
            self.value = [self.value stringByReplacingOccurrencesOfString:@" " withString:@""];
            self.value = [self.value stringByReplacingOccurrencesOfString:@")" withString:@""];
            self.value = [self.value stringByReplacingOccurrencesOfString:@"(" withString:@""];
            self.value = [self.value stringByReplacingOccurrencesOfString:@"-" withString:@""];
        }
    }
    
    return self;
}

- (Label_Type)GetMobileLabel:(NSString*)mobileLabel {
    if([mobileLabel isEqualToString:(NSString *)kABPersonPhoneMobileLabel]) {
        return Label_Type_Phone_Mobile;
    } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneIPhoneLabel]) {
        return Label_Type_Phone_iPhone;
    } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneWorkFAXLabel]) {
        return Label_Type_Phone_Work;
    } else if ([mobileLabel isEqualToString:(NSString*)kABPersonPhoneHomeFAXLabel]) {
        return Label_Type_Phone_Home;
    }
    
    NSRange range = [mobileLabel rangeOfString:@"Home"];
    if (range.location != NSNotFound) {
        return  Label_Type_Phone_Home;
    } else {
        range = [mobileLabel rangeOfString:@"Work"];
        if (range.location != NSNotFound) {
            return  Label_Type_Phone_Work;
        }
    }
    
    return  Label_Type_Unknown;
}

@end