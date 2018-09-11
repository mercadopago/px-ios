//
// NSAttributedStringMLHtmlHelper.m
// MLUI
//
// Created by amargalef on 6/7/16.
// Copyright © 2016 MercadoLibre. All rights reserved.
//

#import "MLHtml.h"
#import <MLUI/UIFont+MLFonts.h>

/**
 *  Error domain to identify errors from this class
 */
NSString *const kMLHtmlErrorDomain = @"com.mercadolibre.ui.html";

/**
 *  Error code
 */
NSInteger const kMLHtmlSyntaxErrorCode = 1;

#pragma mark - Supported Html Tags

// Bold tag
static NSString *const kHTMLBoldTag = @"b";

// Underline tag
static NSString *const kHTMLUnderlineTag = @"u";

// Strike tag
static NSString *const kHTMLStrikeTag = @"s";

// Big tag
static NSString *const kHTMLBigTag = @"big";

// Small tag
static NSString *const kHTMLSmallTag = @"small";

// Line break tag
static NSString *const kHTMLBrTag = @"br";

#pragma mark - Parsing html tags

// Pattern used to detect html tags with optional color attribute
static NSString *const openTagPattern = @"<([a-zA-Z][a-zA-Z0-9]*)\\s*(?:color\\s*=\\s*\\\"([^\\\"]*)\\\")*[^>]*>";

// Pattern used to detect ending html tags
static NSString *const endTagPattern = @"</([a-zA-Z][a-zA-Z0-9]*)>";

// Patter used to detect closed html tags
static NSString *const closedTagPattern = @"<([a-zA-Z][a-zA-Z0-9]*)\\s*/>";

#pragma mark - Attributes config

// Font size increment when a tag '<big>' or '<small>' is detected
static const CGFloat kBigSmallFontIncrement = 3;

// Default font color to be used when No tag is detected
#define kDefaultColor [UIColor blackColor]

@implementation MLHtml

/**
 *  Retorna una instancia de UIColor con el color definido en hexadecimal
 *
 *  @param hexString color definido en exadecimal, en formato RGB / ARGB / RRGGBB /AARRGGBB
 *
 *  @return Instancia de UIColor
 */
