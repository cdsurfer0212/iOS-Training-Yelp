//
//  CheckboxCell.h
//  Yelp
//
//  Created by Sean Zeng on 6/19/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CheckboxCell;

@protocol CheckboxCellDelegate <NSObject>

- (void)checkboxCell:(CheckboxCell *)cell didUpdateValue:(BOOL)value;

@end

@interface CheckboxCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIButton *checkbox;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, assign) BOOL on;
@property (nonatomic, weak) id<CheckboxCellDelegate> delegate;

- (IBAction)onCheck:(id)sender;

@end
