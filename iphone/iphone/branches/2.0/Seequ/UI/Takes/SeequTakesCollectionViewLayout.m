//
//  UICollectionViewWaterfallLayout.m
//
//  Created by Nelson on 12/11/19.
//  Copyright (c) 2012 Nelson Tai. All rights reserved.
//

#import "SeequTakesCollectionViewLayout.h"
#import "idoubs2AppDelegate.h"
#import "common.h"
#define SHIFT_BETWEEN_COLUMNS 90.5
#define NAVIGATION_BAR_HEIGHT 44;

NSString *const SeequCollectionElementKindSectionHeader = @"SeequCollectionElementKindSectionHeader";
NSString *const SeequCollectionElementKindSectionFooter = @"SeequCollectionElementKindSectionFooter";

@interface SeequTakesCollectionViewLayout ()
/// The delegate will point to collection view's delegate automatically.
@property (nonatomic, weak) id <SeequCollectionViewDelegateWaterfallLayout> delegate;
/// Array to store height for each column
@property (nonatomic, strong) NSMutableArray *columnHeights;
/// Array of arrays. Each array stores item attributes for each section
@property (nonatomic, strong) NSMutableArray *sectionItemAttributes;
/// Array to store attributes for all items includes headers, cells, and footers
@property (nonatomic, strong) NSMutableArray *allItemAttributes;
/// Dictionary to store section headers' attribute
@property (nonatomic, strong) NSMutableDictionary *headersAttribute;
/// Dictionary to store section footers' attribute
@property (nonatomic, strong) NSMutableDictionary *footersAttribute;
/// Array to store union rectangles
@property (nonatomic, strong) NSMutableArray *unionRects;
@end

@implementation SeequTakesCollectionViewLayout

/// How many items to be union into a single rectangle
const NSInteger unionSize = 20;

#pragma mark - Public Accessors
- (void)setColumnCount:(NSInteger)columnCount {
  if (_columnCount != columnCount) {
    _columnCount = columnCount;
    [self invalidateLayout];
  }
}

- (void)setMinimumColumnSpacing:(CGFloat)minimumColumnSpacing {
  if (_minimumColumnSpacing != minimumColumnSpacing) {
    _minimumColumnSpacing = minimumColumnSpacing;
    [self invalidateLayout];
  }
}

- (void)setMinimumInteritemSpacing:(CGFloat)minimumInteritemSpacing {
  if (_minimumInteritemSpacing != minimumInteritemSpacing) {
    _minimumInteritemSpacing = minimumInteritemSpacing;
    [self invalidateLayout];
  }
}

- (void)setHeaderHeight:(CGFloat)headerHeight {
  if (_headerHeight != headerHeight) {
    _headerHeight = headerHeight;
    [self invalidateLayout];
  }
}

- (void)setFooterHeight:(CGFloat)footerHeight {
  if (_footerHeight != footerHeight) {
    _footerHeight = footerHeight;
    [self invalidateLayout];
  }
}

- (void)setSectionInset:(UIEdgeInsets)sectionInset {
  if (!UIEdgeInsetsEqualToEdgeInsets(_sectionInset, sectionInset)) {
    _sectionInset = sectionInset;
    [self invalidateLayout];
  }
}

#pragma mark - Private Accessors
- (NSMutableDictionary *)headersAttribute {
  if (!_headersAttribute) {
    _headersAttribute = [NSMutableDictionary dictionary];
  }
  return _headersAttribute;
}

- (NSMutableDictionary *)footersAttribute {
  if (!_footersAttribute) {
    _footersAttribute = [NSMutableDictionary dictionary];
  }
  return _footersAttribute;
}

- (NSMutableArray *)unionRects {
  if (!_unionRects) {
    _unionRects = [NSMutableArray array];
  }
  return _unionRects;
}

- (NSMutableArray *)columnHeights {
  if (!_columnHeights) {
    _columnHeights = [NSMutableArray array];
  }
  return _columnHeights;
}

- (NSMutableArray *)allItemAttributes {
  if (!_allItemAttributes) {
    _allItemAttributes = [NSMutableArray array];
  }
  return _allItemAttributes;
}

- (NSMutableArray *)sectionItemAttributes {
  if (!_sectionItemAttributes) {
    _sectionItemAttributes = [NSMutableArray array];
  }
  return _sectionItemAttributes;
}

#pragma mark - Init
- (void)commonInit {
  _columnCount = 2;
  _minimumColumnSpacing = 10;
  _minimumInteritemSpacing = 10;
  _headerHeight = 0;
  _footerHeight = 0;
  _sectionInset = UIEdgeInsetsZero;
}

- (id)init {
  if (self = [super init]) {
    [self commonInit];
  }
  return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
  if (self = [super initWithCoder:aDecoder]) {
    [self commonInit];
  }
  return self;
}

-(CGFloat)itemWidth{
    CGFloat width = self.collectionView.frame.size.width - self.sectionInset.left - self.sectionInset.right;
    return floorf((width - (self.columnCount - 1) * self.minimumColumnSpacing) / self.columnCount);
}

