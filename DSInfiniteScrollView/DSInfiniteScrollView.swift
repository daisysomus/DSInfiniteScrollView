//
//  ABInfinitePlayerView.swift
//  Vegetable
//
//  Created by liaojinhua on 16/5/4.
//  Copyright © 2016年 April Brother. All rights reserved.
//

import UIKit

@objc protocol DSInfinitePlayerViewDelegate:NSObjectProtocol {
    
    func numberOfViews(playerView:DSInfinitePlayerView) -> Int
    
    func playingViewClassName(playerView:DSInfinitePlayerView) -> String
    
    func playerView(playerView:DSInfinitePlayerView, configView:UIView, atIndex index:Int)
    
    optional func playerView(playerView:DSInfinitePlayerView, clickedIndex index:Int)
}

class DSInfinitePlayerView:UIView {
    
    weak var delegate:DSInfinitePlayerViewDelegate?
    
    var autoPlaying = true {
        didSet {
            if !autoPlaying {
                stopTimer()
            } else {
                if (viewCount > 1 && timer == nil) {
                    startTimer()
                }
            }
        }
    }
    
    var playingInterval = NSTimeInterval(5); // default playing interval
    
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    
    private var leftView:UIView?
    private var rightView:UIView?
    private var middleView:UIView?
    
    private var movingView:UIView?
    
    private var viewCount = 0
    private var displayingIndex = 0
    
    private var isMovingToRight = false
    private var isMovingToLeft = false
    
    private var timer:NSTimer?
    
    private let tapGesture = UITapGestureRecognizer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configView()
    }
    
    override func awakeFromNib() {
        configView()
    }
    
    deinit {
        stopTimer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        guard self.frame.width != scrollView.frame.width else {
            return
        }
        
        scrollView.frame = self.bounds
        scrollView.contentSize = CGSizeMake(self.frame.width * 3, self.frame.height)
        scrollView.contentOffset = CGPoint(x: self.frame.width, y: 0)
        
        if let _ = leftView {
            leftView!.frame = CGRectMake(0, leftView!.frame.minY, self.frame.width, self.frame.height)
        }
        if let _ = middleView {
            middleView!.frame = CGRectMake(self.frame.width, middleView!.frame.minY, self.frame.width, self.frame.height)
        }
        if let _ = rightView {
            rightView!.frame = CGRectMake(middleView!.frame.maxX, rightView!.frame.minY, self.frame.width, self.frame.height)
        }
        pageControl.frame = CGRectMake(0, self.frame.height - 10, pageControl.frame.width, 10)
    }
    
    func reloadData() {
        guard let _ = delegate  else {
            return
        }
        
        createSubviews()
        
        viewCount = delegate!.numberOfViews(self)
        pageControl.numberOfPages = viewCount
        pageControl.sizeToFit()
        pageControl.frame = CGRectMake(0, self.frame.height - 10, pageControl.frame.width, 10)
        displayingIndex = 0
        
        if viewCount == 0 {
            return
        } else if viewCount == 1 {
            scrollView.scrollEnabled = false
            pageControl.hidden = true
        } else {
            scrollView.scrollEnabled = true
            pageControl.hidden = false
        }
        
        updateViews()
        scrollView.contentOffset = CGPointMake(scrollView.frame.width, 0)
        
        if autoPlaying  && viewCount != 1{
            startTimer()
        }
    }
}

extension DSInfinitePlayerView: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        print("scrollview will begin dragging")
    }
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        guard let _ = movingView else {
            return
        }
        
        let xPosition = scrollView.contentOffset.x
        let width = self.frame.width
        let originalOffset = movingView!.frame.origin.x
        
        let gap = originalOffset - xPosition
        
        if gap == 0 {
            return
        }
        if (gap >= width || gap <= -width) {
            if gap > 0 {
                displayingIndex = preNIndex(1)
            } else {
                displayingIndex = nextNIndex(1)
            }
            pageControl.currentPage = displayingIndex
            updateViews()
        } else if (gap > width/2 || (gap < 0 && gap > -width/2 && isMovingToRight)) {
            moveRightToLeft()
        } else if (gap < -width/2 || (gap > 0 && gap < width/2 && isMovingToLeft)) {
            moveLeftToRight()
        }
       
    }
}

// MARK: private method

