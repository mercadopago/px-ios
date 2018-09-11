//
// MLContextualMenu.m
// MLUI
//
// Created by Nicolas Guido Brucchieri on 5/11/16.
//
//

#import "MLContextualMenu.h"
#import "UIColor+MLColorPalette.h"
#import "UIFont+MLFonts.h"

#define LayerBackgroundColor [UIColor colorWithWhite:0.1f alpha:.8f].CGColor
static NSString *const kMLGHShowAnimationID = @"contextMenuViewRriseAnimationID";
static NSString *const kMLGHDismissAnimationID = @"contextMenuViewDismissAnimationID";
static NSInteger const kMLMaxItems = 4;
static NSInteger const kMLMainItemSize = 48;
static NSInteger const kMLMenuItemSize = 48;
static NSInteger const kMLMenuLabelHeight = 18;
static NSInteger const kMLMenuLabelWidth = 78;
static NSInteger const kMLMenuSpacelSize = 10;
static NSInteger const kMLBorderWidth = 5;
static CGFloat const kMLAnimationDuration = 0.2;
static CGFloat const kMLAnimationDelay = kMLAnimationDuration / 20;

#pragma mark LayerTypes
typedef NS_ENUM (NSInteger, MLLongPressContextMenuLayerType) {
	MLLongPressContextMenuLayerTypeText,
	MLLongPressContextMenuLayerTypeImage,
};
static NSString *const MLLongPressContextMenuLayerType_toString[] = {
	[MLLongPressContextMenuLayerTypeText] = @"MLLongPressContextMenuLayerTypeText",
	[MLLongPressContextMenuLayerTypeImage] = @"MLLongPressContextMenuLayerTypeImage"
};

#pragma mark MLLongPressMenuItemLocation Class
@interface MLLongPressMenuItemLocation : NSObject

@property (nonatomic) CGPoint position;
@property (nonatomic) CGFloat angle;

@end

@implementation MLLongPressMenuItemLocation

@end

#pragma mark MLLongPressContextMenuView Class
@interface MLContextualMenu () <CAAnimationDelegate>

@property (nonatomic, strong) NSMutableArray *originalGestureRecognizers;
@property (nonatomic, strong) UIView *parentView;

@property (nonatomic, assign) BOOL isShowing;
@property (nonatomic, assign) BOOL isPaning;

@property (nonatomic, assign) BOOL invertActionsOrder;

@property (nonatomic) CGPoint longPressLocation;
@property (nonatomic) CGPoint originalPressLocation;
@property (nonatomic) CGPoint currentLocation;

@property (nonatomic, strong) NSMutableArray *menuItems;
@property (nonatomic, strong) NSArray <MLContextualMenuItem *> *longPressContextMenuItems;

@property (nonatomic) CGFloat radius;
@property (nonatomic) CGFloat arcAngle;
@property (nonatomic) CGFloat angleBetweenItems;
@property (nonatomic, strong) NSMutableArray *itemLocations;
@property (nonatomic) NSInteger selectedIndex;

@end

@implementation MLContextualMenu

#pragma mark -
#pragma mark Initializations
#pragma mark -
- (id)init
{
	self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
	if (self) {
		[self setup];
	}
	return self;
}

- (void)setup
{
	[self setupView];
	[self viewInitializations];
	[self setupDisplayLink];
}

- (void)setupDisplayLink
{
	CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self
	                                                         selector:@selector(highlightMenuItemForPoint)];
	[displayLink addToRunLoop:[NSRunLoop mainRunLoop]
	                  forMode:NSDefaultRunLoopMode];
}

- (void)setupView
{
	self.userInteractionEnabled = YES;
	self.backgroundColor = [UIColor clearColor];
	self.layer.backgroundColor = LayerBackgroundColor;
}

- (void)viewInitializations
{
	self.menuItems = [NSMutableArray array];
	self.itemLocations = [NSMutableArray array];
	self.arcAngle = M_PI / 3;
	self.radius = 90;
	self.invertActionsOrder = NO;
}

