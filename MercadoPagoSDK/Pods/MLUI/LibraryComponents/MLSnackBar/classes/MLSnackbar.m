//
// MLSnackBar.m
// MLUI
//
// Created by Julieta Puente on 26/2/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLSnackbar.h"
#import "UIFont+MLFonts.h"
#import "MLUIBundle.h"

@interface MLSnackbarButton : UIButton
@property (nonatomic, strong) UIColor *backgroundHighlightedColor;
@end

@implementation MLSnackbarButton

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];

	if (highlighted) {
		self.backgroundColor = self.backgroundHighlightedColor;
	} else {
		self.backgroundColor = [UIColor clearColor];
	}
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	if (selected) {
		self.backgroundColor = self.backgroundHighlightedColor;
	} else {
		self.backgroundColor = [UIColor clearColor];
	}
}

@end

@interface MLKeyboardInfo : NSObject
@property (nonatomic) CGFloat keyboardHeight;
+ (instancetype)sharedInstance;
@end

@interface MLSnackbar ()
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet MLSnackbarButton *actionButton;
@property (strong, nonatomic) UIView *view;
@property (nonatomic, copy) void (^actionBlock)(void);
@property (nonatomic, copy) MLSnackbarDismissBlock dismissBlock;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *labelButtonSpacing;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonTrailingConstraint;
@property (nonatomic) MLSnackbarDuration duration;
@property (nonatomic) CGRect snackbarFrame;
@property (nonatomic) CGRect snackbarInitialFrame;
@property (nonatomic) CGFloat parentHeight;
@property (nonatomic) BOOL isShowingSnackbar;
@property (nonatomic) BOOL isAnimating;
@property (nonatomic) BOOL isDesappearing;
@property (nonatomic, strong) UIPanGestureRecognizer *gesture;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic) long durationInMillis;
@property (nonatomic, copy) void (^pendingAction)(void);

@end

static CGFloat const kMLSnackbarAnimationDuration = 0.3;
static int const kMLSnackbarOneLineViewHeight = 48;
static int const kMLSnackbarTwoLineViewHeight = 82;
static int const kMLSnackbarOneLineComponentHeight = 20;
static int const kMLSnackbarOneLineTopSpacing = 14;
static int const kMLSnackbarTwoLineTopSpacing = 24;
static int const kMLSnackbarLabelButtonSpacing = 24;

@implementation MLSnackbar

+ (instancetype)showWithTitle:(NSString *)title type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled
{
	return [MLSnackbar showWithTitle:title actionTitle:nil actionBlock:nil type:type duration:duration dismissGestureEnabled:dismissGestureEnabled];
}

+ (instancetype)showWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration
{
	return [MLSnackbar showWithTitle:title actionTitle:buttonTitle actionBlock:actionBlock type:type duration:duration dismissGestureEnabled:YES];
}

+ (instancetype)showWithTitle:(NSString *)title type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration
{
	return [MLSnackbar showWithTitle:title actionTitle:nil actionBlock:nil type:type duration:duration dismissGestureEnabled:YES];
}

+ (instancetype)showWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled
{
	return [MLSnackbar showWithTitle:title actionTitle:buttonTitle actionBlock:actionBlock type:type duration:duration dismissGestureEnabled:dismissGestureEnabled dismissBlock:nil];
}

+ (instancetype)showWithTitle:(NSString *)title type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled dismissBlock:(MLSnackbarDismissBlock)dismissBlock
{
	return [MLSnackbar showWithTitle:title actionTitle:nil actionBlock:nil type:type duration:duration dismissGestureEnabled:dismissGestureEnabled dismissBlock:dismissBlock];
}

+ (instancetype)showWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissBlock:(MLSnackbarDismissBlock)dismissBlock
{
	return [MLSnackbar showWithTitle:title actionTitle:buttonTitle actionBlock:actionBlock type:type duration:duration dismissGestureEnabled:YES dismissBlock:dismissBlock];
}

