//
//  CanvasView.swift
//  LogicBLOX
//
//  Created by Mike Griebling on 2 Sep 2017.
//  Copyright © 2017 Computer Inspirations. All rights reserved.
//

import UIKit

class LBZoomingCanvasView: UIScrollView {

    var scaleFactor : CGFloat = 1 {
        didSet {
            self.zoomScale = scaleFactor
        }
    }

}