#pragma mark -
#pragma mark GestureRecognizer
#pragma mark -
- (UILongPressGestureRecognizer *)gestureRecognizerWithDelegate:(id <UIGestureRecognizerDelegate>)delegate
{
	UILongPressGestureRecognizer *gestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self
	                                                                                                action:@selector(longPressDetected:)];
	gestureRecognizer.delegate = delegate;

	// Standard config
	gestureRecognizer.delaysTouchesBegan = YES;

	return gestureRecognizer;
}

#pragma mark -
#pragma mark Datasource
#pragma mark -
- (void)setDataSource:(id <MLContextualMenuDataSource>)dataSource
{
	_dataSource = dataSource;
	[self reloadData];
}

- (BOOL)shouldShowMenuAtPoint:(CGPoint)point
{
	if (self.dataSource != nil && [self.dataSource respondsToSelector:@selector(contextualMenu:shouldShowMenuAtPoint:)]) {
		return [self.dataSource contextualMenu:self shouldShowMenuAtPoint:point];
	}
	return YES;
}

#pragma mark -
#pragma mark LongPress handler
#pragma mark -
- (void)dismissWithSelectedIndexForMenuAtPoint:(CGPoint)point
{
	if (self.delegate) {
		if ([self.delegate respondsToSelector:@selector(contextualMenuDidClose:)]) {
			[self.delegate contextualMenuDidClose:self];
		}
		if ([self.delegate respondsToSelector:@selector(contextualMenu:didSelectItemAtIndex:atPoint:)]
		    && [self isSelectedIndex]) {
			[self.delegate contextualMenu:self didSelectItemAtIndex:self.selectedIndex atPoint:point];
			[self resetSelectedIndex];
		}
	}

	[self hideMenu];
}

- (void)longPressDetected:(UIGestureRecognizer *)gestureRecognizer
{
	switch (gestureRecognizer.state) {
		case UIGestureRecognizerStateBegan:
		{
			[self resetSelectedIndex];

			CGPoint pointInView = [gestureRecognizer locationInView:gestureRecognizer.view];
			if ([self shouldShowMenuAtPoint:pointInView]) {
				[self storeOriginalGestureRecognizersFromView:gestureRecognizer.view];

				[[UIApplication sharedApplication].keyWindow addSubview:self];
				self.longPressLocation = [gestureRecognizer locationInView:self];
				self.originalPressLocation = [self convertPoint:self.longPressLocation toView:gestureRecognizer.view];

				[self showAnimateMenu:YES];
			}
			break;
		}

		case UIGestureRecognizerStateChanged:
		{
			if (self.isShowing) {
				self.isPaning = YES;
				self.currentLocation = [gestureRecognizer locationInView:self];
			}
			break;
		}

		case UIGestureRecognizerStateCancelled:
		{
			CGPoint menuAtPoint = [self convertPoint:self.longPressLocation toView:gestureRecognizer.view];
			[self dismissWithSelectedIndexForMenuAtPoint:menuAtPoint];
			break;
		}

		case UIGestureRecognizerStateFailed:
		{
			CGPoint menuAtPoint = [self convertPoint:self.longPressLocation toView:gestureRecognizer.view];
			[self dismissWithSelectedIndexForMenuAtPoint:menuAtPoint];
			break;
		}

		case UIGestureRecognizerStateEnded:
		{
			CGPoint menuAtPoint = [self convertPoint:self.longPressLocation toView:gestureRecognizer.view];
			[self dismissWithSelectedIndexForMenuAtPoint:menuAtPoint];
			break;
		}

		default: {
			break;
		}
	}
}