+ (instancetype)showWithTitle:(NSString *)title type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissBlock:(MLSnackbarDismissBlock)dismissBlock
{
	return [MLSnackbar showWithTitle:title actionTitle:nil actionBlock:nil type:type duration:duration dismissGestureEnabled:YES dismissBlock:dismissBlock];
}

+ (instancetype)showWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled dismissBlock:(MLSnackbarDismissBlock)dismissBlock
{
	MLSnackbar *snackbar = [MLSnackbar sharedInstance];
	__weak typeof(snackbar)weakSnackbar = snackbar;

	if (snackbar.isDesappearing) {
		snackbar.pendingAction = ^{[weakSnackbar setUpSnackbarWithTitle:title actionTitle:buttonTitle actionBlock:actionBlock type:type duration:duration dismissGestureEnabled:dismissGestureEnabled dismissBlock:dismissBlock];
		};
	} else {
		CGRect screenRect = [[UIScreen mainScreen] bounds];
		snackbar.parentHeight = CGRectGetHeight(screenRect);
		snackbar.frame = CGRectMake(0, CGRectGetHeight(screenRect) - CGRectGetHeight(snackbar.view.frame) - [[MLKeyboardInfo sharedInstance] keyboardHeight], CGRectGetWidth(screenRect), CGRectGetHeight(snackbar.view.frame));

		if (snackbar.isShowingSnackbar) {
			snackbar.pendingAction = ^{[weakSnackbar setUpSnackbarWithTitle:title actionTitle:buttonTitle actionBlock:actionBlock type:type duration:duration dismissGestureEnabled:dismissGestureEnabled dismissBlock:dismissBlock];
			};
			[snackbar removeSnackbarWithAnimation:MLSnackbarDismissCauseNone];
		} else {
			[snackbar setUpSnackbarWithTitle:title actionTitle:buttonTitle actionBlock:actionBlock type:type duration:duration dismissGestureEnabled:dismissGestureEnabled dismissBlock:dismissBlock];
		}

		[[NSNotificationCenter defaultCenter] addObserver:snackbar selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
	}

	return snackbar;
}

- (void)setUpSnackbarWithTitle:(NSString *)title actionTitle:(NSString *)buttonTitle actionBlock:(void (^)(void))actionBlock type:(MLSnackbarType *)type duration:(MLSnackbarDuration)duration dismissGestureEnabled:(BOOL)dismissGestureEnabled dismissBlock:(MLSnackbarDismissBlock)dismissBlock
{
	self.messageLabel.text = title;
	self.messageLabel.textColor = type.titleFontColor;
	self.messageLabel.font = [UIFont ml_lightSystemFontOfSize:kMLFontsSizeXSmall];

	self.view.backgroundColor = type.backgroundColor;

	if (buttonTitle != nil && actionBlock != nil) {
		[self.actionButton setTitle:buttonTitle forState:UIControlStateNormal];
		[self.actionButton setTitleColor:type.actionFontColor forState:UIControlStateNormal];
		[self.actionButton setTitleColor:type.actionFontHighlightColor forState:UIControlStateHighlighted];
		[self.actionButton setTitleColor:type.actionFontHighlightColor forState:UIControlStateSelected];
		self.actionButton.titleLabel.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeXSmall];
		self.actionButton.backgroundHighlightedColor = type.actionBackgroundHighlightColor;
		self.actionButton.layer.cornerRadius = 4.0f;
		self.actionBlock = actionBlock;
		[self.actionButton addTarget:self action:@selector(actionButtonDismissSnackbar) forControlEvents:UIControlEventTouchUpInside];
		self.actionButton.hidden = NO;
		self.labelButtonSpacing.constant = kMLSnackbarLabelButtonSpacing;
		[self.actionButton setContentCompressionResistancePriority:751 forAxis:UILayoutConstraintAxisHorizontal];
		self.buttonTrailingConstraint.constant = 24;
	} else {
		// si no se recibe título del botón o un bloque de acción, se esconde el botón
		self.actionButton.hidden = YES;
		self.labelButtonSpacing.constant = 0;
		[self.actionButton setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
		self.buttonTrailingConstraint.constant = 0;
	}
	if (dismissGestureEnabled) {
		self.gesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(swipeAnimation:)];
		[self addGestureRecognizer:self.gesture];
	}
	self.dismissBlock = dismissBlock;

	[self updateLayout];
	self.snackbarFrame = self.frame;
	self.snackbarInitialFrame = CGRectMake(CGRectGetMinX(self.snackbarFrame), CGRectGetMaxY(self.snackbarFrame), CGRectGetWidth(self.snackbarFrame), CGRectGetHeight(self.snackbarFrame));

	[self show];

	if (duration != MLSnackbarDurationIndefinitely) {
		self.durationInMillis = [self durationInMilliseconds:duration];
		if (self.durationInMillis > 0) {
			self.timer = [NSTimer scheduledTimerWithTimeInterval:self.durationInMillis / 1000.0 target:self selector:@selector(snackbarTimeOut) userInfo:nil repeats:NO];
		}
	}
}

