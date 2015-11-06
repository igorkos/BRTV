//
//  InfiniteHorizontalLayout.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/2/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit

let NotificationUpdateLayoutData = "NotificationUpdateLayoutData"

extension CGRect {
    public func intersectsY(rect: CGRect) -> Bool{
        if self.origin.y < rect.origin.y {
            if self.origin.y + self.size.height > rect.origin.y {
                return true
            }
        }
        return false
    }
    public func intersectsX(rect: CGRect) -> Bool{
        if self.origin.x < rect.origin.x {
            if self.origin.x + self.size.width > rect.origin.x {
                return true
            }
        }
        return false
    }
}

class InfiniteHorizontalLayout : UICollectionViewFlowLayout{
    
    var _collectionViewSize : CGSize
    var _collectionViewAttrib : [[UICollectionViewLayoutAttributes]] = []
    var _collectionViewTimeAttrib : [UICollectionViewLayoutAttributes] = []
    var _collectionViewHeaderAttrib : [UICollectionViewLayoutAttributes] = []
    var maxWith : CGFloat = 0
    var minWith : CGFloat = 0
    
    var bounds : CGRect
    required override init() {
        _collectionViewSize = CGSizeMake(0, 0)
         self.bounds = CGRectMake(0,0,0,0)
         super.init()
        self.itemSize = CGSizeMake(235,120)
        self.minimumInteritemSpacing = 2
        self.headerReferenceSize = CGSizeMake(120,120)
       
    }


    required init?(coder aDecoder: NSCoder) {
        _collectionViewSize = CGSizeMake(0, 0)
         self.bounds = CGRectMake(0,0,0,0)
        super.init(coder: aDecoder)
        self.itemSize = CGSizeMake(235,120)
        self.minimumInteritemSpacing = 2
        self.headerReferenceSize = CGSizeMake(120,120)
    }
  
    
    // Mark - Overriden
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds : CGRect) -> Bool
    {
        self.bounds = newBounds
       // Log.d("\(newBounds)")
        let triger = minWith - newBounds.size.width * 2
        if self.bounds.origin.x > triger {
            let nc = NSNotificationCenter.defaultCenter()
            nc.postNotificationName(NotificationUpdateLayoutData, object: nil)
        }
        return true;
    }
    
    private func calculateLayoutData() -> CGFloat {
        guard let sections = self.collectionView?.numberOfSections() else{
            return 0
        }
        if sections == 0 {
            return 0
        }
        if sections == 1 && self.collectionView?.numberOfItemsInSection(0) == 0 {
            return 0
        }
       
        let spacing = self.minimumInteritemSpacing
        
        if( _collectionViewTimeAttrib.count == 0 ){
            let count = self.collectionView?.numberOfItemsInSection(0)
            var width : CGFloat = 120
            for var i = 0 ; i < count ; i++ {
                let index = NSIndexPath(forItem: i, inSection: 0)
                let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: index)
                let size = sizeForItemAtIndexPath(index)
                attr.frame = CGRectMake(width+spacing, 0, size.width, size.height)
                _collectionViewTimeAttrib.append(attr)
                width += size.width + spacing
            }
        }
        
        _collectionViewAttrib = []
       
        var widthMax : CGFloat = 0
        var widthMin : CGFloat = CGFloat.max

        for var i = 1 ; i < sections ; i++ {
            let items = self.collectionView?.numberOfItemsInSection(i)
            //Log.d("\(sections) = \(i) - \(items!)")
            var width : CGFloat = 120
            let header = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: NSIndexPath(forItem: 0, inSection: i))
            header.frame = CGRectMake(0,i == 0 ? 0:CGFloat(i)*(120 + spacing) - 70,120,120)
            _collectionViewHeaderAttrib.append(header)
             _collectionViewAttrib.append([])
            for var ii = 0 ; ii < items ; ii++ {
                let index = NSIndexPath(forItem: ii, inSection: i)
                let attr = UICollectionViewLayoutAttributes(forCellWithIndexPath: index)
                let size = sizeForItemAtIndexPath(index)
                attr.frame = CGRectMake(width+spacing, i == 0 ? 0:CGFloat(i)*(size.height + spacing) - 70, size.width, size.height)
                _collectionViewAttrib[i-1].append(attr)
                width += size.width + spacing
            }
            widthMax = max(width, widthMax)
            widthMin = min(width,widthMin)
        }
        minWith = widthMin
        maxWith = widthMax
        Log.d("\(minWith) - \(maxWith)")
        _collectionViewSize = CGSizeMake(widthMax, CGFloat(sections) * self.itemSize.height)
        return widthMax
    }
    
    override func prepareLayout()
    {
        if maxWith == 0 {
            calculateLayoutData()
        }
        self.scrollDirection = .Vertical
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, self.minimumLineSpacing);
        self.collectionView!.showsHorizontalScrollIndicator = false
        self.collectionView!.showsVerticalScrollIndicator = false
        
      //  Log.d("\(_collectionViewSize)")
    }
    
    override func collectionViewContentSize() -> CGSize
    {
 //       Log.d("\(_collectionViewSize)")
        return _collectionViewSize;
    }
    
    
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [UICollectionViewLayoutAttributes]?
    {
      //  Log.d("Rect \(rect)")
        if rect.origin.x < 0 {
            bounds.origin.x = 0
        }
        var result = Array<UICollectionViewLayoutAttributes>()
        for header in _collectionViewHeaderAttrib {
            let frame  = header.frame
            if rect.intersectsY(frame) {
                let newHeader = header
                newHeader.frame = CGRectMake(bounds.origin.x, header.frame.origin.y, header.frame.size.width, header.frame.size.height)
                //Log.d("Header \(newHeader.frame)")
                result.append(newHeader)
            }
        }
        for timeMark in _collectionViewTimeAttrib {
            let frame  = timeMark.frame
            if rect.intersectsX(frame) {
                let newMark = timeMark
                newMark.frame = CGRectMake(timeMark.frame.origin.x, bounds.origin.y, timeMark.frame.size.width, timeMark.frame.size.height)
                result.append(newMark)
            }
        }
        
        for section in _collectionViewAttrib {
            for attr in section {
                let frame  = attr.frame
                if rect.intersects(frame) {
                   result.append(attr)
                }
            }
        }
        return result;
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath:NSIndexPath) -> UICollectionViewLayoutAttributes
    {
        if indexPath.section == 0 {
            return _collectionViewTimeAttrib[indexPath.row]
        }
        return _collectionViewAttrib[indexPath.section-1][indexPath.row]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?{
        Log.d("\(elementKind)  \(indexPath)")
        return _collectionViewHeaderAttrib[indexPath.section]
    }
    
    override func layoutAttributesForDecorationViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes?{
        Log.d("\(elementKind)  \(indexPath)")
        return _collectionViewHeaderAttrib[indexPath.section]
    }

    //MARK - Private
    private func sizeForItemAtIndexPath(index:NSIndexPath) -> CGSize {
        guard  let delegate = self.collectionView?.delegate else{
            return self.itemSize
        }
        
        if delegate.respondsToSelector("collectionView:layout:sizeForItemAtIndexPath:") {
            let del = delegate as! UICollectionViewDelegateFlowLayout
            let size = del.collectionView!(self.collectionView!, layout:self, sizeForItemAtIndexPath:index)
            return size
        }
        return self.itemSize;
    }
}