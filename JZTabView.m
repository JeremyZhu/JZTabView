//
//  JZTabView.m
//
//  Created by Jeremy Zhu on 20/04/2017.
//
//

#import "JZTabView.h"

// width for each tab head item
const CGFloat tabHeadWidth = 120;

// height for tabs head bar
const CGFloat tabHeadHeight = 44;

@interface JZTabView () {
    @private
    // the page width for each tab.
    CGFloat pageWidth;
    
    // record content view's center when every time the scroll action has done.
    CGPoint contentViewCenterSnapshot;
    
    // for storing all tab page views.
    NSMutableArray* tabPageViews;
    
    // for storing all tab head labels.
    NSMutableArray* tabHeadViews;
    
    // for storing all tab head buttons.
    NSMutableArray* tabHeadButtons;
    
    // tabs head bar
    UIView* tabsHeadBar;
    
    // scroller of tab head item.
    UIView* activePageIndicatorScroller;

    // the view contain all pages.
    UIView* contentView;
    
    // for padding the first head item's origin x value to make all head items align to horizontal center.
    CGFloat xPaddingParamForAligningCenterOfAllHeadItems;
    
    UIPanGestureRecognizer* panGestureRecognizer;
}

@property (nonatomic, readonly) NSUInteger currentPageIndex;

// How many tabs are in this tab view.
@property (readonly, nonatomic) NSUInteger pageCount;

@end


@implementation JZTabView
@synthesize currentPageIndex;

- (NSUInteger) pageCount {
    return [self.delegate countOfTabsInTabView:self];
}

- (void)setDelegate:(id<JZTabViewDelegate>)delegate {
    if (delegate) {
        _delegate = delegate;
        [self constructTabViews];
    }
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        currentPageIndex = 0;
        
        contentView = [UIView new];
        [self addSubview:contentView];

        panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panInContent:)];
        [contentView addGestureRecognizer:panGestureRecognizer];
    }
    return self;
}

- (void) constructTabViews {
    tabPageViews = [NSMutableArray arrayWithCapacity:self.pageCount];
    for (int i = 0; i < self.pageCount; i ++) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(tabView:pageViewAt:)]) {
            UIView* pageCellView = [self.delegate tabView:self pageViewAt:i];
            [tabPageViews addObject:pageCellView];
            [contentView addSubview:pageCellView];

        } else {
            UIView* view = [UIView new];
            [tabPageViews addObject:view];
            [contentView addSubview:view];
        }
    }

    tabsHeadBar = [self constructTabHeadBar];
    [self addSubview:tabsHeadBar];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    pageWidth = self.bounds.size.width;

    contentView.frame = CGRectMake(0, tabHeadHeight, pageWidth * self.pageCount, self.bounds.size.height - tabHeadHeight);
    contentViewCenterSnapshot = contentView.center;

    for (NSUInteger index = 0; index < self.pageCount; index ++) {

        UIView* tabView = [tabPageViews objectAtIndex:index];
        tabView.frame = CGRectMake(index * pageWidth, 0, pageWidth, contentView.bounds.size.height);
    }
    
    tabsHeadBar.frame = CGRectMake(0, 0, pageWidth, tabHeadHeight);
    xPaddingParamForAligningCenterOfAllHeadItems = (pageWidth - (self.pageCount * tabHeadWidth)) / 2;
    
    for(NSUInteger index = 0; index < self.pageCount; index ++) {
        UILabel* titleLabel = [tabHeadViews objectAtIndex:index];
        UIButton* tabButton = [tabHeadButtons objectAtIndex:index];
        titleLabel.frame = CGRectMake(xPaddingParamForAligningCenterOfAllHeadItems + (index * tabHeadWidth), 0, tabHeadWidth, tabHeadHeight);
        tabButton.frame = titleLabel.frame;
    }
    
    UIView* currentTabHeadLabelView = [tabHeadViews objectAtIndex:currentPageIndex];
    CGPoint currentTabHeadLabelViewCenter = currentTabHeadLabelView.center;
    CGFloat activePageIndicatorScrollerHeight = 3;
    
    activePageIndicatorScroller.frame = CGRectMake(0, tabHeadHeight - 7, tabHeadWidth, activePageIndicatorScrollerHeight);
    activePageIndicatorScroller.center = CGPointMake(currentTabHeadLabelViewCenter.x, activePageIndicatorScroller.center.y);
}

