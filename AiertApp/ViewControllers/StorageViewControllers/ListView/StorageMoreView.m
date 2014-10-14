


#import "StorageMoreView.h"

#define kStorageMore_Tag                                   2000001
#define kStorageMore_MaxCount                              4

#define kStorageMore_OrgX                                  5.0
#define kStorageMore_OrgY                                  5.0
#define kStorageCell_Image_Pad                             10.0
#define kStorageCell_Image_Height                          60.0


@interface StorageMoreView ()

- (void)iniDragButtonData;

-(void)removeAllView;

@end

@implementation StorageMoreView
@synthesize dataArr = dataArr_;
@synthesize storageMoreViewDelegate = storageMoreViewDelegate_;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _bChoiceAllButton = NO;
        
        
        UIScrollViewEx *sView = [[UIScrollViewEx alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - 49.0 - 44.0)];
        [sView setBackgroundColor:[UIColor clearColor]];
       
        self.scrollViewEx = sView;
        sView.uiScrollViewExDelegate = self;
        sView.showsVerticalScrollIndicator = YES;
        [self addSubview:sView];
        
    }
    return self;
}


-(void)removeAllView {
    if (_dragButtonDataArr) {
        for (int i = 0; i< [_dragButtonDataArr count]; i++) {
            DragButton *button = (DragButton*)[_dragButtonDataArr objectAtIndex:i];
            [button removeFromSuperview];
        }
    }
}

- (void)iniDragButtonData {

    float x = kStorageMore_OrgX;
    float y = kStorageMore_OrgY;
    int nMaxCount = kStorageMore_MaxCount;
    int nRows = [dataArr_ count]/nMaxCount;
    if (0 != ([dataArr_ count] % nMaxCount)) {
        nRows += 1;
    }
    
    _scrollViewEx.contentSize = CGSizeMake(_scrollViewEx.frame.size.width ,nRows * (kStorageCell_Image_Height + kStorageCell_Image_Pad));
    
    _dragButtonDataArr = [[NSMutableArray alloc] initWithCapacity:[dataArr_ count]];
    for (int nRow = 0; nRow < nRows; nRow++) {
        for (int nCol = 0 ; nCol < nMaxCount; nCol++) {
            int nIndex = nRow*nMaxCount +nCol;
            if (nIndex < [dataArr_ count]) {
                //
                float fbuttonWidth = (self.bounds.size.width - 2*kStorageMore_OrgX - 3*kStorageCell_Image_Pad)/4 ;
                DragButton *button = [[DragButton alloc] initWithFrameWithType:CGRectMake(x, y, fbuttonWidth, kStorageCell_Image_Height) Type:0];
                
                NSString *imagePath = [Utilities documentsPathWithFolder:[[AppData lastLoginUser] userId] fileName:[NSString stringWithFormat:@"%@_small.png",[dataArr_ objectAtIndex:nIndex]]];
                
                [button setDragButtonBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]] forState:UIControlStateNormal];
                [button setDragButtonBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfFile:imagePath]] forState:UIControlStateHighlighted];
                
                button.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleRightMargin;
                
                button.dragButtonDelegate = self;
                button.tag = kStorageMore_Tag + nIndex;
                [_dragButtonDataArr addObject:button];
                [_scrollViewEx addSubview:button];
                
                x = (nCol + 1) * (fbuttonWidth + kStorageCell_Image_Pad) + kStorageMore_OrgX;
            }
        }
        y = (nRow + 1) * (kStorageCell_Image_Height + kStorageCell_Image_Pad) - kStorageMore_OrgY *nRow;
        x = kStorageMore_OrgX;
    }
}

- (void)showAllDelButtonInStorageMoreView:(BOOL)bShow {
    
    for (int i = 0; i< [_dragButtonDataArr count]; i++) {
        DragButton *button = (DragButton*)[_dragButtonDataArr objectAtIndex:i];
        [button showDelButton:bShow];
    }
}