+ (instancetype)sharedInstance
{
	static MLSnackbar *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (id)init
{
	if (self = [super init]) {
		self.view = [[MLUIBundle mluiBundle] loadNibNamed:NSStringFromClass([MLSnackbar class])
		                                            owner:self
		                                          options:nil].firstObject;

		self.view.translatesAutoresizingMaskIntoConstraints = NO;

		[self addSubview:self.view];

		NSDictionary *views = @{@"view" : self.view};
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[view]-0-|"
		                                                             options:0
		                                                             metrics:nil
		                                                               views:views]];
		[self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[view]-0-|"
		                                                             options:0
		                                                             metrics:nil
		                                                               views:views]];
	}

	return self;
}

- (void)animateForKeyboardNotification:(NSNotification *)notification
{
	if (!self.isShowingSnackbar) {
		return;
	}

	NSDictionary *info = [notification userInfo];
	UIViewAnimationCurve curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
	double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

	BOOL movingUp = [notification.name isEqualToString:UIKeyboardWillShowNotification];

	CGFloat newY = CGRectGetMinY(self.frame) + (movingUp ? -1 : 1) * [[MLKeyboardInfo sharedInstance] keyboardHeight];

	__weak typeof(self)weakSelf = self;

	[UIView animateWithDuration:duration delay:0 options:curve << 16 animations: ^{
	    weakSelf.frame = CGRectMake(CGRectGetMinX(weakSelf.frame), newY, CGRectGetWidth(weakSelf.frame), CGRectGetHeight(weakSelf.frame));
		} completion:nil];
}

- (void)updateLayout
{
	[self layoutIfNeeded];

	[self.messageLabel sizeToFit];
	if (CGRectGetHeight(self.messageLabel.frame) > kMLSnackbarOneLineComponentHeight) {
		self.frame = CGRectMake(self.frame.origin.x, self.parentHeight - kMLSnackbarTwoLineViewHeight - [[MLKeyboardInfo sharedInstance] keyboardHeight], self.frame.size.width, kMLSnackbarTwoLineViewHeight);
		self.labelTopConstraint.constant = kMLSnackbarTwoLineTopSpacing;
	} else {
		self.frame = CGRectMake(self.frame.origin.x, self.parentHeight - kMLSnackbarOneLineViewHeight - [[MLKeyboardInfo sharedInstance] keyboardHeight], self.frame.size.width, kMLSnackbarOneLineViewHeight);
		self.labelTopConstraint.constant = kMLSnackbarOneLineTopSpacing;
	}

	[self layoutIfNeeded];
}