#pragma mark - Methods to Override
- (void)prepareLayout {
  [super prepareLayout];

  NSInteger numberOfSections = [self.collectionView numberOfSections];
  if (numberOfSections == 0) {
    return;
  }

  self.delegate = (id <SeequCollectionViewDelegateWaterfallLayout> )self.collectionView.delegate;
  NSAssert([self.delegate conformsToProtocol:@protocol(SeequCollectionViewDelegateWaterfallLayout)], @"UICollectionView's delegate should conform to SeequCollectionViewDelegateWaterfallLayout protocol");
  NSAssert(self.columnCount > 0, @"UICollectionViewWaterfallLayout's columnCount should be greater than 0");

  // Initialize variables
  NSInteger idx = 0;
  

  [self.headersAttribute removeAllObjects];
  [self.footersAttribute removeAllObjects];
  [self.unionRects removeAllObjects];
  [self.columnHeights removeAllObjects];
  [self.allItemAttributes removeAllObjects];
  [self.sectionItemAttributes removeAllObjects];

  for (idx = 0; idx < self.columnCount; idx++) {
    [self.columnHeights addObject:@(0)];
  }

  // Create attributes
  CGFloat top = 0;
  CGFloat itemWidth = [self itemWidth];
  UICollectionViewLayoutAttributes *attributes;

  for (NSInteger section = 0; section < numberOfSections; ++section) {
    /*
     * 1. Section header
     */
    CGFloat headerHeight;
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForHeaderInSection:)]) {
      headerHeight = [self.delegate collectionView:self.collectionView layout:self heightForHeaderInSection:section];
    } else {
      headerHeight = self.headerHeight;
    }

    if (headerHeight > 0) {
      attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SeequCollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
      attributes.frame = CGRectMake(0, top, self.collectionView.frame.size.width, headerHeight);

      self.headersAttribute[@(section)] = attributes;
      [self.allItemAttributes addObject:attributes];

      top = CGRectGetMaxY(attributes.frame);
    }

    top += self.sectionInset.top;
    for (idx = 0; idx < self.columnCount; idx++) {
      self.columnHeights[idx] = @(top);
    }

    /*
     * 2. Section items
     */
    NSInteger itemCount = [self.collectionView numberOfItemsInSection:section];
    NSMutableArray *itemAttributes = [NSMutableArray arrayWithCapacity:itemCount];

    // Item will be put into shortest column.
    for (idx = 0; idx < itemCount; idx++) {
      NSIndexPath *indexPath = [NSIndexPath indexPathForItem:idx inSection:section];
      NSUInteger columnIndex = [self shortestColumnIndex];
      CGFloat xOffset = self.sectionInset.left + (itemWidth + self.minimumColumnSpacing) * columnIndex;
      CGFloat yOffset = [self.columnHeights[columnIndex] floatValue];
      CGSize itemSize = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
      CGFloat itemHeight = 0;
      if (itemSize.height > 0 && itemSize.width > 0) {
        itemHeight = floorf(itemSize.height * itemWidth / itemSize.width);
      }

      attributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
      attributes.frame = CGRectMake(xOffset, yOffset, itemWidth, itemHeight);
      [itemAttributes addObject:attributes];
      [self.allItemAttributes addObject:attributes];
      self.columnHeights[columnIndex] = @(CGRectGetMaxY(attributes.frame) + self.minimumInteritemSpacing);
    }

    [self.sectionItemAttributes addObject:itemAttributes];

    /*
     * Section footer
     */
    CGFloat footerHeight;
    NSUInteger columnIndex = [self longestColumnIndex];
    top = [self.columnHeights[columnIndex] floatValue] - self.minimumInteritemSpacing + self.sectionInset.bottom;

    if ([self.delegate respondsToSelector:@selector(collectionView:layout:heightForFooterInSection:)]) {
      footerHeight = [self.delegate collectionView:self.collectionView layout:self heightForFooterInSection:section];
    } else {
      footerHeight = self.footerHeight;
    }

    if (footerHeight > 0) {
      attributes = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:SeequCollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
      attributes.frame = CGRectMake(0, top, self.collectionView.frame.size.width, footerHeight);

      self.footersAttribute[@(section)] = attributes;
      [self.allItemAttributes addObject:attributes];

      top = CGRectGetMaxY(attributes.frame);
    }

    for (idx = 0; idx < self.columnCount; idx++) {
      self.columnHeights[idx] = @(top);
    }
  } // end of for (NSInteger section = 0; section < numberOfSections; ++section)

  // Build union rects
  idx = 0;
  NSInteger itemCounts = [self.allItemAttributes count];
  while (idx < itemCounts) {
    CGRect rect1 = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
    idx = MIN(idx + unionSize, itemCounts) - 1;
    CGRect rect2 = ((UICollectionViewLayoutAttributes *)self.allItemAttributes[idx]).frame;
    [self.unionRects addObject:[NSValue valueWithCGRect:CGRectUnion(rect1, rect2)]];
    idx++;
  }
}

