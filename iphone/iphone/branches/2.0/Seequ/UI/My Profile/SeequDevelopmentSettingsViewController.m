//
//  SeequDevelopmentSettingsViewController.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 12/30/13.
//  Copyright (c) 2013 Doubango Telecom. All rights reserved.
//

#import "SeequDevelopmentSettingsViewController.h"
#import "SeequSwitchWithTitleCell.h"
#import "BackBarButton.h"
#import "Common.h"





@interface SeequDevelopmentSettingsViewController ()<UITextFieldDelegate>{
    NSArray*  dataArray;
    BOOL  isDevelopment;
    BOOL  isRTMP_Debugging;
    BOOL  isTomcatDebugging;
}

@property (nonatomic,retain) NSString*  RTMPServer;
@property (nonatomic,retain) NSString*  SIPServer;
@property (nonatomic,retain) NSString*  TomcatServer;
@property (nonatomic,retain) NSString*  transportType;


@end

@implementation SeequDevelopmentSettingsViewController

@synthesize RTMPServer;
@synthesize TomcatServer;
@synthesize transportType;
@synthesize SIPServer;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        isDevelopment = NO;
        isRTMP_Debugging = NO;
        isTomcatDebugging = NO;
        NSArray* firstSection = [NSArray arrayWithObject:@"Developer"];
        NSArray* secondSection = [NSArray arrayWithObjects:@"Debugging Mode",@"RTMP", @"SIP", nil];
        NSArray* thirdSection = [NSArray arrayWithObjects:@"Debugging Mode",@"Tomcat", nil];
        NSArray* fourthSection = [NSArray arrayWithObjects:@"RTMP",@"XMPP", nil];

        dataArray = [NSArray arrayWithObjects: firstSection,secondSection,thirdSection,fourthSection, nil];
    }
    return self;
}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) textFieldDidEndEditing:(UITextField *)textField {
    switch (textField.tag) {
        case 1001:
            self.RTMPServer = textField.text;
            break;
        case 1002:
            self.SIPServer = textField.text;
            break;
        case 1003:
            self.TomcatServer = textField.text;
            break;
        default:
            break;
    }
}
- (void) onButtonSave:(id)sender {
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];

    [userDef setBool:isDevelopment forKey:DEVELOPER_MODE];
     [userDef setBool:isRTMP_Debugging forKey:RTMP_DEBUG];
    [userDef setBool:isTomcatDebugging forKey:TOMCAT_DEBUG];
    if (isRTMP_Debugging) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:1];
        SeequSwitchWithTitleCell* cell = (SeequSwitchWithTitleCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        [userDef setValue:cell.textField.text forKey:RTMP_SERVER];
        indexPath = [NSIndexPath indexPathForRow:2 inSection:1];
         cell = (SeequSwitchWithTitleCell*) [self.tableView cellForRowAtIndexPath:indexPath];

        [userDef setValue:cell.textField.text forKey:SIP_SERVER];
    }
    if (isTomcatDebugging) {
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:1 inSection:2];
        SeequSwitchWithTitleCell* cell = (SeequSwitchWithTitleCell*) [self.tableView cellForRowAtIndexPath:indexPath];
        [userDef setValue:cell.textField.text forKey:TOMCAT_SERVER];

    }
    [userDef setValue:transportType forKey:XMPP_TRANSPORT];

    [userDef synchronize];
    [self.navigationController popViewControllerAnimated:YES];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"SeequSwitchWithTitleCell"
                                               bundle:[NSBundle mainBundle]]
         forCellReuseIdentifier:@"SwitchCell"]; 
    self.navigationItem.title = @"Development";
    BackBarButton *backBarButton = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequBackButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(GoBack:)];
    self.navigationItem.leftBarButtonItem = backBarButton;
    BackBarButton *barButtonSave = [[BackBarButton alloc] initWithImage:[UIImage imageNamed:@"defaultSeequSaveButton.png"]
                                                                  style:UIBarButtonItemStylePlain
                                                                 target:self
                                                                 action:@selector(onButtonSave:)];
    self.navigationItem.rightBarButtonItem = barButtonSave;
    
    
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    isDevelopment       = [userDef boolForKey:DEVELOPER_MODE];
    isRTMP_Debugging    = [userDef boolForKey:RTMP_DEBUG];
    isTomcatDebugging   = [userDef boolForKey:TOMCAT_DEBUG];
    NSString* tempString = [userDef stringForKey:RTMP_SERVER];
    self.RTMPServer = tempString ? tempString:@"10.20.0.13";
    tempString = [userDef stringForKey:SIP_SERVER];
    self.SIPServer = tempString ? tempString:@"10.20.0.22";
    tempString = [userDef stringForKey:XMPP_TRANSPORT];

    self.transportType = tempString?tempString:@"RTMP";
    tempString = [userDef stringForKey:TOMCAT_SERVER];
    self.TomcatServer = tempString? tempString:@"192.168.0.250";
    
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 1;
        case 1:
            return 3;
        case 2:
            return 2;
        case 3:
            return 2;
            
        default:
            return 0;
    }
    
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section ) {
        return 44;

    }
    return 0;
}