#pragma mark -
#pragma mark Menu item layout
#pragma mark -
- (void)reloadData
{
	[self.menuItems removeAllObjects];
	[self.itemLocations removeAllObjects];

	if (self.dataSource != nil) {
		self.longPressContextMenuItems = [self.dataSource contextualMenu:self itemsAtPoint:self.originalPressLocation];
		NSInteger itemsCount = self.longPressContextMenuItems.count;
		if (self.longPressContextMenuItems.count > kMLMaxItems) {
			itemsCount = kMLMaxItems;
		}

		for (int i = 0; i < itemsCount; i++) {
			CALayer *layer = [self layerWithIndex:i];
			[self.layer addSublayer:layer];
			[self.menuItems addObject:layer];
		}
	}
}

- (CALayer *)layerWithIndex:(NSInteger)index
{
	CALayer *mainLayer = [self drawMainLayer];

	CALayer *contentImageLayer = [self drawContentImageLayerAtIndex:index
	                                                          width:CGRectGetWidth(mainLayer.bounds)
	                                                         height:CGRectGetHeight(mainLayer.bounds)];
	[mainLayer addSublayer:contentImageLayer];

	CALayer *textLayer = [self drawTextLayerAtIndex:index
	                                          width:mainLayer.bounds.size.width];
	[mainLayer addSublayer:textLayer];

	return mainLayer;
}

- (CALayer *)drawMainLayer
{
	CALayer *mainLayer = [CALayer layer];
	mainLayer.backgroundColor = [UIColor clearColor].CGColor;
	mainLayer.bounds = CGRectMake(0, 0, kMLMenuLabelWidth, kMLMenuItemSize + (kMLMenuLabelHeight + kMLMenuSpacelSize) * 2);

	return mainLayer;
}

- (CALayer *)drawContentImageLayerAtIndex:(NSInteger)index width:(CGFloat)width height:(CGFloat)height
{
	CALayer *layer = [CALayer layer];
	layer.name = MLLongPressContextMenuLayerType_toString[MLLongPressContextMenuLayerTypeImage];
	layer.bounds = CGRectMake(0, 0, kMLMenuItemSize, kMLMenuItemSize);
	layer.cornerRadius = kMLMenuItemSize / 2;
	layer.shadowColor = [UIColor ml_meli_black].CGColor;
	layer.shadowOffset = CGSizeMake(0, -1);
	layer.backgroundColor = [UIColor ml_meli_white].CGColor;
	layer.position = CGPointMake(width / 2, height / 2);

	CALayer *imageLayer = [self drawImageLayerAtIndex:index width:width height:height selected:NO];
	[layer addSublayer:imageLayer];

	return layer;
}

- (CALayer *)drawImageLayerAtIndex:(NSInteger)index width:(CGFloat)width height:(CGFloat)height selected:(BOOL)selected
{
	UIImage *image = self.longPressContextMenuItems[index].image;
	if (selected) {
		image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
		image = [self tintedImage:image WithColor:[UIColor ml_meli_white]];
	}

	CALayer *imageLayer = [CALayer layer];
	imageLayer.contents = (id)image.CGImage;
	imageLayer.bounds = CGRectMake(0, 0, image.size.width, image.size.height);
	imageLayer.position = CGPointMake((kMLMenuItemSize / 2), kMLMenuItemSize / 2);
	return imageLayer;
}

- (UIImage *)tintedImage:(UIImage *)image WithColor:(UIColor *)tintColor
{
	UIGraphicsBeginImageContextWithOptions(image.size, NO, [[UIScreen mainScreen] scale]);
	CGContextRef context = UIGraphicsGetCurrentContext();

	CGContextTranslateCTM(context, 0, image.size.height);
	CGContextScaleCTM(context, 1.0, -1.0);

	CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);

	CGContextSetBlendMode(context, kCGBlendModeNormal);
	CGContextDrawImage(context, rect, image.CGImage);

	CGContextSetBlendMode(context, kCGBlendModeSourceIn);
	[tintColor setFill];
	CGContextFillRect(context, rect);

	UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return coloredImage;
}

