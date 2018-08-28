//
//  JZTabView.h
//
//  Created by Jeremy Zhu on 20/04/2017.
//
//

#import <UIKit/UIKit.h>

@class JZTabView;

@protocol JZTabViewDelegate <NSObject>
@required
- (NSUInteger)countOfTabsInTabView:(JZTabView*)tabView;
- (NSString*)tabView:(JZTabView*) tabView titleAt:(NSUInteger) index;

@optional
- (void)tabView:(JZTabView*) tabView willShowTabAtIndex:(NSUInteger) index;
- (UIColor *)hightlightTextColorOfTabHeadInTabView:(JZTabView*) tabView;
- (UIColor *)inactiveTextColorOfTabHeadInTabView:(JZTabView*) tabView;
- (UIColor *)sliderColorOfTabHeadInTabView:(JZTabView*) tabView;
- (UIView *)tabView:(JZTabView *)tabView pageViewAt:(NSUInteger) index;

@end

@interface JZTabView : UIView

@property (weak, nonatomic) IBOutlet id<JZTabViewDelegate> delegate;

@end