- (void)show
{
	// get the current position
	CGRect currentFrame = [[self.layer presentationLayer] frame];
	CGFloat currentMinY = CGRectGetMinY(currentFrame);

	// weakSelf
	__weak typeof(self)weakSelf = self;

	// if other snackbar is animating, we need to disappear it before showing new one
	if (self.isAnimating) {
		// if snackbar isn't visible, set the default initial position for animation
		if (currentMinY == 0 || currentMinY < CGRectGetMinY(self.snackbarFrame)) {
			self.snackbarInitialFrame = CGRectMake(CGRectGetMinX(self.snackbarFrame), CGRectGetMaxY(self.snackbarFrame), CGRectGetWidth(self.snackbarFrame), CGRectGetHeight(self.snackbarFrame));
		} else {
			self.snackbarInitialFrame = currentFrame;
		}
		self.pendingAction = ^{[weakSelf show];
		};
		if (!self.isDesappearing) {
			[self removeSnackbarWithAnimation:MLSnackbarDismissCauseNone];
		}
	} else {
		// get remaining distance constant
		CGFloat distance = CGRectGetMinY(self.snackbarInitialFrame) / CGRectGetMaxY(self.snackbarFrame);

		// perform animation
		self.frame = self.snackbarInitialFrame;
		[UIView animateWithDuration:kMLSnackbarAnimationDuration * distance delay:0 options:UIViewAnimationOptionCurveEaseOut animations: ^{
		    weakSelf.frame = weakSelf.snackbarFrame;
		    UIViewController *topViewController = [weakSelf topViewController];
		    UIView *parentView = topViewController.view;
		    [parentView addSubview:weakSelf];
		    weakSelf.isAnimating = YES;
		} completion: ^(BOOL finished) {
		    weakSelf.isShowingSnackbar = YES;
		    weakSelf.isAnimating = NO;
		}];
	}
}

- (void)snackbarTimeOut
{
	[self removeSnackbarWithAnimation:MLSnackbarDismissCauseDuration];
}

- (void)dismissSnackbar
{
	[self removeSnackbarWithAnimation:MLSnackbarDismissCauseNone];
}

- (UIViewController *)rootViewController
{
	return [[[[UIApplication sharedApplication] delegate] window] rootViewController];
}

- (UIViewController *)topViewController
{
	UIViewController *topViewController = [self rootViewController];

	while ([topViewController presentedViewController] != nil) {
		topViewController = [topViewController presentedViewController];
	}
	return topViewController;
}

- (void)actionButtonDismissSnackbar
{
	[self removeSnackbarWithAnimation:MLSnackbarDismissCauseActionButton];
}

- (IBAction)actionButtonCancelTimer:(id)sender
{
	// cancel timer for button touch down
	[self.timer invalidate];
}

- (long)durationInMilliseconds:(MLSnackbarDuration)duration
{
	switch (duration) {
		case MLSnackbarDurationShort: {
			return 2000;
			break;
		}

		case MLSnackbarDurationLong: {
			return 3500;
			break;
		}

		default: {
			return -1;
			break;
		}
	}
}

