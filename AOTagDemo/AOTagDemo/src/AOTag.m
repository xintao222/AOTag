//
//  AOTag.m
//  AOTagDemo
//
//  Created by Loïc GRIFFIE on 16/09/13.
//  Copyright (c) 2013 Appsido. All rights reserved.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "AOTag.h"

#define tagFontSize         12.0f
#define tagFontType         @"Helvetica-Light"
#define tagMargin           5.0f
#define tagHeight           25.0f
#define tagCornerRadius     3.0f
#define tagCloseButton      7.0f

@implementation AOTagList

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        
        self.tags = [NSMutableArray array];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    int n = 0;
    float x = 40.0f;
    float y = 0.0f;
    
    for (id v in [self subviews])
        if ([v isKindOfClass:[AOTag class]])
            [v removeFromSuperview];
    
    for (AOTag *tag in self.tags)
    {
        if (x + [tag getTagSize].width + tagMargin > self.frame.size.width) { n = 0; x = 40.0; y += [tag getTagSize].height + tagMargin; }
        else x += (n ? tagMargin : 0.0f);
        
        [tag setFrame:CGRectMake(x, y, [tag getTagSize].width, [tag getTagSize].height)];
        [self addSubview:tag];
        
        x += [tag getTagSize].width;
        
        n++;
    }
    
    CGRect r = [self frame];
    r.size.height = y + tagHeight;
    [self setFrame:r];
}

- (AOTag *)generateTagWithLabel:(NSString *)tTitle withImage:(NSString *)tImage
{
    AOTag *tag = [[AOTag alloc] initWithFrame:CGRectZero];
    
    [tag setTImage:[UIImage imageNamed:tImage]];
    [tag setTTitle:tTitle];
    
    [self.tags addObject:tag];
    
    return tag;
}

- (void)addTag:(NSString *)tTitle withImage:(NSString *)tImage
{
    [self generateTagWithLabel:tTitle withImage:tImage];
    
    [self setNeedsDisplay];
}

- (void)addTag:(NSString *)tTitle
     withImage:(NSString *)tImage
withLabelColor:(UIColor *)labelColor
withBackgroundColor:(UIColor *)backgroundColor
withCloseButtonColor:(UIColor *)closeColor
{
    AOTag *tag = [self generateTagWithLabel:tTitle withImage:tImage];
    
    if (labelColor) [tag setTLabelColor:labelColor];
    if (backgroundColor) [tag setTBackgroundColor:backgroundColor];
    if (closeColor) [tag setTCloseButtonColor:closeColor];
    
    [self setNeedsDisplay];
}

- (void)addTags:(NSArray *)tags
{
    for (NSDictionary *tag in tags)
        [self addTag:[tag objectForKey:@"title"] withImage:[tag objectForKey:@"image"]];
}

- (void)removeTag:(AOTag *)tag
{
    [self.tags removeObject:tag];
    
    [self setNeedsDisplay];
}

- (void)removeAllTag
{
    for (id t in [NSArray arrayWithArray:[self tags]])
        [self removeTag:t];
}

@end

@implementation AOTag

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        self.tBackgroundColor = [UIColor colorWithRed:0.204 green:0.588 blue:0.855 alpha:1.000];
        self.tLabelColor = [UIColor whiteColor];
        self.tCloseButtonColor = [UIColor colorWithRed:0.710 green:0.867 blue:0.953 alpha:1.000];
        
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        
        [[self layer] setCornerRadius:tagCornerRadius];
        [[self layer] setMasksToBounds:YES];
        
    }
    return self;
}

- (CGSize)getTagSize
{
    CGSize tSize = [self.tTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:tagFontType size:tagFontSize]}];
    
    return CGSizeMake(tagHeight + tagMargin + tSize.width + tagMargin + tagCloseButton + tagMargin, tagHeight);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.layer.backgroundColor = [self.tBackgroundColor CGColor];
    
    [self.tImage drawInRect:CGRectMake(0.0f, 0.0f, [self getTagSize].height, [self getTagSize].height)];
    
    CGSize tSize = [self.tTitle sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:tagFontType size:tagFontSize]}];
    
    [self.tTitle drawInRect:CGRectMake(tagHeight + tagMargin, ([self getTagSize].height / 2.0f) - (tSize.height / 2.0f), tSize.width, tSize.height)
             withAttributes:@{NSFontAttributeName:[UIFont fontWithName:tagFontType size:tagFontSize], NSForegroundColorAttributeName:self.tLabelColor}];
    
    [self drawClose:rect];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagSelected:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [self addGestureRecognizer:recognizer];
}

- (void)drawClose:(CGRect)rect
{
    UIBezierPath *bezierPath = [UIBezierPath bezierPath];
    [bezierPath moveToPoint:CGPointMake(rect.size.width - tagCloseButton + 1.0, (rect.size.height - tagCloseButton) / 2.0)];
    [bezierPath addLineToPoint:CGPointMake(rect.size.width - (tagCloseButton * 2.0) + 1.0, ((rect.size.height - tagCloseButton) / 2.0) + tagCloseButton)];
    [self.tCloseButtonColor setStroke];
    bezierPath.lineWidth = 2.0;
    [bezierPath stroke];
    
    UIBezierPath *bezier2Path = [UIBezierPath bezierPath];
    [bezier2Path moveToPoint:CGPointMake(rect.size.width - tagCloseButton + 1.0, ((rect.size.height - tagCloseButton) / 2.0) + tagCloseButton)];
    [bezier2Path addLineToPoint:CGPointMake(rect.size.width - (tagCloseButton * 2.0) + 1.0, (rect.size.height - tagCloseButton) / 2.0)];
    [self.tCloseButtonColor setStroke];
    bezier2Path.lineWidth = 2.0;
    [bezier2Path stroke];
}

- (void)tagSelected:(id)sender
{
    NSLog(@"Tag > %@ has been selected", self);
    
    [(AOTagList *)[self superview] removeTag:self];
}

@end