//
//  AddressBookItem.h
//  ProTime
//
//  Created by Norayr Harutyunyan on 11/21/12.
//  Copyright (c) 2012 BeInteractive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AddressBook/AddressBook.h>

typedef enum Item_Type {
	Item_Type_Unknown,
	Item_Type_Phone_Number,
	Item_Type_EMail
}
Item_Type;

typedef enum Label_Type {
	Label_Type_Unknown,
	Label_Type_Phone_iPhone,
	Label_Type_Phone_Mobile,
    Label_Type_Phone_Work,
    Label_Type_Phone_Home,
	Label_Type_Email_Work,
	Label_Type_Email_Home
}
Label_Type;

@interface AddressBookItem : NSObject {
    Item_Type itemType;
}

- (id) initWithType:(Item_Type)type LabelType:(NSString*)lblType Value:(NSString*)vle;
- (Label_Type)GetMobileLabel:(NSString*)mobileLabel;

@property (nonatomic, strong) NSString *value;
@property (nonatomic, assign) Item_Type itemType;
@property (nonatomic, assign) Label_Type labelType;

@end