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
    func segmentedProgressBarReachEnd()
    func segmentedProgressBarReachPrevious()
}

class StoryBar : UIView{
    
    weak var delegate: SegmentedProgressBarDelegate?
    var animatingBarColor = UIColor.gray {
        didSet {
            updateColors()
        }
    }
    var nonAnimatingBarColor = UIColor.gray.withAlphaComponent(0.25) {
        didSet {
            updateColors()
        }
    }
    var padding: CGFloat = 2.0
    var segments = [Segment]()
    let duration: TimeInterval
    var currentAnimationIndex = 0
    var hasDoneLayout = false
    var barAnimation: UIViewPropertyAnimator?
    
    init(numberOfSegments: Int, duration: TimeInterval = 5.0) {
        self.duration = duration
        super.init(frame: CGRect.zero)
        
        for _ in 0..<numberOfSegments {
            let segment = Segment()
            addSubview(segment.nonAnimatingBar)
            addSubview(segment.animatingBar)
            segments.append(segment)
        }
        updateColors()
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
    
    deinit {
        if let _ = barAnimation {
            barAnimation?.stopAnimation(true)
        }
    }
    
    func updateColors() {
        for segment in segments {
            segment.animatingBar.backgroundColor = animatingBarColor
            segment.nonAnimatingBar.backgroundColor = nonAnimatingBarColor
        }
    }
}

// MARK: - Playback
extension StoryBar {
    
    func resetSegments() {
        if let _ = barAnimation {
            barAnimation?.stopAnimation(true)
        }
        currentAnimationIndex = 0
        for segment in segments {
            let oldFrame = segment.nonAnimatingBar.frame
            segment.animatingBar.frame = CGRect(x: oldFrame.origin.x,
                                                y: oldFrame.origin.y,
                                                width: 0,
                                                height: oldFrame.size.height) 
        }
        self.layoutIfNeeded()
        if barAnimation?.state == .stopped {
            barAnimation?.finishAnimation(at: .current)
        }
    }
    
    func removeOldAnimation(newWidth: CGFloat = 0) {
        barAnimation?.stopAnimation(true)
        let oldAnimatingBar = segments[currentAnimationIndex].animatingBar
        let oldFrame = oldAnimatingBar.frame
        oldAnimatingBar.frame = CGRect(x: oldFrame.origin.x,
                                       y: oldFrame.origin.y,
                                       width: newWidth,
                                       height: oldFrame.size.height)
        if barAnimation?.state == .stopped {
            barAnimation?.finishAnimation(at: .current)
        }
    }
    
    func previous() {
        removeOldAnimation()
        let newIndex = currentAnimationIndex - 1
        if newIndex < 0 {
            resetSegments()
            delegate?.segmentedProgressBarReachPrevious()
        } else {
            currentAnimationIndex = newIndex
            removeOldAnimation()
            delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            animate(animationIndex: newIndex)
        }
    }

    func next() {
        let newIndex = currentAnimationIndex + 1
        if newIndex < segments.count {
            let oldSegment = segments[currentAnimationIndex]
            removeOldAnimation(newWidth: oldSegment.nonAnimatingBar.frame.width)
            delegate?.segmentedProgressBarChangedIndex(index: newIndex)
            animate(animationIndex: newIndex)
        } else {
            resetSegments()
            delegate?.segmentedProgressBarReachEnd()
        }
    }
}

// MARK: - Animations
extension StoryBar {
    
    func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    func pause() {
        barAnimation?.pauseAnimation()
    }
    
    func resume() {
        barAnimation?.startAnimation()
    }
    
    func animate(animationIndex: Int = 0) {
        let currentSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        
        if let _ = barAnimation {
            barAnimation = nil
        }
        
        barAnimation = UIViewPropertyAnimator(duration: duration, curve: .linear, animations: { 
            currentSegment.animatingBar.frame.size.width = currentSegment.nonAnimatingBar.frame.width
        })
        
        barAnimation?.addCompletion { [weak self] (position) in
            if position == .end {
                self?.next()
            }
        }
        
        barAnimation?.startAnimation()
    }
}