- (CALayer *)drawTextLayerAtIndex:(NSInteger)index width:(CGFloat)width
{
	NSString *text = self.longPressContextMenuItems[index].text;

	CATextLayer *textLayer = [CATextLayer layer];
	textLayer.name = MLLongPressContextMenuLayerType_toString[MLLongPressContextMenuLayerTypeText];
	textLayer.string = text;
	textLayer.position = CGPointMake(width / 2, kMLMenuLabelHeight / 2);
	textLayer.fontSize = kMLFontsSizeXXSmall;
	textLayer.font = (__bridge CFTypeRef _Nullable)([UIFont ml_lightSystemFontOfSize:kMLFontsSizeXXSmall]);
	textLayer.cornerRadius = 10;
	textLayer.alignmentMode = kCAAlignmentCenter;
	textLayer.bounds = CGRectMake(0, 0, kMLMenuLabelWidth, kMLMenuLabelHeight);
	textLayer.contentsScale = [[UIScreen mainScreen] scale];
	textLayer.backgroundColor = [UIColor ml_meli_black].CGColor;
	textLayer.hidden = YES;

	return textLayer;
}

- (void)layoutMenuItems
{
	self.layer.sublayers = nil;
	[self reloadData];
	[self.itemLocations removeAllObjects];

	self.arcAngle = M_PI / (6.5 / self.menuItems.count);

	NSUInteger count = self.menuItems.count;
	BOOL isFullCircle = (self.arcAngle == M_PI * 2);
	NSUInteger divisor = (isFullCircle || count <= 1) ? count : count - 1;

	self.angleBetweenItems = self.arcAngle / divisor;

	CGFloat ratio = [self calculateRatio:self.longPressLocation];

	for (int i = 0; i < self.menuItems.count; i++) {
		MLLongPressMenuItemLocation *location = [self locationForItemAtIndex:i andRatio:ratio];
		[self.itemLocations addObject:location];

		CALayer *layer = (CALayer *)[self.menuItems objectAtIndex:i];
		layer.transform = CATransform3DIdentity;
	}
}

- (MLLongPressMenuItemLocation *)locationForItemAtIndex:(NSUInteger)index andRatio:(CGFloat)ratio
{
	if (self.invertActionsOrder) {
		index = self.menuItems.count - index - 1;
	}

	CGFloat itemAngle = [self itemAngleAtIndex:index andRatio:ratio];

	CGPoint itemCenter = CGPointMake(self.longPressLocation.x + cosf(itemAngle) * self.radius,
	                                 self.longPressLocation.y + sinf(itemAngle) * self.radius);
	MLLongPressMenuItemLocation *location = [MLLongPressMenuItemLocation new];
	location.position = itemCenter;
	location.angle = itemAngle;

	return location;
}

- (CGFloat)itemAngleAtIndex:(NSUInteger)index andRatio:(CGFloat)ratio
{
	float bearingRadians = [self angleForLongPressLocation:self.longPressLocation andRatio:ratio];

	CGFloat angle = bearingRadians - (self.arcAngle / 2);

	CGFloat itemAngle = angle + (index * self.angleBetweenItems) - 0.3;

	if (itemAngle > 2 * M_PI) {
		itemAngle -= 2 * M_PI;
	} else if (itemAngle < 0) {
		itemAngle += 2 * M_PI;
	}

	return itemAngle;
}

#pragma mark -
#pragma mark Menu animation and selection
#pragma mark -
- (void)showAnimateMenu:(BOOL)show
{
	if (show) {
		[self layoutMenuItems];
	}

	for (NSUInteger index = 0; index < self.menuItems.count; index++) {
		CALayer *layer = self.menuItems[index];
		layer.opacity = 0;
		CGPoint fromPosition = self.longPressLocation;

		MLLongPressMenuItemLocation *location = [self.itemLocations objectAtIndex:index];
		CGPoint toPosition = location.position;

		double delayInSeconds = index * kMLAnimationDelay;

		CABasicAnimation *positionAnimation;

		positionAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
		positionAnimation.fromValue = [NSValue valueWithCGPoint:show ? fromPosition : toPosition];
		positionAnimation.toValue = [NSValue valueWithCGPoint:show ? toPosition : fromPosition];
		positionAnimation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.45f :1.2f :0.75f :1.0f];
		positionAnimation.duration = kMLAnimationDuration;
		positionAnimation.beginTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil] + delayInSeconds;
		[positionAnimation setValue:[NSNumber numberWithUnsignedInteger:index] forKey:show ? kMLGHShowAnimationID : kMLGHDismissAnimationID];
		positionAnimation.delegate = self;

		[layer addAnimation:positionAnimation forKey:@"riseAnimation"];
	}

	self.isShowing = show;
	[self setNeedsDisplay];
	if (!show) {
		self.isPaning = NO;
		[self removeFromSuperview];
	}
}