- (void)swipeAnimation:(UIPanGestureRecognizer *)gesture
{
	CGRect frame = self.snackbarFrame;

	CGPoint translate = [gesture translationInView:gesture.view];
	CGFloat percent = translate.x / gesture.view.bounds.size.width;
	UIPercentDrivenInteractiveTransition *interactionController;

	if (gesture.state == UIGestureRecognizerStateBegan) {
		interactionController = [[UIPercentDrivenInteractiveTransition alloc] init];
		// cancel timer while swipe interaction is occuring
		[self.timer invalidate];
	} else if (gesture.state == UIGestureRecognizerStateChanged) {
		self.frame = CGRectMake(translate.x, CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
		self.alpha = 1 - fabs(percent);
		[interactionController updateInteractiveTransition:percent];
	} else if (gesture.state == UIGestureRecognizerStateEnded) {
		CGRect finalFrame;
		if (translate.x > 0) {
			finalFrame = CGRectMake(CGRectGetMaxX(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
		} else {
			finalFrame = CGRectMake(CGRectGetMinX(frame) - CGRectGetWidth(frame), CGRectGetMinY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
		}
		if (fabs(percent) > 0.2) {
			__weak typeof(self)weakSelf = self;

			[UIView animateWithDuration:kMLSnackbarAnimationDuration animations: ^{
			    weakSelf.frame = finalFrame;
			    weakSelf.alpha = 0;
			} completion: ^(BOOL finished) {
			    [interactionController finishInteractiveTransition];
			    [weakSelf removeFromSuperview];
			    weakSelf.frame = frame;
			    weakSelf.alpha = 1;
			    weakSelf.isShowingSnackbar = NO;
			    [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
			    [weakSelf removeGestureRecognizer:gesture];
			    if (weakSelf.dismissBlock != nil) {
			        weakSelf.dismissBlock(MLSnackbarDismissCauseSwipe);
				}
			}];
		} else {
			__weak typeof(self)weakSelf = self;

			[UIView animateWithDuration:kMLSnackbarAnimationDuration animations: ^{
			    weakSelf.frame = frame;
			    weakSelf.alpha = 1;
			}];
			[interactionController cancelInteractiveTransition];

			// if swipe was canceled, the timer needs to restart
			if (self.durationInMillis > 0) {
				self.timer = [NSTimer scheduledTimerWithTimeInterval:self.durationInMillis / 1000.0 target:self selector:@selector(snackbarTimeOut) userInfo:nil repeats:NO];
			}
		}
	}
}

- (void)removeSnackbarWithAnimation:(MLSnackbarDismissCause)cause
{
	CGRect frame = self.frame;

	__weak typeof(self)weakSelf = self;

	MLSnackbarDismissBlock dismissBlock = [self.dismissBlock copy];
	void (^actionBlock)(void) = [self.actionBlock copy];

	[UIView animateWithDuration:kMLSnackbarAnimationDuration delay:0 options:UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseOut animations: ^{
	    weakSelf.isAnimating = YES;
	    weakSelf.isDesappearing = YES;
	    [weakSelf.timer invalidate];
	    weakSelf.frame = CGRectMake(CGRectGetMinX(frame), CGRectGetMaxY(frame), CGRectGetWidth(frame), CGRectGetHeight(frame));
	} completion: ^(BOOL finished) {
	    weakSelf.alpha = 1;
	    [weakSelf removeFromSuperview];
	    [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
	    [weakSelf removeGestureRecognizer:weakSelf.gesture];
	    weakSelf.isShowingSnackbar = NO;
	    weakSelf.isDesappearing = NO;
	    weakSelf.isAnimating = NO;

	    // perfom the action block if dismiss ocurred beacuse the Action Button was pressed
	    if (cause == MLSnackbarDismissCauseActionButton) {
	        if (actionBlock) {
	            actionBlock();
			}
		}

	    if (dismissBlock != nil) {
	        dismissBlock(cause);
		}

	    // perfom any pending action after the animation finished
	    if (weakSelf.pendingAction) {
	        weakSelf.pendingAction();
	        weakSelf.pendingAction = nil;
		}
	}];
}

- (void)didRotate:(NSNotification *)notification
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];
	// take keyboard height into account when device rotates
	self.frame = CGRectMake(0, CGRectGetHeight(screenRect) - CGRectGetHeight(self.view.frame) - [[MLKeyboardInfo sharedInstance] keyboardHeight], CGRectGetWidth(screenRect), CGRectGetHeight(self.view.frame));
}

@end

@implementation MLKeyboardInfo

+ (void)load
{
	[MLKeyboardInfo sharedInstance];
}

+ (instancetype)sharedInstance
{
	static MLKeyboardInfo *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});
	return sharedInstance;
}

- (id)init
{
	if (self = [super init]) {
		self.keyboardHeight = 0.0f;
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(keyboardWillShow:)
		                                             name:UIKeyboardWillShowNotification object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self
		                                         selector:@selector(keyboardWillHide:)
		                                             name:UIKeyboardWillHideNotification object:nil];
	}
	return self;
}

- (void)keyboardWillShow:(NSNotification *)notification
{
	NSDictionary *info = [notification userInfo];

	// If keyboard was already visible, snackbar should not animate
	if (self.keyboardHeight == 0) {
		self.keyboardHeight = CGRectGetHeight([info[UIKeyboardFrameEndUserInfoKey] CGRectValue]);
		[[MLSnackbar sharedInstance] animateForKeyboardNotification:notification];
	}
}

- (void)keyboardWillHide:(NSNotification *)notification
{
	[[MLSnackbar sharedInstance] animateForKeyboardNotification:notification];
	self.keyboardHeight = 0.0f; // Set to zero after the animation because it uses this height
}

@end
