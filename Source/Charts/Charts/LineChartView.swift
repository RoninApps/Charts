//
//  LineChartView.swift
//  Charts
//
//  Copyright 2015 Daniel Cohen Gindi & Philipp Jahoda
//  A port of MPAndroidChart for iOS
//  Licensed under Apache License 2.0
//
//  https://github.com/danielgindi/Charts
//

import Foundation
import CoreGraphics

/// Chart that draws lines, surfaces, circles, ...
open class LineChartView: BarLineChartViewBase, LineChartDataProvider
{
  
    internal override func initialize()
    {
        super.initialize()
        
        renderer = LineChartRenderer(dataProvider: self, animator: _animator, viewPortHandler: _viewPortHandler)
    }
    
    // MARK: - LineChartDataProvider
    
    open var lineData: LineChartData? { return _data as? LineChartData }
  
    // Retrieve calculated path
    public func pathUpdated(path: CGPath) {
      guard lineLayer == nil, glowLayer == nil else {
        return
      }
      lineLayer = CAShapeLayer()
      drawPath(path: path)
      guard isGlowLayerEnabled else {
        startPathAnimation()
        return
      }
      glowLayer = CAShapeLayer()
      drawGlowPath(path: path)
      drawGlowAnimations()
      startPathAnimation()
    }
}

extension LineChartView {
    func drawPath(path: CGPath) {
      lineLayer.frame = self.bounds
      lineLayer.lineWidth = 2.0
      lineLayer.fillColor = UIColor.clear.cgColor
      lineLayer.path = path
      
      if isShadowEnabled {
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.shadowColor = lineLayerPathColor.cgColor
        lineLayer.shadowOffset = .zero
        lineLayer.shadowRadius = 10
        lineLayer.shadowOpacity = 1.0
      } else {
        lineLayer.strokeColor = lineLayerPathColor.cgColor
      }
      self.layer.addSublayer(lineLayer)
    }
  
    func drawGlowPath(path: CGPath) {
      guard isGlowLayerEnabled else { return }
      glowLayer.frame = self.bounds
      glowLayer.lineWidth = 3.0
      glowLayer.fillColor = UIColor.clear.cgColor
      glowLayer.path = path
      if isShadowEnabled {
        glowLayer.strokeColor = lineLayerPathColor.cgColor
        glowLayer.shadowColor = lineLayerPathColor.cgColor
        glowLayer.shadowOffset = .zero
        glowLayer.shadowRadius = 10
        glowLayer.shadowOpacity = 1.0
      }
      self.layer.addSublayer(glowLayer)
    }
  
    func drawGlowAnimations() {
      guard isGlowLayerEnabled, isGlowAnimationEnabled else { return }
      
      let lineLayerAnimation = CABasicAnimation(keyPath: "shadowRadius")
      lineLayerAnimation.fromValue = 10
      lineLayerAnimation.toValue = 5
      lineLayerAnimation.duration = 2.5
      lineLayerAnimation.repeatCount = .infinity
      lineLayerAnimation.autoreverses = true
      lineLayerAnimation.isRemovedOnCompletion = false
      lineLayerAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      lineLayer.add(lineLayerAnimation, forKey: "breathing")
      
      let glowLayerAnimation = CABasicAnimation(keyPath: "opacity")
      glowLayerAnimation.fromValue = 1.0
      glowLayerAnimation.toValue = 0.4
      glowLayerAnimation.duration = 1.5
      glowLayerAnimation.repeatCount = .infinity
      glowLayerAnimation.autoreverses = true
      glowLayerAnimation.isRemovedOnCompletion = false
      glowLayerAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
      glowLayer.add(glowLayerAnimation, forKey: "breathing")
    }
  
    func startPathAnimation() {
      guard pathAnimationEnabled else { return }
      let pathAnimation = CABasicAnimation(keyPath: "strokeEnd")
      pathAnimation.duration = 1.6
      pathAnimation.fromValue = 0.0
      pathAnimation.toValue = lineLayer.strokeEnd
      pathAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
      pathAnimation.fillMode = .forwards
      pathAnimation.isRemovedOnCompletion = false
      lineLayer.add(pathAnimation, forKey: "path")
      guard isGlowLayerEnabled else { return }
      glowLayer.add(pathAnimation, forKey: "path")
    }
}
