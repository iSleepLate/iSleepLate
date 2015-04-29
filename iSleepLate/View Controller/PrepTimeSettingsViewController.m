//
//  PrepTimeSettingsViewController.m
//  iSleepLate
//
//  Created by David Neubauer on 4/28/15.
//  Copyright (c) 2015 iSleepLate. All rights reserved.
//

#import "PrepTimeSettingsViewController.h"

@interface PrepTimeSettingsViewController () <UITableViewDataSource, UITextFieldDelegate>

@property (strong, nonatomic) NSArray *cellIds;
@property (strong, nonatomic) UITextField *minTextField;
@property (strong, nonatomic) UITextField *maxTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation PrepTimeSettingsViewController

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _cellIds = @[@"min", @"max"];
        _minTextField = [self valueTextField];
        _maxTextField = [self valueTextField];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    
    
    NSInteger min = [[NSUserDefaults standardUserDefaults] integerForKey:@"minPrepTime"];
    NSInteger max = [[NSUserDefaults standardUserDefaults] integerForKey:@"maxPrepTime"];
    self.minTextField.placeholder = self.minTextField.text = [NSString stringWithFormat:@"%d", min];
    self.maxTextField.placeholder = self.maxTextField.text = [NSString stringWithFormat:@"%d", max];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _cellIds.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:self.cellIds[indexPath.row]];
    if (cell) {
        if (indexPath.row == 0) {
            cell.accessoryView = self.minTextField;
        } else {
            cell.accessoryView = self.maxTextField;
        }
    }
    
    return cell;
}

- (UITextField *)valueTextField
{
    UITextField *textfield = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    textfield.borderStyle = UITextBorderStyleNone;
    textfield.backgroundColor = [UIColor clearColor];
    textfield.textColor = [UIColor whiteColor];
    textfield.clearsOnBeginEditing = YES;
    textfield.textAlignment = NSTextAlignmentRight;
    textfield.keyboardType = UIKeyboardTypeNumberPad;
    textfield.delegate = self;
    
    return textfield;
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSString *text = textField.text;
    NSLog(@"%d minutes", [text integerValue]);
    if ([text integerValue] > 120) {
        NSLog(@"WARNING: Prep Time set to value greater than 2h.");
    }
    
    // reset textfield top remove leading zeros
    textField.placeholder = textField.text = [NSString stringWithFormat:@"%d", [text integerValue]];
    
    // save new value
    if (textField == self.minTextField) {
        [[NSUserDefaults standardUserDefaults] setInteger:[text integerValue] forKey:@"minPrepTime"];
    } else if (textField == self.maxTextField) {
        [[NSUserDefaults standardUserDefaults] setInteger:[text integerValue] forKey:@"maxPrepTime"];
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
        
}

@end
