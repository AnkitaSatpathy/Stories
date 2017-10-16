//
//  StoryBar.swift
//  Stories
//
//  Created by Ankita Satpathy on 16/10/17.
//  Copyright © 2017 Ankita Satpathy. All rights reserved.
//

import Foundation
import UIKit

class Segment {
    let nonAnimatingBar = UIView()
    let animatingBar = UIView()
    init() {
    }
}

protocol SegmentedProgressBarDelegate: class {
    func segmentedProgressBarChangedIndex(index: Int)
}

class StoryBar : UIView{
    
     weak var delegate: SegmentedProgressBarDelegate?
    var animatingBarColor = UIColor.gray {
        didSet {
            self.updateColors()
        }
    }
    var nonAnimatingBarColor = UIColor.gray.withAlphaComponent(0.25) {
        didSet {
            self.updateColors()
        }
    }
    var padding: CGFloat = 2.0
    var segments = [Segment]()
    let duration: TimeInterval
    var currentAnimationIndex = 0
    var hasDoneLayout = false
    
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.nonAnimatingBar)
            addSubview(segment.animatingBar)
            segments.append(segment)
        }
        self.updateColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if hasDoneLayout {
            return
        }
        let width = (frame.width - (padding * CGFloat(segments.count - 1)) ) / CGFloat(segments.count)
        for (index, segment) in segments.enumerated() {
            let segFrame = CGRect(x: CGFloat(index) * (width + padding), y: 0, width: width, height: frame.height)
            segment.nonAnimatingBar.frame = segFrame
            segment.animatingBar.frame = segFrame
            segment.animatingBar.frame.size.width = 0
            
            let cr = frame.height / 2
            segment.nonAnimatingBar.layer.cornerRadius = cr
            segment.animatingBar.layer.cornerRadius = cr
        }
        hasDoneLayout = true
    }
    
    func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    func animate(animationIndex: Int = 0) {
        let currentSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
       
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveLinear, animations: {
            currentSegment.animatingBar.frame.size.width = currentSegment.nonAnimatingBar.frame.width
        }) { (finished) in
            if !finished {
                return
            }
            self.next()
        }
    }
    
    func next() {
        let newIndex = self.currentAnimationIndex + 1
        if newIndex < self.segments.count {
            self.delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            self.animate(animationIndex: newIndex)
        }
    }
    func updateColors() {
        for segment in segments {
            segment.animatingBar.backgroundColor = animatingBarColor
            segment.nonAnimatingBar.backgroundColor = nonAnimatingBarColor
        }
    }
}
