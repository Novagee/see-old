//
//  SeequBillingViewController.m
//  ProTime
//
//  Created by Levon Nikoghosyan on 8/28/14.
//  Copyright (c) 2014 Doubango Telecom. All rights reserved.
//

#import "SeequBillingViewController.h"
#import "BackBarButton.h"
#import "Common.h"
#import "ContactStorage.h"
#import "UserInfoCoreData.h"
#import "CJSONSerializer.h"

@interface SeequBillingViewController ()
@property (nonatomic,retain) UILabel* billingLabel;
@property (nonatomic,retain) UILabel* rateLabel;
@property (nonatomic,retain) UISwitch* billingSwitch;
@property (nonatomic,retain) UITextField *rateText;
@property (nonatomic,retain) UILabel* balanceLabel;
@property (nonatomic,retain) UILabel* balanceValue;
@property (nonatomic,retain) UIActivityIndicatorView* activity;

@end

@implementation SeequBillingViewController

@synthesize billingLabel = _billingLabel;
@synthesize billingSwitch = _billingSwitch;
@synthesize rateLabel = _rateLabel;
@synthesize rateText = _rateText;
@synthesize balanceLabel = _balanceLabel;
@synthesize balanceValue = _balanceValue;
@synthesize  activity = _activity;

- (void)viewDidLoad
{
    [super viewDidLoad];
    if(IS_IOS_7){
        self.edgesForExtendedLayout=UIRectEdgeNone;
    }

    
    
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"Billing Settings";
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
 //   [self createControls];
    UserInfoCoreData* info =[[ContactStorage sharedInstance] getUserInfoBySeequId:[Common sharedCommon].contactObject.SeequID];
    _rateText.enabled = ([info.billingRate floatValue] != 0);
    _rateText.text = [NSString localizedStringWithFormat:@"%.2f", [info.billingRate floatValue]];
    [_billingSwitch setOn:([info.billingRate floatValue]!= 0)];
    self.view.backgroundColor = [UIColor colorWithRed:.95 green:.95 blue:.95 alpha:1];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Billing"];
    [_activity startAnimating];
    [self performSelectorInBackground:@selector(getBalance) withObject:nil];
 }

-(void) getBalance{
    [ Common getUserBalance:^(NSMutableDictionary *dict) {
        _balanceValue.text = [NSString stringWithFormat:@"%@",[dict objectForKey:@"balance"] ];
        [_activity stopAnimating];

        [self.tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES ];
    }];

}

- (void) GoBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void) onButtonSave:(id)sender {
    if(![Common updateRate:_rateText.text]) {
        [[ContactStorage sharedInstance] updateRate:_rateText.text];
        NSMutableDictionary *catched_Dict = [NSMutableDictionary dictionaryWithDictionary:[Common GetLastCatchedInfoWithSeequID:[Common sharedCommon].contactObject.SeequID]];
        NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithDictionary:[catched_Dict objectForKey:@"rateData"]];
        [dic setValue:[NSNumber numberWithFloat:[_rateText.text floatValue]] forKey:@"rate"];
        [catched_Dict setObject:dic forKey:@"rateData"];
        NSString *userdetail_key = [NSString stringWithFormat:@"userdetail%@", [Common sharedCommon].contactObject.SeequID];
        NSString*  str = [[CJSONSerializer serializer] serializeDictionary:catched_Dict];
        [Common SaveDataWithData:[str dataUsingEncoding:NSUTF8StringEncoding] key:userdetail_key];
    }
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _billingLabel =[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 50)];
        _billingSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(180, 0, 150, 50)];
        [_billingSwitch addTarget:self action:@selector(changeSwitch:) forControlEvents:UIControlEventValueChanged];
        _rateLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 50)];
        _balanceLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 150, 50)];
        _balanceValue = [[UILabel alloc] initWithFrame:CGRectMake(183, 0, 150, 50)];

        _rateText = [[UITextField alloc] initWithFrame:CGRectMake(180, 0, 100, 35)];
        _rateText.borderStyle = UITextBorderStyleRoundedRect;
        _rateText.delegate = self;
        [_rateText setKeyboardType:UIKeyboardTypeDecimalPad];
        _rateText.layer.cornerRadius = 2;
        _rateText.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        _billingLabel.text = @"Enable billing";
        _balanceLabel.text = @"Balance";
        _rateLabel.text  = @"Rate";
        [_billingLabel sizeToFit];
        [_rateLabel sizeToFit];
        [_balanceLabel sizeToFit];
        _activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activity.frame = CGRectMake(183, 0, 50, 50);
        _activity.hidesWhenStopped = YES;
    }
    return self;
}