- (CGSize)collectionViewContentSize {
  NSInteger numberOfSections = [self.collectionView numberOfSections];
  if (numberOfSections == 0) {
    return CGSizeZero;
  }

  CGSize contentSize = self.collectionView.bounds.size;
//    if ([[UIDevice currentDevice].model rangeOfString:@"iPad"].location != NSNotFound) {
//        
//        
//        contentSize.height = [self.columnHeights[0] floatValue] + [idoubs2AppDelegate sharedInstance].tabBarController.tabBar.frame.size.height + NAVIGATION_BAR_HEIGHT
//        
//        
//    }else{
        if(_allItemAttributes.count % 2 == 0){
            
            contentSize.height = [self.columnHeights[0] floatValue] + [idoubs2AppDelegate sharedInstance].tabBarController.tabBar.frame.size.height + NAVIGATION_BAR_HEIGHT;
            
        }else{
            
            contentSize.height = [self.columnHeights[0] floatValue];
            
        }
        
        
//    }
    return contentSize;
}


- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)path {
  if (path.section >= [self.sectionItemAttributes count]) {
    return nil;
  }
  if (path.item >= [self.sectionItemAttributes[path.section] count]) {
    return nil;
  }
  return (self.sectionItemAttributes[path.section])[path.item];
}

- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
  UICollectionViewLayoutAttributes *attribute = nil;
  if ([kind isEqualToString:SeequCollectionElementKindSectionHeader]) {
    attribute = self.headersAttribute[@(indexPath.section)];
  } else if ([kind isEqualToString:SeequCollectionElementKindSectionFooter]) {
    attribute = self.footersAttribute[@(indexPath.section)];
  }
  return attribute;
}

- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
  NSInteger i;
  NSInteger begin = 0, end = self.unionRects.count;
  NSMutableArray *attrs = [NSMutableArray array];

  for (i = 0; i < self.unionRects.count; i++) {
    if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
        
       begin = i * unionSize;
        
      break;
    }
  }
  for (i = self.unionRects.count - 1; i >= 0; i--) {
    if (CGRectIntersectsRect(rect, [self.unionRects[i] CGRectValue])) {
      end = MIN((i + 1) * unionSize, self.allItemAttributes.count);
      break;
    }
  }
  for (i = begin; i < end; i++) {
    UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
    if (CGRectIntersectsRect(rect, attr.frame)) {
        
                  [attrs addObject:attr];
    
        }
  }
    
    UICollectionViewLayoutAttributes *previous;
    for (i = 1; i < self.allItemAttributes.count; i++) {
        
        UICollectionViewLayoutAttributes *attr = self.allItemAttributes[i];
        if( i % 2 == 0){
            if(attr.frame.origin.y == previous.frame.origin.y){
                attr.frame = CGRectMake(attr.frame.origin.x, attr.frame.origin.y + SHIFT_BETWEEN_COLUMNS, attr.frame.size.width , attr.frame.size.height);
            }
            
        }else{
           previous = attr;
            
        }
        
    }

    
  return [NSArray arrayWithArray:attrs];
}


//- (NSArray *) layoutAttributesForElementsInRect:(CGRect)rect {
//    NSArray *answer = [[super layoutAttributesForElementsInRect:rect] mutableCopy];
//    
//    for(int i = 1; i < [answer count]; ++i) {
//        UICollectionViewLayoutAttributes *currentLayoutAttributes = answer[i];
//        UICollectionViewLayoutAttributes *prevLayoutAttributes = answer[i - 1];
//        NSInteger maximumSpacing = 4;
//        NSInteger origin = CGRectGetMaxX(prevLayoutAttributes.frame);
//        if(origin + maximumSpacing + currentLayoutAttributes.frame.size.width < self.collectionViewContentSize.width) {
//            CGRect frame = currentLayoutAttributes.frame;
//            frame.origin.x = origin + maximumSpacing;
//            currentLayoutAttributes.frame = frame;
//        }
//    }
//    return answer;
//}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
  CGRect oldBounds = self.collectionView.bounds;
  if (CGRectGetWidth(newBounds) != CGRectGetWidth(oldBounds)) {
    return YES;
  }
  return NO;
}

#pragma mark - Private Methods

/**
 *  Find the shortest column.
 *
 *  @return index for the shortest column
 */
- (NSUInteger)shortestColumnIndex {
  __block NSUInteger index = 0;
  __block CGFloat shortestHeight = MAXFLOAT;

  [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    CGFloat height = [obj floatValue];
    if (height < shortestHeight) {
      shortestHeight = height;
      index = idx;
    }
  }];

  return index;
}

/**
 *  Find the longest column.
 *
 *  @return index for the longest column
 */
- (NSUInteger)longestColumnIndex {
  __block NSUInteger index = 0;
  __block CGFloat longestHeight = 0;

  [self.columnHeights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    CGFloat height = [obj floatValue];
    if (height > longestHeight) {
      longestHeight = height;
      index = idx;
    }
  }];

  return index;
}

@end
