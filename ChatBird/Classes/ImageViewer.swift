//
//  ImageViewer.swift
//  ChatBird
//
//  Adapted from
//  https://schiavo.me/2019/pinch-to-zoom-image-view/ by David Rajan on 1/31/20
//
//  Copyright (c) 2019 Julian Schiavo. All rights reserved. Licensed under the MIT License.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import UIKit

class ImageZoomView: UIScrollView, UIScrollViewDelegate {
    
    var imageView: UIImageView!
    var gestureRecognizer: UITapGestureRecognizer!

    convenience init(frame: CGRect, image: UIImage?) {
        self.init(frame: frame)
                
        guard let imageToUse = image
        else {
            fatalError("No image was passed in and failed to find an image at the path.")
        }
        
        // Creates the image view and adds it as a subview to the scroll view
        imageView = UIImageView(image: imageToUse)
        imageView.frame = frame
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        setupScrollView(image: imageToUse)
        setupGestureRecognizer()
    }
    
    // Sets the scroll view delegate and zoom scale limits.
    // Change the `maximumZoomScale` to allow zooming more than 2x.
    func setupScrollView(image: UIImage) {
        delegate = self
        
        minimumZoomScale = 1.0
        maximumZoomScale = 6.0
    }
    
    // Sets up the gesture recognizer that receives double taps to auto-zoom
    func setupGestureRecognizer() {
        gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        gestureRecognizer.numberOfTapsRequired = 2
        addGestureRecognizer(gestureRecognizer)
    }

    // Handles a double tap by either resetting the zoom or zooming to where was tapped
    @IBAction func handleDoubleTap() {
        if zoomScale == 1 {
            zoom(to: zoomRectForScale(maximumZoomScale, center: gestureRecognizer.location(in: gestureRecognizer.view)), animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }

    // Calculates the zoom rectangle for the scale
    func zoomRectForScale(_ scale: CGFloat, center: CGPoint) -> CGRect {
        var zoomRect = CGRect.zero
        zoomRect.size.height = imageView.frame.size.height / scale
        zoomRect.size.width = imageView.frame.size.width / scale
        let newCenter = convert(center, from: imageView)
        zoomRect.origin.x = newCenter.x - (zoomRect.size.width / 2.0)
        zoomRect.origin.y = newCenter.y - (zoomRect.size.height / 2.0)
        return zoomRect
    }
    
    // Tell the scroll view delegate which view to use for zooming and scrolling
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}

class ImageZoomViewController: UIViewController {
    var image: UIImage?
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(frame: CGRect(x: view.frame.width - 50.0, y: 20, width: 30, height: 30))
        button.tintColor = .white
        button.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.setImage(UIImage(named: "xmark.circle.fill"), for: .normal)
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        guard let image = image else { return }
        
        let zoomView = ImageZoomView(frame: view.frame, image: image)
        view.addSubview(zoomView)
        view.addSubview(closeButton)
    }
    
    @objc
    func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
}