- (UIView*) constructTabHeadBar {
    UIView* pageControl = [[UIView alloc] initWithFrame:CGRectZero];
    [pageControl setBackgroundColor:[UIColor clearColor]];
    
    tabHeadViews = [NSMutableArray arrayWithCapacity:self.pageCount];
    tabHeadButtons = [NSMutableArray arrayWithCapacity:self.pageCount];
    
    for(NSUInteger index = 0; index < self.pageCount; index ++) {
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.tag = index;
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        
        if (currentPageIndex == index) {
             if(self.delegate &&
                [self.delegate respondsToSelector:@selector(hightlightTextColorOfTabHeadInTabView:)]) {
                 [titleLabel setTextColor:[self.delegate hightlightTextColorOfTabHeadInTabView:self]];
             } else {
                 [titleLabel setTextColor:[UIColor blueColor]];
             }
        } else {
            if(self.delegate &&
               [self.delegate respondsToSelector:@selector(inactiveTextColorOfTabHeadInTabView:)]) {
                [titleLabel setTextColor:[self.delegate inactiveTextColorOfTabHeadInTabView:self]];
            } else {
                [titleLabel setTextColor:[UIColor lightGrayColor]];
            }
        }
        
        [titleLabel setFont:[UIFont boldSystemFontOfSize:15]];
        [titleLabel setText:[self.delegate tabView:self titleAt:index]];

        [pageControl addSubview:titleLabel];
        [tabHeadViews addObject:titleLabel];
        
        UIButton* tabButton = [[UIButton alloc] initWithFrame:CGRectZero];
        tabButton.tag = index;
        tabButton.backgroundColor = [UIColor clearColor];
        [tabButton addTarget:self action:@selector(tapIn:) forControlEvents:UIControlEventTouchUpInside];
        [pageControl addSubview:tabButton];
        [tabHeadButtons addObject:tabButton];
    }
    
    activePageIndicatorScroller = [[UIView alloc] initWithFrame:CGRectZero];

    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderColorOfTabHeadInTabView:)]) {
        activePageIndicatorScroller.backgroundColor = [self.delegate sliderColorOfTabHeadInTabView:self];
    } else {
        activePageIndicatorScroller.backgroundColor = [UIColor orangeColor];
    }
    [pageControl addSubview:activePageIndicatorScroller];
    
    return pageControl;
}


- (void)tapIn:(UIButton*) tabHead {
    if (tabHead.tag == currentPageIndex) {
        return;
    }
    
    if (tabHead.tag < currentPageIndex) {
        [self scroll:pageWidth * (currentPageIndex - tabHead.tag)];
    } else if (tabHead.tag > currentPageIndex) {
        [self scroll:-(pageWidth * (tabHead.tag - currentPageIndex))];
    }
    [self scrollTitleAt:tabHead.tag];
}