- (void)highlightMenuItemForPoint
{
	if (self.isShowing && self.isPaning) {
		NSInteger closeToIndex = [self getClosestIndex];

		if ([self isValidIndexForSelection:closeToIndex]) {
			[self resetPreviousSelectionIfNeeded:closeToIndex];
			[self animateSelectionAtIndex:closeToIndex selecting:YES];
			self.selectedIndex = closeToIndex;
		} else {
			[self resetPreviousSelection];
		}
	}
}

- (void)resetPreviousSelectionIfNeeded:(NSInteger)closeToIndex
{
	if (([self isSelectedIndex] && self.selectedIndex != closeToIndex)) {
		[self resetPreviousSelection];
	}
}

- (void)resetPreviousSelection
{
	if ([self isSelectedIndex]) {
		[self animateSelectionAtIndex:self.selectedIndex selecting:NO];
		[self resetSelectedIndex];
	}
}

- (void)animateSelectionAtIndex:(NSInteger)index selecting:(BOOL)selecting
{
	[self animateSelectionScaleAtIndex:index selecting:selecting];
	[self animateSelectionTextAndBackgroundAtIndex:index selecting:selecting];
}

- (void)animateSelectionTextAndBackgroundAtIndex:(NSInteger)index selecting:(BOOL)selecting
{
	CALayer *mainLayer = [self.menuItems objectAtIndex:index];

	for (CALayer *layer in mainLayer.sublayers) {
		if ([layer.name isEqualToString:MLLongPressContextMenuLayerType_toString[MLLongPressContextMenuLayerTypeText]]) {
			layer.hidden = !selecting;
		} else if ([layer.name isEqualToString:MLLongPressContextMenuLayerType_toString[MLLongPressContextMenuLayerTypeImage]]) {
			if (selecting) {
				layer.backgroundColor = [UIColor ml_meli_yellow].CGColor;
			} else {
				layer.backgroundColor = [UIColor ml_meli_white].CGColor;
			}

			if (self.longPressContextMenuItems[index].selected) {
				layer.sublayers = nil;
				CALayer *imageLayer = [self drawImageLayerAtIndex:index
				                                            width:CGRectGetWidth(mainLayer.bounds)
				                                           height:CGRectGetHeight(mainLayer.bounds)
				                                         selected:selecting];
				[layer addSublayer:imageLayer];
			}
		}
	}
}

- (void)animateSelectionScaleAtIndex:(NSInteger)closeToIndex selecting:(BOOL)selecting
{
	CALayer *mainLayer = [self.menuItems objectAtIndex:closeToIndex];
	MLLongPressMenuItemLocation *itemLocation = [self.itemLocations objectAtIndex:closeToIndex];

	if (selecting) {
		CGFloat scaleFactor = 1 + 0.2;

		// Scale
		CATransform3D scaleTransForm = CATransform3DScale(CATransform3DIdentity, scaleFactor, scaleFactor, 1.0);

		CGFloat xtrans = cosf(itemLocation.angle);
		CGFloat ytrans = sinf(itemLocation.angle);

		CATransform3D transLate = CATransform3DTranslate(scaleTransForm, 10 * scaleFactor * xtrans, 10 * scaleFactor * ytrans, 0);

		mainLayer.transform = transLate;
	} else {
		mainLayer.position = itemLocation.position;
		mainLayer.zPosition--;
		mainLayer.transform = CATransform3DIdentity;
	}
}