+ (UIColor *)colorWithHexString:(NSString *)hexString
{
	NSString *colorString = [[hexString stringByReplacingOccurrencesOfString:@"#" withString:@""] uppercaseString];
	CGFloat alpha, red, blue, green;
	switch ([colorString length]) {
		case 3: { // #RGB
			alpha = 1.0f;
			red = [self colorComponentFrom:colorString start:0 length:1];
			green = [self colorComponentFrom:colorString start:1 length:1];
			blue = [self colorComponentFrom:colorString start:2 length:1];
			break;
		}

		case 4: { // #ARGB
			alpha = [self colorComponentFrom:colorString start:0 length:1];
			red = [self colorComponentFrom:colorString start:1 length:1];
			green = [self colorComponentFrom:colorString start:2 length:1];
			blue = [self colorComponentFrom:colorString start:3 length:1];
			break;
		}

		case 6: { // #RRGGBB
			alpha = 1.0f;
			red = [self colorComponentFrom:colorString start:0 length:2];
			green = [self colorComponentFrom:colorString start:2 length:2];
			blue = [self colorComponentFrom:colorString start:4 length:2];
			break;
		}

		case 8: { // #AARRGGBB
			alpha = [self colorComponentFrom:colorString start:0 length:2];
			red = [self colorComponentFrom:colorString start:2 length:2];
			green = [self colorComponentFrom:colorString start:4 length:2];
			blue = [self colorComponentFrom:colorString start:6 length:2];
			break;
		}

		default: {
			[NSException raise:@"Invalid color value" format:@"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
			break;
		}
	}
	return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

+ (CGFloat)colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length
{
	NSString *substring = [string substringWithRange:NSMakeRange(start, length)];
	NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat:@"%@%@", substring, substring];
	unsigned hexComponent;
	[[NSScanner scannerWithString:fullHex] scanHexInt:&hexComponent];
	return hexComponent / 255.0;
}

/**
 *  Overrides attributes with the configuration of the html tag
 *
 *  @param tag   html tag detected
 *  @param attrs current attributes to override
 */
+ (void)overrideAttributesWithTag:(NSString *)tag dictionary:(NSMutableDictionary *)attrs
{
	id object = [attrs objectForKey:NSFontAttributeName];
	UIFont *currentFont = [self isNullOrEmpty:object] ? nil : object;

	if ([tag isEqualToString:kHTMLBoldTag]) {
		currentFont = [UIFont ml_boldSystemFontOfSize:currentFont.pointSize];
	} else if ([tag isEqualToString:kHTMLUnderlineTag]) {
		attrs[NSUnderlineStyleAttributeName] = @(NSUnderlineStyleSingle);
	} else if ([tag isEqualToString:kHTMLStrikeTag]) {
		attrs[NSStrikethroughStyleAttributeName] = @(NSUnderlineStyleSingle);
		attrs[NSBaselineOffsetAttributeName] = @0;
	} else if ([tag isEqualToString:kHTMLBigTag]) {
		currentFont = [currentFont fontWithSize:currentFont.pointSize + kBigSmallFontIncrement];
	} else if ([tag isEqualToString:kHTMLSmallTag]) {
		currentFont = [currentFont fontWithSize:MAX(currentFont.pointSize - kBigSmallFontIncrement, 0)];
	}

	if (currentFont) {
		attrs[NSFontAttributeName] = currentFont;
	}
}

+ (BOOL)isNullOrEmpty:(id)object
{
	if (object == nil || [object isEqual:[NSNull null]]) {
		return YES;
	}

	if ([object isKindOfClass:[NSString class]]) {
		if ([object isEqualToString:@""]) {
			return YES;
		}
	}

	return NO;
}

/**
 *  Update a mutable attributed string depending on closeTag value
 *
 *  @param attributedString attributed string to update
 *  @param closedTag        tag to be used for the update
 */
+ (void)updateAttributedString:(NSMutableAttributedString *)attributedString withTag:(NSString *)closedTag attributes:(NSMutableDictionary <NSAttributedStringKey, id> *)attrs
{
	if ([closedTag isEqualToString:kHTMLBrTag]) {
		NSAttributedString *newLine = [[NSAttributedString alloc] initWithString:@"\n" attributes:attrs];
		[attributedString appendAttributedString:newLine];
	}
}

/**
 *  Overrides font color
 *
 *  @param colorStr color string in hex format
 *  @param attrs current attributes to override
 */
+ (void)overrideAttributesWithColor:(NSString *)colorStr dictionary:(NSMutableDictionary *)attrs
{
	// using a try catch because ml_colorWithHexString can raise a exception
	@try {
		NSString *trimmedColor = [colorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		UIColor *color = [self colorWithHexString:trimmedColor];
		attrs[NSForegroundColorAttributeName] = color;
	}
	@catch (NSException *exception)
	{
		// do nothing
	}
}

/**
 *  Find the nearest match result of the array
 *
 *  @param values array with match results
 *
 *  @return the nearest result or nil if there isn't a valid match
 */
+ (NSTextCheckingResult *)nearest:(NSArray <NSTextCheckingResult *> *)values
{
	NSTextCheckingResult *nearest = nil;
	for (NSTextCheckingResult *current in values) {
		if (current.range.location != NSNotFound && (!nearest || nearest.range.location > current.range.location)) {
			nearest = current;
		}
	}
	return nearest;
}

+ (void)addObjectIfNotNil:(NSMutableArray *)array object:(id)object
{
	if (object) {
		[array addObject:object];
	}
}

/**
 *  Convenient function to parse html without custom attributes
 *
 *  @param htmlText string with the html text
 *  @param error    error to return
 *
 *  @return NSAttributedString with the html or nil if occurs an error.
 */
+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText error:(NSError *__autoreleasing *)error
{
	return [self attributedStringWithHtml:htmlText attributes:nil attributesProvider:nil error:error];
}

+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs error:(NSError *__autoreleasing *)error
{
	return [self attributedStringWithHtml:htmlText attributes:attrs attributesProvider:nil error:error];
}

/**
 *  Return YES if the tag needs a closing tag
 *
 *  @param tag the tag to inspect
 *
 *  @return BOOL value
 */
+ (BOOL)needCloseTag:(NSString *)tag
{
	return ![tag isEqualToString:kHTMLBrTag];
}

+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText
                              attributesProvider:(id <MLHtmlAttributeProvider>)attributesProvider
                                           error:(NSError *__autoreleasing *)error
{
	return [self attributedStringWithHtml:htmlText attributes:nil attributesProvider:attributesProvider error:error];
}

+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText
                              attributesProvider:(id <MLHtmlAttributeProvider>)attributesProvider
                                      attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs
                                           error:(NSError *__autoreleasing *)error
{
	return [self attributedStringWithHtml:htmlText attributes:attrs attributesProvider:attributesProvider error:error];
}

/**
 *  Creates a NSAttributedString with a html text.
 *  The process uses default Attributes and custom attributes and returns the created NSAttributedString or nil if occurs an error an or the htmlText is nil.
 *
 *  @param htmlText html text to be parsed
 *  @param attrs    custom attributes
 *  @param error    out param to report errors
 *
 *  @return NSAttributedString with the html
 */
+ (NSAttributedString *)attributedStringWithHtml:(NSString *)htmlText
                                      attributes:(nullable NSDictionary <NSAttributedStringKey, id> *)attrs
                              attributesProvider:(id <MLHtmlAttributeProvider>)attributesProvider
                                           error:(NSError *__autoreleasing *)error
{
	if (!htmlText) {
		return nil;
	}

	if (htmlText.length == 0) {
		return [[NSAttributedString alloc] initWithString:@"" attributes:attrs];
	}

	// set up regex to use for open an end tag
	NSError *unusedError = nil;

	NSRegularExpression *openTagRegex = [NSRegularExpression regularExpressionWithPattern:openTagPattern options:0 error:&unusedError];
	if (unusedError) {
		return nil;
	}

	NSRegularExpression *endTagRegex = [NSRegularExpression regularExpressionWithPattern:endTagPattern options:0 error:&unusedError];
	if (unusedError) {
		return nil;
	}

	NSRegularExpression *closedTagRegex = [NSRegularExpression regularExpressionWithPattern:closedTagPattern options:0 error:&unusedError];
	if (unusedError) {
		return nil;
	}

	// initial values for
	NSUInteger currentFrom = 0;
	NSUInteger to = htmlText.length - 1;

	// add default attributes to attributes stack
	NSDictionary *defaultAttributes = @{
		NSFontAttributeName : [UIFont ml_regularSystemFontOfSize:kMLFontsSizeXXSmall],
		NSForegroundColorAttributeName : kDefaultColor
	};

	NSMutableDictionary *firstAttributes = [defaultAttributes mutableCopy];
	if (attrs) {
		[firstAttributes addEntriesFromDictionary:attrs];
	}

	NSMutableArray <NSDictionary <NSString *, id> *> *attributesStack = [@[firstAttributes] mutableCopy];

	// Add Tag stack used for validation
	NSMutableArray *tagStack = [[NSMutableArray alloc] init];

	// Current result
	NSMutableAttributedString *composedAttrString = [[NSMutableAttributedString alloc] init];

	do {
		// make current range
		NSRange range = NSMakeRange(currentFrom, to - currentFrom + 1);

		NSTextCheckingResult *firstOpenResult = [openTagRegex firstMatchInString:htmlText options:0 range:range];
		NSTextCheckingResult *firstEndTagResult = [endTagRegex firstMatchInString:htmlText options:0 range:range];
		NSTextCheckingResult *firstClosedTagResult = [closedTagRegex firstMatchInString:htmlText options:0 range:range];

		NSMutableArray <NSTextCheckingResult *> *results = [NSMutableArray array];
		[self addObjectIfNotNil:results object:firstOpenResult];
		[self addObjectIfNotNil:results object:firstEndTagResult];
		[self addObjectIfNotNil:results object:firstClosedTagResult];

		// Search first match for open or closed tag
		NSTextCheckingResult *nearestResult = [self nearest:results];

		// if no results, uses the last attribute with the rest of the text
		if (!nearestResult) {
			NSString *subString = [htmlText substringWithRange:range];
			NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:subString attributes:[attributesStack lastObject]];
			[composedAttrString appendAttributedString:attrString];

			// increment the index to fail the while condition
			currentFrom = to + 1;

			// check if html is well formed
			if (tagStack.count > 0 && [self needCloseTag:tagStack.lastObject]) {
				*error = [NSError errorWithDomain:kMLHtmlErrorDomain
				                             code:kMLHtmlSyntaxErrorCode
				                         userInfo:@{
				          NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Open tag not found: %@", tagStack.lastObject]
				}];
				return nil;
			}
		} else {
		    // if exists a text before the next open/close tag, then it uses the last attributes
		    if (nearestResult.range.location > currentFrom) {
		        NSRange subrange = NSMakeRange(currentFrom, nearestResult.range.location - currentFrom);
		        NSString *subString = [htmlText substringWithRange:subrange];
		        NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:subString attributes:[attributesStack lastObject]];
		        [composedAttrString appendAttributedString:attrString];
			}

		    BOOL isOpenTag = nearestResult == firstClosedTagResult || nearestResult == firstOpenResult;

		    if (isOpenTag) {
		        // overrides attributes based on the html tag, for example, the tag <b> makes a font be bold
		        NSRange tagRange = [firstOpenResult rangeAtIndex:1];
		        NSString *tag = [htmlText substringWithRange:tagRange];

		        // if the next tag is an open tag, then push new attributes based on the last attributes of the stack
		        // overrided with the details of the html tag
		        NSMutableDictionary *currentAttributes = [[attributesStack lastObject] mutableCopy];
		        [self overrideAttributesWithTag:tag dictionary:currentAttributes];

		        // overrides attributes based on the html tag attributes, at this moment only 'color' is supported with hexa values
		        // only open tags are supported for colors
		        if (nearestResult == firstOpenResult) {
		            NSRange colorRange = [firstOpenResult rangeAtIndex:2];
		            if (colorRange.location != NSNotFound) {
		                NSString *color = [htmlText substringWithRange:colorRange];
		                [self overrideAttributesWithColor:color dictionary:currentAttributes];
					}
				}

		        // If exist an attributesProvider, use it to process current attributes
		        if ([attributesProvider respondsToSelector:@selector(processAttributesForTag:attributes:)]) {
		            [attributesProvider processAttributesForTag:tag attributes:currentAttributes];
				}

		        // update if necesary
		        [self updateAttributedString:composedAttrString withTag:tag attributes:currentAttributes];

		        // add to stack the current tag and the attributes
		        if ([self needCloseTag:tag]) {
		            [tagStack addObject:tag];
		            [attributesStack addObject:currentAttributes];
				}
			} else {
		        NSRange tagRange = [firstEndTagResult rangeAtIndex:1];
		        NSString *tag = [htmlText substringWithRange:tagRange];

		        // check if html is well formed
		        if (tagStack.count  == 0 || ![tagStack.lastObject isEqualToString:tag]) {
		            *error = [NSError errorWithDomain:kMLHtmlErrorDomain
		                                         code:kMLHtmlSyntaxErrorCode
		                                     userInfo:@{
		                      NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Open tag not found: %@", tagStack.lastObject]
					}];
		            return nil;
				}

		        // pop from stack last attributes and tag
		        [attributesStack removeLastObject];
		        [tagStack removeLastObject];
			}

		    // processes the next content
		    currentFrom = nearestResult.range.location + nearestResult.range.length;
		}
	} while (currentFrom <= to);

	return composedAttrString;
}

@end