-(void) changeSwitch:(id) sender {
    if([sender isOn]){
        NSLog(@"Switch is ON");
        _rateText.enabled = YES;
    } else{
        _rateText.enabled = NO;
        NSLog(@"Switch is OFF");
        _rateText.text = @"0";

    }
}
-(BOOL) isNumeric:(NSString*) checkText{
    return [[NSScanner scannerWithString:checkText] scanFloat:NULL];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
// JSC   NSString* ss = textField.text;
    if (textField.text.length >= 6 && range.length == 0)
    {
    	return NO; // return NO to not change text
    }
    else
    {return YES;}

    NSString *ss = [NSString stringWithFormat:@"%@%@",ss,string];
    BOOL flag = [self isNumeric:ss];
    if (!flag) {
        return  flag;
    }
    NSRange r = [ss rangeOfString:@"."];
    if (r.location == NSNotFound) {
        flag = YES;
    }
    r = [ss rangeOfString:@","];
    if (r.location == NSNotFound) {
        flag = YES;
    }
    if ( !flag && (ss.length - r.location > 3)) {
        return NO;
    }
    return flag;

   
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    return 2;
}

-(CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
        return 44;
 }
-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(NSString*) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
            
        case 0:
            return @"BILLING";
        case 1:
            return @"RATE & BALANCE";
        default:
            return @"";
    }
    
}

-(void) resetCell:(UITableViewCell*) cell{
    NSArray * ar = cell.contentView.subviews;
    for (int i = ar.count - 1 ; i >= 0; i--){
        [[ar objectAtIndex:i] removeFromSuperview];
    }
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Billing";
    
    UITableViewCell *cell = [tableView
                                                                 dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    [self resetCell:cell];
    if (indexPath.section == 0) {
        _billingLabel.frame =CGRectMake(10, cell.bounds.size.height/2 -_billingLabel.frame.size.height/2, _billingLabel.frame.size.width, _billingLabel.frame.size.height);
        _billingSwitch.center =CGPointMake(_billingSwitch.center.x, _billingLabel.center.y);
        
        [cell.contentView addSubview:_billingLabel];
        [cell.contentView addSubview:_billingSwitch];

    } else {
        if (indexPath.row == 0) {
            _rateLabel.frame =CGRectMake(10, cell.bounds.size.height/2 -_rateLabel.frame.size.height/2, _rateLabel.frame.size.width, _rateLabel.frame.size.height);
            _rateText.center =CGPointMake(_rateText.center.x, _rateLabel.center.y);
            [cell.contentView addSubview:_rateLabel];
            [cell.contentView addSubview:_rateText];

        } else {
            _balanceLabel.frame =CGRectMake(10, cell.bounds.size.height/2 -_balanceLabel.frame.size.height/2, _balanceLabel.frame.size.width, _balanceLabel.frame.size.height);
            _balanceValue.center =CGPointMake(_balanceValue.center.x, _balanceLabel.center.y);
            [cell.contentView addSubview:_balanceLabel];
            [cell.contentView addSubview:_balanceValue];
            [cell.contentView addSubview:_activity];

        }
       
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}




#pragma mark - Table view delegate

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.section == 3) {
//        self.transportType = [transportType isEqualToString:@"RTMP"]? @"XMPP":@"RTMP";
//        
//        [self.tableView reloadData];
//    }
//}



@end
