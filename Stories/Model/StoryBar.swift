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
    
    deinit {
        if let _ = barAnimation {
            stop()
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
    
    func resetSegmentFrames() {
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
    }
    
    func resetSegmentsTill(index: Int) {
        var resetTillIndex = index
        if let _ = barAnimation {
            stop()
        }

        if resetTillIndex > segments.count - 1 {
            resetTillIndex = segments.count - 1
        }

        currentAnimationIndex = resetTillIndex
        resetSegmentFrames()
        for segmentIdx in 0..<resetTillIndex {
            segments[segmentIdx].animatingBar.frame.size.width = segments[segmentIdx].nonAnimatingBar.frame.size.width
        }
    }
    
    func removeOldAnimation(newWidth: CGFloat = 0) {
        stop()
        let oldAnimatingBar = segments[currentAnimationIndex].animatingBar
        oldAnimatingBar.frame.size.width = newWidth
    }
    
    func previous() {
        removeOldAnimation()
        let newIndex = currentAnimationIndex - 1
        if newIndex < 0 {
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
            delegate?.segmentedProgressBarReachEnd()
        }
    }
}

// MARK: - Animations
extension StoryBar {
    
    func showStoryBar() {
        if self.alpha == 0 {
            UIView.animate(withDuration: 0.3) { 
                self.alpha = 1
            }
        }
    }
    
    func hideStoryBar() {
        if self.alpha == 1 {
            UIView.animate(withDuration: 0.3) { 
                self.alpha = 0
            }
        }
    }
    
    func startAnimation() {
        layoutSubviews()
        animate()
    }
    
    func pause() {
        hideStoryBar()
        barAnimation?.pauseAnimation()
    }
    
    func resume() {
        showStoryBar()
        barAnimation?.startAnimation()
    }
    
    func stop() {
        barAnimation?.stopAnimation(true)
        if barAnimation?.state == .stopped {
            barAnimation?.finishAnimation(at: .current)
        }
    }
    
    func animate(animationIndex: Int = 0) {
        let currentSegment = segments[animationIndex]
        currentAnimationIndex = animationIndex
        
        if let _ = barAnimation {
            barAnimation = nil
        }
        
        showStoryBar()
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