- (void)initData {
    
    [self iniDragButtonData];
    
    bShowAllDelButton = NO;
    [self showAllDelButtonInStorageMoreView:bShowAllDelButton];
}

- (void)reloadData {
    
    [self removeAllView];
    
    [self iniDragButtonData];
}

- (void)didChoiceAllButtonInStorageMoreView:(BOOL)bChoice {
    
    _bChoiceAllButton = bChoice;
    for (int i = 0; i< [_dragButtonDataArr count]; i++) {
        DragButton *button = (DragButton*)[_dragButtonDataArr objectAtIndex:i];
        [button didChoiceAllButton:bChoice];
    }
}

#pragma Mark DragButtonDelegate
-(void)didLongPressDrag:(id)aData {
    bShowAllDelButton = YES;
    [self showAllDelButtonInStorageMoreView:bShowAllDelButton];
    
    /*if(storageMoreViewDelegate_ && [(id)storageMoreViewDelegate_ respondsToSelector:@selector(didShowAllDelButtonInStorageMoreView:)])
        [storageMoreViewDelegate_ didShowAllDelButtonInStorageMoreView:bShowAllDelButton];*/
}

- (void)delButtonAtIndexInDragButton:(NSInteger)aIndex {
    if(storageMoreViewDelegate_ && [(id)storageMoreViewDelegate_ respondsToSelector:@selector(delButtonAtIndexInStorageMoreView:)])
        [storageMoreViewDelegate_ delButtonAtIndexInStorageMoreView:aIndex - kStorageMore_Tag];
}

- (void)doubleClickAtIndexInDragButton:(NSInteger)aIndex {
    
    if(storageMoreViewDelegate_ && [(id)storageMoreViewDelegate_ respondsToSelector:@selector(doubleClickAtIndexInStorageMoreView:)])
        [storageMoreViewDelegate_ doubleClickAtIndexInStorageMoreView:aIndex - kStorageMore_Tag];
}

- (void)singleClickAtIndexInDragButton:(NSInteger)aIndex {
    for (int i = 0; i< [_dragButtonDataArr count]; i++) {
        DragButton *button = (DragButton*)[_dragButtonDataArr objectAtIndex:i];
        if (button.tag == aIndex) {
            [button didSelectImageView:YES];
        }
        else {
            [button didSelectImageView:NO];
        }
    }
    
    if(storageMoreViewDelegate_ && [(id)storageMoreViewDelegate_ respondsToSelector:@selector(singleClickAtIndexInStorageMoreView:)])
        [storageMoreViewDelegate_ singleClickAtIndexInStorageMoreView:aIndex - kStorageMore_Tag];
}


#pragma Mark UIScrollViewExDelegate
- (void)didTouchesEndedAtUIScrollViewEx:(BOOL)touched {
    if (bShowAllDelButton) {
        bShowAllDelButton = NO;
        [self showAllDelButtonInStorageMoreView:bShowAllDelButton];
        
        /* if(storageMoreViewDelegate_ && [(id)storageMoreViewDelegate_ respondsToSelector:@selector(didShowAllDelButtonInStorageMoreView:)])
         [storageMoreViewDelegate_ didShowAllDelButtonInStorageMoreView:bShowAllDelButton];*/
    }
    /*if (_bChoiceAllButton) {
        _bChoiceAllButton = NO;
        for (int i = 0; i< [_dragButtonDataArr count]; i++) {
            DragButton *button = (DragButton*)[_dragButtonDataArr objectAtIndex:i];
            [button didChoiceAllButton:NO];
        }
        if(storageMoreViewDelegate_ && [(id)storageMoreViewDelegate_ respondsToSelector:@selector(didShowAllDelButtonInStorageMoreView:)])
         [storageMoreViewDelegate_ didShowAllDelButtonInStorageMoreView:bShowAllDelButton];
    }
     */
}

@end
