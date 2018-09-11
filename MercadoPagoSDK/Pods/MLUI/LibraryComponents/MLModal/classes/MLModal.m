//
// MLModal.m
// MLUI
//
// Created by Julieta Puente on 7/3/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLModal.h"
#import "FXBlurView.h"
#import "UIImage+Misc.h"
#import "UIFont+MLFonts.h"
#import "MLUIBundle.h"
#import "MLStyleSheetManager.h"

@interface MLModalButton : UIButton

@end

@implementation MLModalButton

- (void)setHighlighted:(BOOL)highlighted
{
	[super setHighlighted:highlighted];
	if (highlighted) {
		self.backgroundColor = [UIColor colorWithRed:0.f / 255.f green:0.f / 255.f blue:0.f / 255.f alpha:0.1];
	} else {
		self.backgroundColor = [UIColor clearColor];
	}
}

- (void)setSelected:(BOOL)selected
{
	[super setSelected:selected];
	if (selected) {
		self.backgroundColor = [UIColor colorWithRed:0.f / 255.f green:0.f / 255.f blue:0.f / 255.f alpha:0.1];
	} else {
		self.backgroundColor = [UIColor clearColor];
	}
}

@end

@interface MLModal () <UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView *modalView;

@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (weak, nonatomic) IBOutlet UIView *innerContainerView;
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UIView *titleViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet MLModalButton *actionButton;

@property (strong, nonatomic) MLModalButton *secondaryActionButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollViewTopConstraint;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *innerContainerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewTopConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewLeadingConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerViewBottomConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonInnerContainerVerticalSpacing;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationItem;
@property (weak, nonatomic) NSLayoutConstraint *containerViewCenterYConstraint;

@property (nonatomic, copy) void (^actionBlock)(void);
@property (nonatomic, copy) void (^secondaryActionBlock)(void);

@property (strong, nonatomic) FXBlurView *blurView;
@property (nonatomic) CGFloat topSpacing;
@property (nonatomic) CGFloat keyboardHeight;
@property (nonatomic) CGFloat scrollViewTopSpacing;
@property (nonatomic) CGFloat containerBottomSpacing;
@property (strong, nonatomic) UIViewController *innerViewController;
@property (weak, nonatomic) UIViewController *topViewController;
@property (nonatomic) BOOL keyboardIsShowing;
@property (nonatomic) BOOL scrollEnabled;
@end

static CGFloat const kMLModalAnimationDuration = 0.3;
static int const kMLModalPortraitHorizontalSpacing = 32;
static int const kMLModalLandscapeHorizontalSpacing = 80;
static int const kMLModalLandscapeTopSpacing = 60;
static int const kMLModalKeyboardVerticalBottomSpacing = 32;
static int const kMLModalKeyboardVerticalTopSpacing = 60;
static int const kMLModalKeyboardVerticalBottomSpacingWithButton = 16;
static int const kMLModalStatusBarHeight = 20;

