//
//  CheckboxCell.m
//  Yelp
//
//  Created by Sean Zeng on 6/19/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "CheckboxCell.h"

@implementation CheckboxCell

- (void)awakeFromNib {
    // Initialization code
    
    //UIImage *uncheckedImage = [UIImage imageNamed:@"ic_unchecked"];
    //uncheckedImage = [uncheckedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    UIImage *checkedImage = [UIImage imageNamed:@"ic_checked"];
    //checkedImage = [checkedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    
    [self.checkbox setBackgroundImage:nil forState:UIControlStateNormal];
    [self.checkbox setBackgroundImage:nil forState:UIControlStateReserved];
    [self.checkbox setBackgroundImage:checkedImage forState:UIControlStateSelected];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)onCheck:(id)sender {
    if (self.on == YES) {
        [self setOn:NO];
    } else {
        [self setOn:YES];
    }
    
    [self.delegate checkboxCell:self didUpdateValue:self.on];
}

- (void)setOn:(BOOL)on {
    _on = on;
    self.checkbox.selected = on;
}

@end
