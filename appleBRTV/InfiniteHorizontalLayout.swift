//
//  InfiniteHorizontalLayout.swift
//  appleBRTV
//
//  Created by Igor Kosulin on 11/2/15.
//  Copyright © 2015 Aleksandr Kelbas. All rights reserved.
//

import UIKit
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


let NotificationUpdateLayoutData = "NotificationUpdateLayoutData"

extension CGRect {
    public func intersectsY(_ rect: CGRect) -> Bool{
        if self.origin.y < rect.origin.y {
            if self.origin.y + self.size.height > rect.origin.y {
                return true
            }
        }
        return false
    }
    public func intersectsX(_ rect: CGRect) -> Bool{
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
        _collectionViewSize = CGSize(width: 0, height: 0)
         self.bounds = CGRect(x: 0,y: 0,width: 0,height: 0)
         super.init()
        self.itemSize = CGSize(width: 235,height: 120)
        self.minimumInteritemSpacing = 2
        self.headerReferenceSize = CGSize(width: 120,height: 120)
       
    }


    required init?(coder aDecoder: NSCoder) {
        _collectionViewSize = CGSize(width: 0, height: 0)
         self.bounds = CGRect(x: 0,y: 0,width: 0,height: 0)
        super.init(coder: aDecoder)
        self.itemSize = CGSize(width: 235,height: 120)
        self.minimumInteritemSpacing = 2
        self.headerReferenceSize = CGSize(width: 120,height: 120)
    }
  
    
    // Mark - Overriden
    
    override func shouldInvalidateLayout(forBoundsChange newBounds : CGRect) -> Bool
    {
        self.bounds = newBounds
       // Log.d("\(newBounds)")
        let triger = minWith - newBounds.size.width * 2
        if self.bounds.origin.x > triger {
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name(rawValue: NotificationUpdateLayoutData), object: nil)
        }
        return true;
    }
    
    fileprivate func calculateLayoutData() -> CGFloat {
        guard let sections = self.collectionView?.numberOfSections else{
            return 0
        }
        if sections == 0 {
            return 0
        }
        if sections == 1 && self.collectionView?.numberOfItems(inSection: 0) == 0 {
            return 0
        }
       
        let spacing = self.minimumInteritemSpacing
        
        if( _collectionViewTimeAttrib.count == 0 ){
            let count : Int! = self.collectionView?.numberOfItems(inSection: 0)
            var width : CGFloat = 120
            for i in 0...count  {
                let index = IndexPath(item: i, section: 0)
                let attr = UICollectionViewLayoutAttributes(forCellWith: index)
                let size = sizeForItemAtIndexPath(index)
                attr.frame = CGRect(x: width+spacing, y: 0, width: size.width, height: size.height)
                _collectionViewTimeAttrib.append(attr)
                width += size.width + spacing
            }
        }
        
        _collectionViewAttrib = []
       
        var widthMax : CGFloat = 0
        var widthMin : CGFloat = CGFloat.greatestFiniteMagnitude

        for i in 1  ..< sections {
            let items : Int! = self.collectionView?.numberOfItems(inSection: i)
            //Log.d("\(sections) = \(i) - \(items!)")
            var width : CGFloat = 120
            let header = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, with: IndexPath(item: 0, section: i))
            header.frame = CGRect(x: 0,y: i == 0 ? 0:CGFloat(i)*(120 + spacing) - 70,width: 120,height: 120)
            _collectionViewHeaderAttrib.append(header)
             _collectionViewAttrib.append([])
            for ii in 0...items  {
                let index = IndexPath(item: ii, section: i)
                let attr = UICollectionViewLayoutAttributes(forCellWith: index)
                let size = sizeForItemAtIndexPath(index)
                attr.frame = CGRect(x: width+spacing, y: i == 0 ? 0:CGFloat(i)*(size.height + spacing) - 70, width: size.width, height: size.height)
                _collectionViewAttrib[i-1].append(attr)
                width += size.width + spacing
            }
            widthMax = max(width, widthMax)
            widthMin = min(width,widthMin)
        }
        minWith = widthMin
        maxWith = widthMax
        Log.d("\(minWith) - \(maxWith)")
        _collectionViewSize = CGSize(width: widthMax, height: CGFloat(sections) * self.itemSize.height)
        return widthMax
    }
    
    override func prepare()
    {
        if maxWith == 0 {
            calculateLayoutData()
        }
        self.scrollDirection = .vertical
        self.sectionInset = UIEdgeInsetsMake(0, 0, 0, self.minimumLineSpacing);
        self.collectionView!.showsHorizontalScrollIndicator = false
        self.collectionView!.showsVerticalScrollIndicator = false
        
      //  Log.d("\(_collectionViewSize)")
    }
    
    override var collectionViewContentSize : CGSize
    {
 //       Log.d("\(_collectionViewSize)")
        return _collectionViewSize;
    }
    
    
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]?
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
                newHeader.frame = CGRect(x: bounds.origin.x, y: header.frame.origin.y, width: header.frame.size.width, height: header.frame.size.height)
                //Log.d("Header \(newHeader.frame)")
                result.append(newHeader)
            }
        }
        for timeMark in _collectionViewTimeAttrib {
            let frame  = timeMark.frame
            if rect.intersectsX(frame) {
                let newMark = timeMark
                newMark.frame = CGRect(x: timeMark.frame.origin.x, y: bounds.origin.y, width: timeMark.frame.size.width, height: timeMark.frame.size.height)
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
    
    override func layoutAttributesForItem(at indexPath:IndexPath) -> UICollectionViewLayoutAttributes
    {
        if indexPath.section == 0 {
            return _collectionViewTimeAttrib[indexPath.row]
        }
        return _collectionViewAttrib[indexPath.section-1][indexPath.row]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        Log.d("\(elementKind)  \(indexPath)")
        return _collectionViewHeaderAttrib[indexPath.section]
    }
    
    override func layoutAttributesForDecorationView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes?{
        Log.d("\(elementKind)  \(indexPath)")
        return _collectionViewHeaderAttrib[indexPath.section]
    }

    //MARK - Private
    fileprivate func sizeForItemAtIndexPath(_ index:IndexPath) -> CGSize {
        guard  let delegate = self.collectionView?.delegate else{
            return self.itemSize
        }
        
        if delegate.responds(to: #selector(UICollectionViewDelegateFlowLayout.collectionView(_:layout:sizeForItemAt:))) {
            let del = delegate as! UICollectionViewDelegateFlowLayout
            let size = del.collectionView!(self.collectionView!, layout:self, sizeForItemAt:index)
            return size
        }
        return self.itemSize;
    }
}