@implementation MLModal

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController
{
	return [MLModal showModalWithViewController:innerViewController title:nil actionTitle:nil actionBlock:nil secondaryActionTitle:nil secondaryActionBlock:nil dismissBlock:nil enableScroll:YES];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController dismissBlock:(void (^)(void))dismissBlock
{
	return [MLModal showModalWithViewController:innerViewController title:nil actionTitle:nil actionBlock:nil secondaryActionTitle:nil secondaryActionBlock:nil dismissBlock:dismissBlock enableScroll:YES];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title
{
	return [MLModal showModalWithViewController:innerViewController title:title actionTitle:nil actionBlock:nil secondaryActionTitle:nil secondaryActionBlock:nil dismissBlock:nil enableScroll:YES];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock
{
	return [MLModal showModalWithViewController:innerViewController title:title actionTitle:actionTitle actionBlock:actionBlock secondaryActionTitle:nil secondaryActionBlock:nil dismissBlock:nil enableScroll:YES];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock
{
	return [MLModal showModalWithViewController:innerViewController title:nil actionTitle:actionTitle actionBlock:actionBlock secondaryActionTitle:nil secondaryActionBlock:nil dismissBlock:nil enableScroll:YES];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock
{
	return [MLModal showModalWithViewController:innerViewController title:title actionTitle:nil actionBlock:nil secondaryActionTitle:secondaryTitle secondaryActionBlock:secondaryActionBlock dismissBlock:nil enableScroll:YES];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock
{
	return [MLModal showModalWithViewController:innerViewController title:nil actionTitle:nil actionBlock:nil secondaryActionTitle:secondaryTitle secondaryActionBlock:secondaryActionBlock dismissBlock:nil enableScroll:YES];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock dismissBlock:(void (^)(void))dismissBlock enableScroll:(BOOL)enable
{
	return [MLModal showModalWithViewController:innerViewController title:title actionTitle:actionTitle actionBlock:actionBlock secondaryActionTitle:secondaryTitle secondaryActionBlock:secondaryActionBlock dismissBlock:dismissBlock enableScroll:enable configStyle:[[MLModalConfigStyle alloc] init]];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock dismissBlock:(void (^)(void))dismissBlock enableScroll:(BOOL)enable type:(MLModalType)type
{
	return [MLModal showModalWithViewController:innerViewController title:title actionTitle:actionTitle actionBlock:actionBlock secondaryActionTitle:secondaryTitle secondaryActionBlock:secondaryActionBlock dismissBlock:dismissBlock enableScroll:enable configStyle:[[MLModalConfigStyle alloc] init]];
}

+ (instancetype)showModalWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock dismissBlock:(void (^)(void))dismissBlock enableScroll:(BOOL)enable configStyle:(MLModalConfigStyle *)configStyle
{
	static MLModal *sharedModal;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedModal = [[super alloc] init];
	});

	[sharedModal setupWithViewController:innerViewController title:title actionTitle:actionTitle actionBlock:actionBlock secondaryActionTitle:secondaryTitle secondaryActionBlock:secondaryActionBlock dismissBlock:dismissBlock enableScroll:enable configStyle:configStyle];
	[sharedModal show];
	return sharedModal;
}

- (void)setupWithViewController:(UIViewController *)innerViewController title:(NSString *)title actionTitle:(NSString *)actionTitle actionBlock:(void (^)(void))actionBlock secondaryActionTitle:(NSString *)secondaryTitle secondaryActionBlock:(void (^)(void))secondaryActionBlock dismissBlock:(void (^)(void))dismissBlock enableScroll:(BOOL)enable configStyle:(MLModalConfigStyle *)configStyle
{
	// Save the inner view controller.
	self.innerViewController = innerViewController;

	// Save blocks.
	self.actionBlock = actionBlock;
	self.secondaryActionBlock = secondaryActionBlock;
	self.dismissBlock = dismissBlock;

	// Get the host view controller.
	self.topViewController = [self findTopViewController];

	// hide keyboard
	[self.topViewController.view endEditing:YES];

	// Get the modal view.
	self.modalView = [[NSBundle bundleForClass:[self class]] loadNibNamed:NSStringFromClass([MLModal class]) owner:self options:nil].firstObject;
	self.modalView.translatesAutoresizingMaskIntoConstraints = NO;

	// Add close gesture to the modal.
	UITapGestureRecognizer *closeModalTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeModal)];
	closeModalTapGestureRecognizer.delegate = self;
	[self.backgroundView addGestureRecognizer:closeModalTapGestureRecognizer];

	// Set scroll enabled
	self.scrollEnabled = enable;

	// Setup Syle
	[self setupStyleWithConfigStyle:configStyle];

	// Set the corner radius.
	self.innerContainerView.layer.cornerRadius = 4.0f;
	self.innerContainerView.clipsToBounds = YES;

	// Disable interactive pop gesture when dealing with the UINavigationController as the container of our modal.
	if ([self.topViewController isKindOfClass:[UINavigationController class]]) {
		((UINavigationController *)self.topViewController).interactivePopGestureRecognizer.enabled = NO;
	}

	// If the given inner view is a subclass of UIScrollView, we don't need to provide a scrollable container.
	if ([self.innerViewController.view isKindOfClass:[UIScrollView class]] || !self.scrollEnabled) {
		self.scrollViewTopSpacing = self.scrollViewTopConstraint.constant;
		[self.scrollView removeFromSuperview];
	}

	// Layout the inner view up depending on the given parameters: header title, action title and secondary action title.
	[self layoutInnerViewWithTitle:title actionTitle:actionTitle secondaryActionTitle:secondaryTitle configStyle:configStyle];

	// Rotation notification
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willRotate:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];

	// Keyboard notifications
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)layoutInnerViewWithTitle:(NSString *)title actionTitle:(NSString *)actionTitle secondaryActionTitle:(NSString *)secondaryTitle configStyle:(MLModalConfigStyle *)configStyle
{
	// Set the title up.
	if (title) {
		self.titleLabel.text = title;
		self.titleLabel.tintColor = configStyle.titleColor;
		self.titleLabel.font = configStyle.titleFont;
	} else {
		[self.titleViewContainer removeFromSuperview];
		self.scrollViewTopConstraint.constant = 0;
		self.scrollViewTopSpacing = 0;
	}

	// Set the action button up.
	if (self.actionBlock && actionTitle) {
		[self.actionButton setTitleColor:configStyle.tintColor forState:UIControlStateNormal];
		[self.actionButton setTitleColor:configStyle.tintColor forState:UIControlStateHighlighted];
		[self.actionButton setTitle:actionTitle forState:UIControlStateNormal];
		self.actionButton.layer.cornerRadius = 4.0f;
		[self.actionButton addTarget:self action:@selector(onActionButtonDidTouch:) forControlEvents:UIControlEventTouchUpInside];
		self.containerBottomSpacing = kMLModalKeyboardVerticalBottomSpacingWithButton;
	} else {
		[self.actionButton removeFromSuperview];
		self.innerContainerViewBottomConstraint.constant = 0;
		self.buttonInnerContainerVerticalSpacing.constant = 0;
		self.containerBottomSpacing = kMLModalKeyboardVerticalBottomSpacing;
	}

	// Set the secondary button up.
	if (self.secondaryActionBlock && secondaryTitle) {
		self.secondaryActionButton = [[MLModalButton alloc]initWithFrame:CGRectMake(0, 0, 60, 25)];
		[self.secondaryActionButton setTitleColor:configStyle.tintColor forState:UIControlStateNormal];
		self.secondaryActionButton.titleLabel.font = [UIFont ml_regularSystemFontOfSize:kMLFontsSizeMedium];
		[self.secondaryActionButton setTitle:secondaryTitle forState:UIControlStateNormal];
		self.secondaryActionButton.layer.cornerRadius = 4.0f;
		[self.secondaryActionButton addTarget:self action:@selector(onSecondaryActionButtonDidTouch:) forControlEvents:UIControlEventTouchUpInside];

		UIBarButtonItem *secondaryActionBtn = [[UIBarButtonItem alloc] initWithCustomView:self.secondaryActionButton];
		[self.navigationItem setRightBarButtonItem:secondaryActionBtn];
	}

	// Make sure the inner view works with AutoLayout.
	self.innerViewController.view.translatesAutoresizingMaskIntoConstraints = NO;
}

- (void)setupStyleWithConfigStyle:(MLModalConfigStyle *)configStyle
{
	// Apply blur.
	if (configStyle.showBlurView) {
		[self applyBlur];
	}

	self.backgroundView.backgroundColor = configStyle.backgroundColor;
	self.titleViewContainer.backgroundColor = configStyle.headerBackgroundColor;

	// Set the look and feel for the close button.
	[self.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
	self.navigationBar.shadowImage = [UIImage new];
	UIImage *closeImg = [UIImage imageNamed:@"MLModalClose" inBundle:[MLUIBundle mluiBundle] compatibleWithTraitCollection:nil];
	UIBarButtonItem *closeBtn = [[UIBarButtonItem alloc] initWithImage:closeImg
	                                                             style:UIBarButtonItemStylePlain
	                                                            target:self
	                                                            action:@selector(onCloseButtonDidTouch:)];
	closeBtn.tintColor = configStyle.tintColor;
	[self.navigationItem setLeftBarButtonItem:closeBtn];
}

- (void)show
{
	[self.topViewController.view addSubview:self.modalView];
	[self.topViewController addChildViewController:self.innerViewController];

	NSDictionary *views = @{
		@"modalView" : self.modalView,
		@"innerView" : self.innerViewController.view
	};

	if ([self.innerViewController.view isKindOfClass:[UIScrollView class]] || !self.scrollEnabled) {
		[self.innerContainerView addSubview:self.innerViewController.view];

		[self.innerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[innerView]-0-|" options:0 metrics:nil views:views]];
		[self.innerContainerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-top-[innerView]-0-|" options:0 metrics:@{@"top" : @(self.scrollViewTopSpacing)} views:views]];
	} else {
		[self.scrollView addSubview:self.innerViewController.view];

		NSLayoutConstraint *widthConstraint = [NSLayoutConstraint
		                                       constraintWithItem:self.scrollView
		                                                attribute:NSLayoutAttributeWidth
		                                                relatedBy:NSLayoutRelationEqual
		                                                   toItem:self.innerViewController.view
		                                                attribute:NSLayoutAttributeWidth
		                                               multiplier:1.0
		                                                 constant:0.0];
		[self.scrollView addConstraint:widthConstraint];

		NSLayoutConstraint *heightConstraint = [NSLayoutConstraint
		                                        constraintWithItem:self.scrollView
		                                                 attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
		                                                    toItem:self.innerViewController.view
		                                                 attribute:NSLayoutAttributeHeight
		                                                multiplier:1.0
		                                                  constant:0.0];
		heightConstraint.priority = UILayoutPriorityDefaultLow;
		[self.scrollView addConstraint:heightConstraint];

		[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[innerView]-0-|" options:0 metrics:nil views:views]];
		[self.scrollView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[innerView]-0-|" options:0 metrics:nil views:views]];
	}

	self.containerViewCenterYConstraint = [NSLayoutConstraint
	                                       constraintWithItem:self.containerView
	                                                attribute:NSLayoutAttributeCenterY
	                                                relatedBy:NSLayoutRelationEqual
	                                                   toItem:self.backgroundView
	                                                attribute:NSLayoutAttributeCenterY
	                                               multiplier:1.0
	                                                 constant:0.0];
	[self.backgroundView addConstraint:self.containerViewCenterYConstraint];

	[self.topViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[modalView]-0-|" options:0 metrics:nil views:views]];
	[self.topViewController.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[modalView]-0-|" options:0 metrics:nil views:views]];

	// Perform the animation.
	[self makeVisibleModal];
}

- (void)makeVisibleModal
{
	// Save view top spacing
	self.topSpacing = self.containerViewTopConstraint.constant;

	[self.modalView layoutIfNeeded];

	if (![self.topViewController shouldAutomaticallyForwardAppearanceMethods]) {
		[self.innerViewController beginAppearanceTransition:YES animated:YES];
	}

	// Perform the animation.
	self.modalView.alpha = 0;
	CGRect containerFinalFrame = self.innerContainerView.frame;
	self.innerContainerView.frame = CGRectOffset(containerFinalFrame, 0, 20);

	__weak typeof(self)weakSelf = self;

	[UIView animateWithDuration:kMLModalAnimationDuration animations: ^{
	    weakSelf.innerContainerView.frame = containerFinalFrame;
	    weakSelf.modalView.alpha = 1;
	} completion: ^(BOOL finished) {
	    [weakSelf.innerViewController didMoveToParentViewController:weakSelf.topViewController];
	    if (![weakSelf.topViewController shouldAutomaticallyForwardAppearanceMethods]) {
	        [weakSelf.innerViewController endAppearanceTransition];
		}
	}];
}

- (UIViewController *)findTopViewController
{
	UIViewController *topViewController = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
	while ([topViewController presentedViewController] != nil) {
		topViewController = [topViewController presentedViewController];
	}

	return topViewController;
}

- (void)applyBlur
{
	CGRect screenRect = [[UIScreen mainScreen] bounds];

	// Set the blur view up.
	self.blurView = [[FXBlurView alloc] initWithFrame:screenRect];

	// Blur doesn't calculate every time, making it performance friendly
	self.blurView.dynamic = NO;
	self.blurView.translatesAutoresizingMaskIntoConstraints = NO;
	self.blurView.blurRadius = 40;

	// Set the topViewController as the underlying view
	self.blurView.underlyingView = self.topViewController.view;

	// Add it in the view hierarchy.
	[self.modalView insertSubview:self.blurView atIndex:0];

	// Make the blur view cover the whole screen.
	[self.modalView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[blur]-0-|" options:0 metrics:nil views:@{@"blur" : self.blurView}]];
	[self.modalView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[blur]-0-|" options:0 metrics:nil views:@{@"blur" : self.blurView}]];
}

#pragma mark  - Touch events

- (IBAction)onCloseButtonDidTouch:(id)sender
{
    [self closeModal];
}

- (void)closeModal
{
    CGRect containerFinalFrame = self.innerContainerView.frame;

    [self.innerViewController willMoveToParentViewController:nil];
    if (![self.topViewController shouldAutomaticallyForwardAppearanceMethods]) {
        [self.innerViewController beginAppearanceTransition:NO animated:YES];
	}

    __weak typeof(self)weakSelf = self;

    [UIView animateWithDuration:kMLModalAnimationDuration animations: ^{
        weakSelf.innerContainerView.frame = CGRectOffset(containerFinalFrame, 0, 20);
        weakSelf.modalView.alpha = 0;
	} completion: ^(BOOL finished) {
        [weakSelf.modalView removeFromSuperview];

        [[NSNotificationCenter defaultCenter] removeObserver:weakSelf];
        [weakSelf.innerViewController removeFromParentViewController];

        // Enable the interactive pop gesture back again, if we are dealing with an UINavigationController.
        if ([weakSelf.topViewController isKindOfClass:[UINavigationController class]]) {
            ((UINavigationController *)weakSelf.topViewController).interactivePopGestureRecognizer.enabled = YES;
		}

        if (![weakSelf.topViewController shouldAutomaticallyForwardAppearanceMethods]) {
            [weakSelf.innerViewController endAppearanceTransition];
		}

        if (self.dismissBlock) {
            self.dismissBlock();
		}
	}];
}

- (void)onActionButtonDidTouch:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock();
	}

    [self closeModal];
}

- (void)onSecondaryActionButtonDidTouch:(id)sender
{
    if (self.secondaryActionBlock) {
        self.secondaryActionBlock();
	}

    [self closeModal];
}

- (void)dismissModal
{
    [self closeModal];
}

#pragma mark -  UIGesturRecognizerDelegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    return touch.view == self.backgroundView;
}

#pragma mark -  Rotation
- (void)willRotate:(NSNotification *)notification
{
    // Interface orientation indicates the orientation the device has before rotation
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.containerViewLeadingConstraint.constant = kMLModalLandscapeHorizontalSpacing;
        self.containerViewTopConstraint.constant = kMLModalLandscapeTopSpacing;
        self.containerViewBottomConstraint.constant = kMLModalLandscapeTopSpacing;
	} else {
        self.containerViewLeadingConstraint.constant = kMLModalPortraitHorizontalSpacing;
        self.containerViewTopConstraint.constant = self.topSpacing;
        self.containerViewBottomConstraint.constant = self.topSpacing;
	}
}

#pragma mark - Keyboard
- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    self.keyboardHeight = CGRectGetHeight([[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    UIViewAnimationOptions curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [self placeContainerViewForVisibleKeyboardWithHeight:self.keyboardHeight];

    __weak typeof(self)weakSelf = self;

    [UIView animateWithDuration:duration delay:0 options:curve animations: ^{
        [weakSelf.modalView layoutIfNeeded];
	} completion:nil];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    UIViewAnimationOptions curve = [[info objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue] << 16;
    double duration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];

    self.containerViewTopConstraint.constant = self.topSpacing;
    self.containerViewBottomConstraint.constant = self.topSpacing - kMLModalStatusBarHeight;

    self.containerViewCenterYConstraint = [NSLayoutConstraint constraintWithItem:self.containerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.backgroundView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0.0];
    [self.backgroundView addConstraint:self.containerViewCenterYConstraint];

    __weak typeof(self)weakSelf = self;

    [UIView animateWithDuration:duration delay:0 options:curve animations: ^{
        [weakSelf.modalView layoutIfNeeded];
	} completion:nil];
}

- (void)placeContainerViewForVisibleKeyboardWithHeight:(CGFloat)height
{
    [self.backgroundView removeConstraint:self.containerViewCenterYConstraint];
    CGFloat remainingSpace = CGRectGetHeight([[UIScreen mainScreen]bounds]) - height - [self calculateContentHeight] - kMLModalStatusBarHeight;
    CGFloat verticalSpacing = 0.5 * remainingSpace;

    if (verticalSpacing < kMLModalLandscapeTopSpacing) {
        self.containerViewTopConstraint.constant = kMLModalKeyboardVerticalTopSpacing + kMLModalStatusBarHeight;
        self.containerViewBottomConstraint.constant = height + self.containerBottomSpacing;
	} else {
        self.containerViewTopConstraint.constant = verticalSpacing + kMLModalStatusBarHeight;
        self.containerViewBottomConstraint.constant = height + verticalSpacing;
	}
}

- (CGFloat)calculateContentHeight
{
    return CGRectGetHeight(self.containerView.frame);
}

@end