- (void)animationDidStart:(CAAnimation *)anim
{
	if ([anim valueForKey:kMLGHShowAnimationID]) {
		NSUInteger index = [[anim valueForKey:kMLGHShowAnimationID] unsignedIntegerValue];
		CALayer *layer = self.menuItems[index];

		MLLongPressMenuItemLocation *location = [self.itemLocations objectAtIndex:index];
		CGFloat toAlpha = 1.0;

		layer.position = location.position;
		layer.opacity = toAlpha;
	} else if ([anim valueForKey:kMLGHDismissAnimationID]) {
		NSUInteger index = [[anim valueForKey:kMLGHDismissAnimationID] unsignedIntegerValue];
		CALayer *layer = self.menuItems[index];
		CGPoint toPosition = self.longPressLocation;
		[CATransaction begin];
		[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
		layer.position = toPosition;
		layer.backgroundColor = [UIColor ml_meli_white].CGColor;
		layer.opacity = 0.0f;
		layer.transform = CATransform3DIdentity;
	}
	[CATransaction commit];
}

- (void)drawCircle:(CGPoint)locationOfTouch
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	CGContextSaveGState(ctx);
	CGContextSetLineWidth(ctx, kMLBorderWidth / 2);
	CGContextSetRGBStrokeColor(ctx, 251, 218, 21, 0.4);
	CGContextAddArc(ctx, locationOfTouch.x, locationOfTouch.y, kMLMainItemSize / 2, 0.0, M_PI * 2, YES);
	CGContextStrokePath(ctx);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
	// Drawing code
	if (self.isShowing) {
		[self drawCircle:self.longPressLocation];
	}
}

#pragma mark - Selection utils
- (NSInteger)getClosestIndex
{
	NSInteger closeToIndex = -1;

	CGFloat angle = [self angleBetweenStartingPoint:self.longPressLocation endingPoint:self.currentLocation];
	for (int i = 0; i < self.menuItems.count; i++) {
		MLLongPressMenuItemLocation *itemLocation = [self.itemLocations objectAtIndex:i];
		if (fabs(itemLocation.angle - angle) < self.angleBetweenItems / 2) {
			closeToIndex = i;
			break;
		}
	}

	return closeToIndex;
}

- (BOOL)isValidClosestIndex:(NSInteger)closestIndex
{
	return closestIndex >= 0 && closestIndex < self.menuItems.count;
}

- (BOOL)isValidIndexForSelection:(NSInteger)closestIndex
{
	if ([self isValidClosestIndex:closestIndex]) {
		if (fabs([self distanceFromItem]) < [self toleranceDistance]) {
			return YES;
		}
	}

	return NO;
}

#pragma mark -
#pragma mark Utils
#pragma mark -
#pragma mark SelectedIndex
- (void)resetSelectedIndex
{
	self.selectedIndex = -1;
}

- (BOOL)isSelectedIndex
{
	return self.selectedIndex >= 0;
}

#pragma mark OriginalGestureRecognizers
- (void)storeOriginalGestureRecognizersFromView:(UIView *)view
{
	self.originalGestureRecognizers = [[NSMutableArray alloc] init];
	for (UIGestureRecognizer *gr in view.gestureRecognizers) {
		[self.originalGestureRecognizers addObject:gr];
		[self.parentView removeGestureRecognizer:gr];
	}
}

- (void)addStoredOriginalGestureRecognizers
{
	for (UIGestureRecognizer *gr in self.originalGestureRecognizers) {
		[self.parentView addGestureRecognizer:gr];
	}
	self.originalGestureRecognizers = nil;
}

#pragma mark UI
- (void)hideMenu
{
	if (self.isShowing) {
		[self addStoredOriginalGestureRecognizers];
		[self showAnimateMenu:NO];
	}
}