extension DSInfinitePlayerView {
    private func configView() {
        scrollView.frame = self.bounds
        scrollView.delegate = self
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.contentSize = CGSizeMake(scrollView.frame.width * 3, scrollView.frame.height)
        self.addSubview(scrollView)
        
        self.addSubview(pageControl)
        
        tapGesture.addTarget(self, action:#selector(handleTapGesture(_:)))
        self.addGestureRecognizer(tapGesture)
    }
    
    private func createSubviews() {
        guard let _ = delegate  else {
            return
        }
        
        guard leftView == nil else {
            return
        }
        
        var viewName = delegate!.playingViewClassName(self)
        var aClass = NSClassFromString(viewName) as? UIView.Type
        
        if aClass == nil {
            
            let appName:String = (NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as? String)!
            viewName = "\(appName).\(viewName)"
            
            aClass = NSClassFromString(viewName) as? UIView.Type
            
        }
        
        if let _ = aClass {
            middleView = aClass!.init()
            delegate!.playerView(self, configView: middleView!, atIndex: displayingIndex)
            scrollView.insertSubview(middleView!, belowSubview: pageControl)
            
            leftView = aClass!.init()
            delegate!.playerView(self, configView: leftView!, atIndex: preNIndex(1))
            scrollView.insertSubview(leftView!, belowSubview: pageControl)
            
            rightView = aClass!.init()
            delegate!.playerView(self, configView: rightView!, atIndex: nextNIndex(1))
            scrollView.insertSubview(rightView!, belowSubview: pageControl)
        }
    }
    
    private func updateViews() {
        delegate!.playerView(self, configView: leftView!, atIndex: preNIndex(1))
        delegate!.playerView(self, configView: middleView!, atIndex: displayingIndex)
        delegate!.playerView(self, configView: rightView!, atIndex: nextNIndex(1))
        
        updateFrame()
        movingView = middleView
        
        isMovingToRight = false
        isMovingToLeft = false
    }
    
    private func preNIndex(offset:Int) -> Int {
        if viewCount == 0 {
            return 0
        }
        let index = displayingIndex - offset
        return (index + viewCount) % viewCount
    }
    
    private func nextNIndex(offset:Int) -> Int {
        if viewCount == 0 {
            return 0
        }
        let index = displayingIndex + offset
        return index % viewCount
    }
    
    private func updateFrame() {
        leftView?.frame = CGRectMake(0, 0, self.frame.width, self.frame.height)
        middleView?.frame = CGRectMake(self.frame.width, 0, self.frame.width, self.frame.height)
        rightView?.frame = CGRectMake(self.frame.width * 2, 0, self.frame.width, self.frame.height)
    }
    
    func startTimer() {
        guard autoPlaying else {
            return
        }
        stopTimer()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(playingInterval, target: self, selector: #selector(DSInfinitePlayerView.timerOut), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        if let _ = timer {
            timer!.invalidate()
            timer = nil
        }
    }
    
    func timerOut(timer:NSTimer) {
         moveLeftToRight()
        UIView.animateWithDuration(0.5) {
            self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.width, 0)
        }
    }
    
    private func moveRightToLeft() {
        
        guard !isMovingToLeft else {
            return
        }
        
        isMovingToLeft = true
        isMovingToRight = false
        
        let temp = rightView
        rightView = middleView
        middleView = leftView
        
        var index = preNIndex(2)
        if movingView == middleView {
            index = preNIndex(1)
        }
        
        leftView = temp
        delegate!.playerView(self, configView: leftView!, atIndex: index)
        
        updateFrame()
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x + self.frame.width, 0)
    }
    
    private func moveLeftToRight() {
        guard !isMovingToRight else {
            return
        }
        
        isMovingToRight = true
        isMovingToLeft = false
        
        let temp = leftView
        leftView = middleView
        middleView = rightView
        
        var index = nextNIndex(2)
        if movingView == middleView {
            index = nextNIndex(1)
        }
        rightView = temp
        delegate!.playerView(self, configView: rightView!, atIndex: index)
        
        updateFrame()
        
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x - self.frame.width, 0)
    }
}

extension DSInfinitePlayerView {
    func handleTapGesture(gesture:UITapGestureRecognizer) {
        if delegate != nil && delegate!.respondsToSelector(#selector(DSInfinitePlayerViewDelegate.playerView(_:clickedIndex:))) {
            delegate!.playerView!(self, clickedIndex: displayingIndex)
        }
    }
}

























