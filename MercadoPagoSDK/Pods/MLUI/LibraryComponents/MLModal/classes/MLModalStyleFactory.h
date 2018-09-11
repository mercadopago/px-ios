//
// MLModalStyleFactory.h
// Pods
//
// Created by Jonatan Urquiza on 9/12/17.
//
//

@class MLModalConfigStyle;

/**
   Modal Factory from modal types
 */
NS_ASSUME_NONNULL_BEGIN
@interface MLModalStyleFactory : NSObject

	typedef NS_ENUM (NSInteger, MLModalType)
{
	MLModalTypeML = 0,
	MLModalTypeMP
};

/**
 *  Config style object from modal type
 *
 *  @param modalType    modal type
 *  @return             configstyle object
 */
+ (MLModalConfigStyle *)configForModalType:(MLModalType)modalType;

@end
NS_ASSUME_NONNULL_END