# pragma mark Helper Math methods
- (CGFloat)angleBetweenStartingPoint:(CGPoint)startingPoint endingPoint:(CGPoint)endingPoint
{
	CGPoint originPoint = CGPointMake(endingPoint.x - startingPoint.x, endingPoint.y - startingPoint.y);
	float bearingRadians = atan2f(originPoint.y, originPoint.x);

	bearingRadians = (bearingRadians > 0.0 ? bearingRadians : (M_PI * 2 + bearingRadians));

	return bearingRadians;
}

- (CGFloat)calculateRatio:(CGPoint)longPressPoint
{
	CGFloat width = CGRectGetWidth([UIScreen mainScreen].bounds);
	self.invertActionsOrder = NO;

	CGFloat ratio = longPressPoint.x / width;

	CGFloat const kMLMinRatioToInvertOrder = 0.70f;
	CGFloat const kMLMaxRatioInverted = 0.85f;
	CGFloat const kMLMaxRatioFixedInverted = 0.75;
	if (ratio >= kMLMinRatioToInvertOrder) {
		self.invertActionsOrder = YES;
		if (ratio < kMLMaxRatioInverted) {
			ratio = kMLMaxRatioFixedInverted;
		}
	}

	CGFloat const kMLMinRadioToShowItemsSide = 0.15f;
	CGFloat const kMLMaxRadioToShowItemsSide = 0.32f;
	CGFloat const kMLMaxRadioToShowItemsTop = 0.68f;
	CGFloat const kMLShowItemsSideRatio = 0.25;
	CGFloat const kMLShowItemsTopRatio = 0.5;
	if (ratio > kMLMinRadioToShowItemsSide && ratio <= kMLMaxRadioToShowItemsSide) {
		ratio = kMLShowItemsSideRatio;
	}
	if (ratio > kMLMaxRadioToShowItemsSide && ratio < kMLMaxRadioToShowItemsTop) {
		ratio = kMLShowItemsTopRatio;
	}

	return ratio;
}

- (CGFloat)angleForLongPressLocation:(CGPoint)longPressPoint andRatio:(CGFloat)ratio
{
	CGFloat yPosition = (longPressPoint.y < (60 + (kMLMenuItemSize * 0.5) + self.radius) ? -1 : 1);

	CGFloat itemAngle = ((M_PI_2 * 3) - ((ratio - 0.5) * M_PI)) * yPosition;

	CGFloat const kMLMaxYForShowItemsBottom = 100;
	CGFloat const kMLMaxRatioForShowItemsBottom = 0.85f;
	CGFloat const kMLMaxYForShowItemsTop = 600;
	CGFloat const kMLMaxRatioForShowItemsTop = 0.85f;
	CGFloat const kMLValueToTurnItemsAngle = 0.4;
	if (longPressPoint.y < kMLMaxYForShowItemsTop && ratio > kMLMaxRatioForShowItemsTop) {
		itemAngle = itemAngle - kMLValueToTurnItemsAngle;
	}
	if (longPressPoint.y > kMLMaxYForShowItemsBottom && ratio > kMLMaxRatioForShowItemsBottom) {
		itemAngle = itemAngle + kMLValueToTurnItemsAngle;
	}

	if (itemAngle > 2 * M_PI) {
		itemAngle -= 2 * M_PI;
	} else if (itemAngle < 0) {
		itemAngle += 2 * M_PI;
	}

	return itemAngle;
}

- (CGFloat)distanceFromCenter
{
	return sqrt(pow(self.currentLocation.x - self.longPressLocation.x, 2) + pow(self.currentLocation.y - self.longPressLocation.y, 2));
}

- (CGFloat)toleranceDistance
{
	return (self.radius - kMLMainItemSize / (2 * sqrt(2)) - kMLMenuItemSize / (2 * sqrt(2)));
}

- (CGFloat)distanceFromItem
{
	return fabs([self distanceFromCenter] - self.radius) - kMLMenuItemSize / (2 * sqrt(2));
}

@end