-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
 
        case 1:
            return @"RTMP and SIP server";
        case 2:
            return @"Tomcat server";
        case 3:
            return @"XMPP transport";
        default:
            return @"";
    }[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];

}
-(void) enableDevelopment:(id)sender {
    UISwitch* switcher = (UISwitch*) sender;
 
    isDevelopment = switcher.isOn;
    
 
    [self.tableView reloadData];
}

-(void) enableRTMP_SIP:(id)sender {
    UISwitch* switcher = (UISwitch*) sender;
    
    
    isRTMP_Debugging =switcher.isOn;
 
    [self.tableView reloadData];
}


-(void) enableTomcat:(id)sender {
    UISwitch* switcher = (UISwitch*) sender;
    isTomcatDebugging = switcher.isOn;
    [self.tableView reloadData];
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SwitchCell";
    
    SeequSwitchWithTitleCell *cell = (SeequSwitchWithTitleCell*)[tableView
                                    dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.title.text = [[dataArray objectAtIndex: indexPath.section] objectAtIndex:indexPath.row];
    cell.textField.delegate = self;

    switch (indexPath.section) {
        case 0:{
            cell.isEditable = NO;
            cell.switcher.on = isDevelopment;
            [cell.switcher addTarget:self action:@selector(enableDevelopment:) forControlEvents:UIControlEventValueChanged];
             cell.accessoryType =UITableViewCellAccessoryNone;
        }
            break;
        case 1:{
            cell.userInteractionEnabled = isDevelopment;
            cell.isEditable = indexPath.row !=0;
            cell.switcher.on = isRTMP_Debugging;
            cell.textField.enabled = isRTMP_Debugging;
            if (indexPath.row == 1) {
                cell.textField.text = isRTMP_Debugging?self.RTMPServer:@"uvc.protime.tv";
                cell.textField.tag = 1001;

            } else if(indexPath.row == 2){
                cell.textField.text = isRTMP_Debugging?self.SIPServer:@"sip.protime.tv";
                cell.textField.tag = 1002;

            }
            [cell.switcher addTarget:self action:@selector(enableRTMP_SIP:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 2:{
            cell.userInteractionEnabled = isDevelopment;
            cell.isEditable = indexPath.row !=0;
        
            cell.switcher.on = isTomcatDebugging;
            cell.textField.enabled = isTomcatDebugging;
            cell.textField.text = isTomcatDebugging?self.TomcatServer:@"tommy.protime.tv";
            cell.textField.tag =1003;

            [cell.switcher addTarget:self action:@selector(enableTomcat:) forControlEvents:UIControlEventValueChanged];
        }
            break;
        case 3:{
            cell.userInteractionEnabled = isDevelopment;
            cell.isEditable = YES;
            cell.textField.enabled = NO;
//            NSString* str = [userDef stringForKey:XMPP_TRANSPORT];
//            if (!str) {
//                str = @"RTMP";
//                [userDef setValue:@"RTMP" forKey:XMPP_TRANSPORT];
//            }
            cell.accessoryType =[self.transportType isEqualToString:cell.title.text]? UITableViewCellAccessoryCheckmark:UITableViewCellAccessoryNone;
        }
            break;
            
            
        default:
            cell.isEditable = NO;

    }
    
    return cell;
}




#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 3) {
        self.transportType = [transportType isEqualToString:@"RTMP"]? @"XMPP":@"RTMP";
   
        [self.tableView reloadData];
    }
}

@end
