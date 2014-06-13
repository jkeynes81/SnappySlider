//
//  SnappySlider.m
//  snappyslider
//
//  Created by Aaron Brethorst on 3/13/11.
//  Segmented vertical lines added by Keynes Paul on 5/19/14.
//  Copyright (c) 2011 Aaron Brethorst
//  Copyright (c) 2014 Keynes Paul
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

#import "SnappySlider.h"
#import <QuartzCore/QuartzCore.h>
typedef void (^SliderValueChangedHandler) (id sender, int value);

@interface SnappySlider ()
@property(nonatomic,strong) NSArray *detents;
@property(nonatomic,strong) NSMutableArray *tmpDetents;
@property(nonatomic,retain) UIBezierPath *segmentStopPath;
@property(nonatomic,copy) SliderValueChangedHandler valueChangedHandler;
-(void)markLines:(CGPoint)point withValue:(id)value inView:(UIView*)view;
- (void)_configureView;

@end

@implementation SnappySlider
@synthesize valuesToPlot=_valuesToPlot;
-(NSMutableArray*)tmpDetents
{
    if (!_tmpDetents) {
        _tmpDetents = [[NSMutableArray alloc] init];
    }
    return _tmpDetents;
}
- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];
    if (self) {
        [self _configureView];
//        self.value=self.maximumValue;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
        [self _configureView];
	}
	return self;
}

- (void)_configureView
{
    rawDetents = NULL;
    self.detents = nil;
    [self addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
}

- (void)valueChanged:(id)sender
{
    if (self.valueChangedHandler)
    {
//        self.valueChangedHandler(self, (int)self.value);
                self.valueChangedHandler(self,(int)[self.tmpDetents indexOfObject:[NSString stringWithFormat:@"%f",self.value]]);
    }
}
-(void)setValuesToPlot:(NSArray *)valuesToPlot
{
    _valuesToPlot = valuesToPlot;
    float detentSize = 100/valuesToPlot.count;
    for (int i = 0; i < valuesToPlot.count; i++) {
        [self.tmpDetents addObject:[NSString stringWithFormat:@"%f",i*detentSize] ];
    }
    [self setDetents:_tmpDetents];
}

- (void)setDetents:(NSArray *)v
{
	if (_detents == v)
	{
		return;
	}
	
	NSArray *newDetents = [[v sortedArrayUsingSelector:@selector(compare:)] copy];
	
	_detents = newDetents;
	
	if (nil != rawDetents)
	{
		free(rawDetents);
	}
	
	rawDetents = malloc(sizeof(int) * [self.detents count]);
	
	for (int i=0; i < self.detents.count; i++)
	{
		rawDetents[i] = [(self.detents)[i] intValue];
	}
    
    CGRect trackLength=[self trackRectForBounds:self.bounds];
    CGFloat segment = trackLength.size.width/(self.detents.count-1);
    CGPoint marker = CGPointMake(trackLength.origin.x, trackLength.origin.y);
    self.maximumTrackTintColor=[UIColor blackColor];
    self.minimumTrackTintColor=[UIColor blackColor];
    for (int segments=0; segments < self.detents.count ; segments++) {
        marker =CGPointMake((CGFloat)segment*segments, trackLength.origin.y);
        [self markLines:marker withValue:[self.valuesToPlot objectAtIndex:segments] inView:self];
    }
	self.minimumValue = [(self.detents)[0] floatValue];
	self.maximumValue = [self.detents.lastObject floatValue];
    self.value = self.maximumValue;
}

- (void)setValue:(float)value animated:(BOOL)animated
{
	int bestDistance = INT_MAX;
	int bestFit = INT_MAX;
	
	for (int i=0; i < self.detents.count; i++)
	{
		int candidate = rawDetents[i];
		int candidateDistance = abs(candidate - (int)value);
		
		if (candidateDistance < bestDistance)
		{
			bestFit = candidate;
			bestDistance = candidateDistance;
		}
	}
    
	[super setValue:(float)bestFit animated:animated];
}

- (void)valueDidChange:(void (^)(id, int))block
{
    self.valueChangedHandler = block;
}

- (void)dealloc
{
	free(rawDetents);
}

-(void)markLines:(CGPoint)point withValue:(id)value inView:(UIView*)view
{
    self.segmentStopPath = [[UIBezierPath alloc] init];
    [self.segmentStopPath moveToPoint:CGPointMake(point.x+2, point.y-5)];
    [self.segmentStopPath addLineToPoint:CGPointMake(point.x+2, point.y+6)];
    CAShapeLayer *markerLine = [[CAShapeLayer alloc] init];
    markerLine.strokeColor = [UIColor blackColor].CGColor;
    markerLine.lineWidth=1.5f;
    markerLine.path=self.segmentStopPath.CGPath;
    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(point.x-10, point.y-50, 50, 50)];
    valueLabel.text = [NSString stringWithFormat:@"%@",value];
    [view addSubview:valueLabel];
    [view.layer addSublayer:markerLine];
}

#pragma -mark Custom Tracking Methods

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    return YES;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super continueTrackingWithTouch:touch withEvent:event];
    CGPoint pointForCurrentValue = CGPointMake(([self trackRectForBounds:self.frame].size.width * [self value])/ (int)self.maximumValue,[self trackRectForBounds:self.frame].size.height/4) ;
    [self thumbRectForBounds:CGRectMake(pointForCurrentValue.x, pointForCurrentValue.y, 31,31) trackRect:[self trackRectForBounds:self.frame] value:self.value];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
}

-(CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    CGRect thumbRect = CGRectZero;
    if (self.value == self.minimumValue) {
        thumbRect = CGRectOffset(CGRectMake([self trackRectForBounds:self.frame].origin.x, [self trackRectForBounds:self.frame].size.height/4, 31, 31),-35.5,-5);
    }else if (self.value == self.maximumValue)
    {
        thumbRect = CGRectOffset(CGRectMake([self trackRectForBounds:self.frame].size.width, [self trackRectForBounds:self.frame].size.height/4, 31,31),-15.5,-5);
    }
    else
    {
        CGPoint pointForCurrentValue = CGPointMake(([self trackRectForBounds:self.frame].size.width * [self value])/ (int)self.maximumValue,[self trackRectForBounds:self.frame].size.height/4) ;
        thumbRect = CGRectOffset(CGRectMake(pointForCurrentValue.x, pointForCurrentValue.y, 31, 31),-10.0,-5);
    }
    return thumbRect;
    
}

@end
