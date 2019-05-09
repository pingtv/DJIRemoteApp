//
//  FileLabelViewController.m
//  
//
//  Created by Ping Chen on 5/8/19.
//

#import "FileLabelViewController.h"

@interface FileLabelViewController () <UITextFieldDelegate>

@end

@implementation FileLabelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    
    self.contentView.layer.cornerRadius = 3.0;
    
    self.readyButton.layer.cornerRadius = 3.0;
    
    [self.textField setDelegate:self];
    [self setupReadyButton];
    
}

-(void)setupReadyButton {
    if (self.textField.text.length > 0) {
        [self.readyButton setEnabled:YES];
    } else {
        [self.readyButton setEnabled:NO];
    }
}


- (IBAction)readyPressed:(id)sender {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(setFileLabel:)]) {
        [self.delegate setFileLabel:self.textField.text];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    
    [self setupReadyButton];
    
    return NO;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self setupReadyButton];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