- (void)panInContent:(UIPanGestureRecognizer*) recognizer {
    if (recognizer.state != UIGestureRecognizerStateEnded) {
        CGPoint point = [recognizer translationInView:contentView];
        CGPoint curViewCenterPoint = contentView.center;
        curViewCenterPoint.x = contentViewCenterSnapshot.x + point.x;
        
        //Add conditions
        //Can not move out of left and right boundaries.
        CGFloat leftCenterXLimittion = (pageWidth * self.pageCount) / 2.0f;
        CGFloat rightCenterXLimittion = pageWidth - leftCenterXLimittion;
        
        if (curViewCenterPoint.x <= leftCenterXLimittion && curViewCenterPoint.x >= rightCenterXLimittion) {
            contentView.center = curViewCenterPoint;
        }
    } else {
        contentViewCenterSnapshot.x = contentView.center.x;
        //Match page
        CGPoint contentOrigin = contentView.frame.origin;
        if (contentOrigin.x < 0) {
            CGFloat leftPages = floorf(fabs(contentOrigin.x) / pageWidth);

            CGFloat leftRemainingWidth = (fabs(contentOrigin.x) - (leftPages * pageWidth));
            CGFloat rightRemainingWidth = pageWidth - leftRemainingWidth;
            
            CGPoint velocity = [recognizer velocityInView:contentView];
            CGFloat x = velocity.x;
            if (fabs(x) > 800) {
                if (x > 0 && currentPageIndex > 0) {
                    [self scroll:leftRemainingWidth];
                    [self scrollTitleAt:currentPageIndex-- > 0 ? currentPageIndex : 0];
                } else if (currentPageIndex < (self.pageCount - 1)){
                    [self scroll:-(rightRemainingWidth)];
                    [self scrollTitleAt:currentPageIndex++ < self.pageCount ? currentPageIndex : self.pageCount - 1];
                }
                return;
            }
            
            if (rightRemainingWidth > (pageWidth / 2.0f) && rightRemainingWidth < pageWidth) {
                //Scroll to left
                [self scroll:leftRemainingWidth];
                [self scrollTitleAt:currentPageIndex];
                
            } else if (rightRemainingWidth < (pageWidth / 2.0f) && rightRemainingWidth > 0 ) {
                //Scroll to right
                [self scroll:-(rightRemainingWidth)];
                [self scrollTitleAt:currentPageIndex];
            }
        }
    }
}

- (void)scrollTitleAt:(NSUInteger) index {
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:0.5f initialSpringVelocity:0.5f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        
        CGPoint curactivePageIndicatorScrollerCenter = self->activePageIndicatorScroller.center;
        curactivePageIndicatorScrollerCenter.x = self->xPaddingParamForAligningCenterOfAllHeadItems + (index * tabHeadWidth + tabHeadWidth / 2) ;
        self->activePageIndicatorScroller.center = curactivePageIndicatorScrollerCenter;
        
    } completion:^(BOOL finished) {
        
        for(UILabel* titleLabel in self->tabHeadViews) {
            if (titleLabel.tag == index) {
                if(self.delegate &&
                   [self.delegate respondsToSelector:@selector(hightlightTextColorOfTabHeadInTabView:)]) {
                    [titleLabel setTextColor:[self.delegate hightlightTextColorOfTabHeadInTabView:self]];
                } else {
                    [titleLabel setTextColor:[UIColor blueColor]];
                }
            } else {
                if(self.delegate &&
                   [self.delegate respondsToSelector:@selector(inactiveTextColorOfTabHeadInTabView:)]) {
                    [titleLabel setTextColor:[self.delegate inactiveTextColorOfTabHeadInTabView:self]];
                } else {
                    [titleLabel setTextColor:[UIColor lightGrayColor]];
                }
            }
        }
    }];
}

- (void)scroll:(CGFloat) x {
    [UIView animateWithDuration:0.4f delay:0 usingSpringWithDamping:1.0f initialSpringVelocity:0.5f options:UIViewAnimationOptionAllowUserInteraction animations:^{
        
        CGPoint curViewCenterPoint = self->contentView.center;
        curViewCenterPoint.x = self->contentViewCenterSnapshot.x + x;
        self->contentView.center = curViewCenterPoint;
        
    } completion:^(BOOL finished) {
        
        self->contentViewCenterSnapshot.x = self->contentView.center.x;
        self->currentPageIndex = fabs(self->contentView.frame.origin.x) / self->pageWidth;
        if (self.delegate && [self.delegate respondsToSelector:@selector(tabView:willShowTabAtIndex:)]) {
            [self.delegate tabView:self willShowTabAtIndex:self->currentPageIndex];
        }
    }];
}
@end
