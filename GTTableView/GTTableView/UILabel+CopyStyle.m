//
//  UILabel+CopyStyle.m
//  GTTableView
//
//  Created by Andrew Mackenzie-Ross on 10/05/11.
//  Copyright 2011 mackross.net. All rights reserved.
//

#import "UILabel+CopyStyle.h"


@implementation UILabel (CopyStyle)
- (void)copyStyleFromLabel:(UILabel *)aLabel
{
    if (!aLabel) return;
    
    /* Accessing the Text Attributes. */
    if (aLabel.font)
        self.font =  aLabel.font;
    if (aLabel.textColor)
        self.textColor = aLabel.textColor;
    if (aLabel.backgroundColor)
        self.backgroundColor = aLabel.backgroundColor;
    if (aLabel.highlightedTextColor)
        self.highlightedTextColor = aLabel.highlightedTextColor;
    self.textAlignment = aLabel.textAlignment;
    self.lineBreakMode = aLabel.lineBreakMode;
    
    /* Sizing the Label's Text. */
    self.adjustsFontSizeToFitWidth = aLabel.adjustsFontSizeToFitWidth;
    self.baselineAdjustment = aLabel.baselineAdjustment;
    self.minimumScaleFactor = aLabel.minimumScaleFactor;
    self.numberOfLines = aLabel.numberOfLines;
    
    /* Managing Highlight Values. */
    if (aLabel.highlightedTextColor)
        self.highlightedTextColor = aLabel.highlightedTextColor;
    self.highlighted = aLabel.highlighted;
    
    /* Drawing a Shadow. */
    if (aLabel.shadowColor)
        self.shadowColor = aLabel.shadowColor;
    self.shadowOffset = aLabel.shadowOffset;
    
    /* View Attributes. */
    self.userInteractionEnabled = aLabel.userInteractionEnabled;
    self.opaque = aLabel.opaque;
    self.alpha = aLabel.alpha;
    self.enabled = aLabel.enabled;
    self.highlighted = aLabel.highlighted;
    self.autoresizingMask = aLabel.autoresizingMask;
    self.hidden = aLabel.hidden;
    
    /* Accessability.
     I've chosen not to copy the accessability hint, value, etc as it will probably be set on a per instance basis.
     */
    self.accessibilityTraits = aLabel.accessibilityTraits;
    self.accessibilityFrame = aLabel.accessibilityFrame;
    
}
@end
