//
//  UIImageExtras.swift
//  LogicBLOX
//
//  Created by Michael Griebling on 28Jan2016.
//  Copyright © 2016 Solinst Canada. All rights reserved.
//

import UIKit

extension UIImage {
    
    public func imageByBestFitForSize(_ targetSize: CGSize) -> UIImage? {
        let aspectRatio = size.width / size.height
        
        let targetHeight = targetSize.height
        let scaledWidth = targetSize.height * aspectRatio
        let targetWidth = (targetSize.width < scaledWidth) ? targetSize.width : scaledWidth
        
        return imageByScalingAndCroppingForSize(CGSize(width: targetWidth, height: targetHeight))
    }
    
    public func imageByScalingAndCroppingForSize(_ targetSize: CGSize) -> UIImage? {
        let sourceImage = self
        var newImage : UIImage?
        let imageSize = sourceImage.size
        let width = imageSize.width
        let height = imageSize.height
        let targetWidth = targetSize.width
        let targetHeight = targetSize.height
        var scaleFactor : CGFloat = 0.0
        var scaledWidth = targetWidth
        var scaledHeight = targetHeight
        var thumbnailPoint = CGPoint(x: 0.0,y: 0.0)
        
        if imageSize != targetSize {
            let widthFactor = targetWidth / width
            let heightFactor = targetHeight / height
            
            if widthFactor > heightFactor {
                scaleFactor = widthFactor // scale to fit height
            } else {
                scaleFactor = heightFactor // scale to fit width
            }
            scaledWidth  = ceil(width * scaleFactor)
            scaledHeight = ceil(height * scaleFactor)
            
            // center the image
            if widthFactor > heightFactor {
                thumbnailPoint.y = (targetHeight - scaledHeight) * 0.5
            } else {
                if widthFactor < heightFactor {
                    thumbnailPoint.x = (targetWidth - scaledWidth) * 0.5
                }
            }
        }
        
        UIGraphicsBeginImageContext(targetSize); // this will crop
        
        var thumbnailRect = CGRect.zero
        thumbnailRect.origin = thumbnailPoint
        thumbnailRect.size.width  = scaledWidth
        thumbnailRect.size.height = scaledHeight
        
        sourceImage.draw(in: thumbnailRect)
        
        newImage = UIGraphicsGetImageFromCurrentImageContext()
        if newImage == nil {
            NSLog("could not scale image")
        }
        
        //pop the context to get back to the default
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
