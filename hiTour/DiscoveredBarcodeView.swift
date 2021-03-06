//
//  DiscoveredBarcodeView.swift
//  hiTour
//
//  Created by Charlie Baker on 19/02/2016.
//  Copyright © 2016 stranders.kcl.ac.uk. All rights reserved.
//

import UIKit


/// Create a Red Rectangle view to be displayed around the QR code discovered by the camera.
class DiscoveredBardCodeView : UIView {
    
    /// Reference to the Rectangle Shape Layer.
    var borderLayer : CAShapeLayer?
    
    /// Reference array to the corner points.
    var corners : [CGPoint]?
    
    /// Construct view and call function to set up the rectangles properties.
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setMyView()
    }
    
    /// Required initialise function.
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    /// Draw the rectangle shapes from the corner points passed in as an argument.
    func drawBorder(points: [CGPoint]) {
        self.corners = points
        let path = UIBezierPath()
        
        path.moveToPoint(points.first!)
        for i in 1 ..< points.count {
            path.addLineToPoint(points[i])
        }
        path.addLineToPoint(points.first!)
        borderLayer?.path = path.CGPath
    }
    
    /// Set up the rectangle shape layer by configuring its properties to be red
    /// and the fill colour to be transparant.
    func setMyView() {
        borderLayer = CAShapeLayer()
        borderLayer?.strokeColor = UIColor.redColor().CGColor
        borderLayer?.lineWidth = 2.0
        borderLayer?.fillColor = UIColor.clearColor().CGColor
        self.layer.addSublayer(borderLayer!)
    }
    
}
