//
//  XBAddressBookManger.m
//  AnXin
//
//  Created by 谢贤彬 on 2018/3/6.
//  Copyright © 2018年 xxb. All rights reserved.
//

#import "XBAddressBookManger.h"

@implementation XBAddressBookManger

+ (instancetype)shared
{
    return [self new];
}
+ (instancetype)allocWithZone:(struct _NSZone *)zone
{
    static id manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [super allocWithZone:zone];
    });
    return manager;
}
- (instancetype)init
{
    if (self = [super init])
    {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            self.arrM_contact = [NSMutableArray new];
            [self getAddressBookInfo];
        });
    }
    return self;
}


- (void)getAddressBookInfo
{
    //    if (IOS9 == NO)
    {
        //这个变量用于记录授权是否成功，即用户是否允许我们访问通讯录
        int __block tip = 0;
        //声明一个通讯簿的引用
        ABAddressBookRef addBook = nil;
        
        //创建通讯簿的引用
        addBook = ABAddressBookCreateWithOptions(NULL, NULL);
        //创建一个出事信号量为0的信号
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        //申请访问权限
        ABAddressBookRequestAccessWithCompletion(addBook, ^(bool greanted, CFErrorRef error)        {
            //greanted为YES是表示用户允许，否则为不允许
            if (!greanted) {
                tip = 1;
            }
            //发送一次信号
            dispatch_semaphore_signal(sema);
        });
        //等待信号触发
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        
        if (tip) {
            //做一个友好的提示
            UIAlertView * alart = [[UIAlertView alloc]initWithTitle:@"温馨提示" message:@"请您设置允许APP访问您的通讯录\nSettings>General>Privacy" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alart show];
            return;
        }
        
        //获取所有联系人的数组
        CFArrayRef allLinkPeople = ABAddressBookCopyArrayOfAllPeople(addBook);
        //获取联系人总数
        CFIndex number = ABAddressBookGetPersonCount(addBook);
        //进行遍历
        for (int i = 0; i < number; i++)
        {
            //获取联系人对象的引用
            ABRecordRef  people = CFArrayGetValueAtIndex(allLinkPeople, i);
            
            //获取当前联系人名字
            NSString * firstName = (__bridge NSString *)(ABRecordCopyValue(people, kABPersonFirstNameProperty));
            //获取当前联系人姓氏
            NSString * lastName=(__bridge NSString *)(ABRecordCopyValue(people, kABPersonLastNameProperty));
            
            //获取当前联系人的名字拼音
            //            NSString * firstNamePhoneic=(__bridge NSString*)(ABRecordCopyValue(people, kABPersonFirstNamePhoneticProperty));
            
            //获取当前联系人的备注
            //            NSString * notes = (__bridge NSString*)(ABRecordCopyValue(people, kABPersonNoteProperty));
            
            //获取当前联系人的电话 数组
            NSMutableArray * phoneArr = [[NSMutableArray alloc]init];
            ABMultiValueRef phones= ABRecordCopyValue(people, kABPersonPhoneProperty);
            for (NSInteger j = 0; j < ABMultiValueGetCount(phones); j++) {
                [phoneArr addObject:(__bridge NSString *)(ABMultiValueCopyValueAtIndex(phones, j))];
            }
            
            //获取当前联系人头像图片
            //            NSData * userImage=(__bridge NSData*)(ABPersonCopyImageData(people));
            
            
            NSString *userName = nil;
            if (firstName.length && lastName.length)
            {
                userName = [lastName stringByAppendingString:firstName];
            }
            else if (firstName.length)
            {
                userName = firstName;
            }
            else
            {
                userName = lastName;
            }
            userName = [userName stringByReplacingOccurrencesOfString:@" " withString:@""];
            
            NSString *userPhone = nil;
            if (phoneArr.count > 0)
            {
                userPhone = phoneArr[0];
                userPhone = [userPhone stringByReplacingOccurrencesOfString:@" " withString:@""];
                userPhone = [userPhone stringByReplacingOccurrencesOfString:@"-" withString:@""];
                userPhone = [userPhone stringByReplacingOccurrencesOfString:@"+86" withString:@""];
            }
            
            if (userPhone.length && userName.length)
            {
                NSDictionary *contactInfoDic = @{contactKey_Name:userName,contactKey_Phone:userPhone};
                [self.arrM_contact addObject:contactInfoDic];
            }
            
            //            NSLog(@"firstName:%@,lastName:%@,firstNamePhoneic:%@,notes:%@,phoneArr:%@,userImage:%@",firstName,lastName,firstNamePhoneic,notes,phoneArr,userImage);
        }
    }
    
}
@end

