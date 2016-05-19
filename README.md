# DSInfiniteScrollView
Infinite scroll any view
## Features
* Scroll any view (include custom view and system view)
* Infinite scroll
* Auto playing images with setting interval

## Installation

		pod "DSInfiniteScrollView"
		
or

		copy the source file to your project
		
## How to use
	
		infiniteScrollView = DSInfiniteScrollView.init(frame: CGRectMake(0, 0, 200, 200))
        infiniteScrollView.delegate = self
        infiniteScrollView.reloadData()
    
then implement the protocol DSInfiniteImagePlayerViewDelegate
		
		extension ViewController:DSInfiniteScrollViewDelegate {
    
    func numberOfViews(scrollView: DSInfiniteScrollView) -> Int {
        return 3
    }
    
    func scrollingViewClassName(scrollView: DSInfiniteScrollView) -> String {
        return String(UIImageView)
    }
    
    func scrollView(scrollView: DSInfiniteScrollView, configView: UIView, atIndex index: Int) {
        let imageView = configView as! UIImageView
        
        
        let imageName = "image" + "\(index%3 + 1)"
        imageView.image = UIImage(named: imageName)
    }
}
 		
    
you also can use this in storyboard. just set the class of your view to DSInfiniteScrollView, then make an outlet from storyboard and set the properties you want.

> Note: you must set the delegate, or it won't display the images.
