//
//  MainTableViewCell.m
//  PulseDemoDev
//
//  Created by tutu on 2020/6/16.
//  Copyright © 2020 tusdk.com. All rights reserved.
//

#import "MainTableViewCell.h"

@implementation MainTableViewCell {
 
    UITextView* _textView;
}



- (void) setText:(NSString *)text
{
    
    if (!_textView) {
        //self.backgroundColor = UIColor.blueColor;
        
        UITextView* tv = [[UITextView alloc]init];
        [tv setUserInteractionEnabled:NO];
        //tv.editable = NO;
        //tv.selectable = NO;
        tv.text = text;
        tv.textAlignment = NSTextAlignmentCenter;
        [tv setFont:[UIFont boldSystemFontOfSize:25]];
        //tv.font = UIFont systemFontOfSize:<#(CGFloat)#> weight:<#(UIFontWeight)#>
        tv.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:tv];
        
        [tv.leadingAnchor constraintEqualToAnchor:self.leadingAnchor].active = YES;
        [tv.trailingAnchor constraintEqualToAnchor:self.trailingAnchor].active = YES;
        [tv.topAnchor constraintEqualToAnchor:self.topAnchor].active = YES;
        [tv.bottomAnchor constraintEqualToAnchor:self.bottomAnchor].active = YES;
        
        //[tv sizeToFit];
        tv.scrollEnabled = NO;
        
        _textView = tv;
    }
    
    _textView.text = text;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    
    
    
    
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}




@end
