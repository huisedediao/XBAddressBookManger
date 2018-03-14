//
//  XBAddressBookManger.h
//  AnXin
//
//  Created by 谢贤彬 on 2018/3/6.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import <Foundation/Foundation.h>

///ios9之前
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>

@interface XBAddressBookManger : NSObject <ABPeoplePickerNavigationControllerDelegate>
+ (instancetype)shared;
@property (nonatomic,strong) NSMutableArray *arrM_contact;
@end
