//
//  Utils.swift
//  ChatBird
//
//  Created by David Rajan on 2/21/20.
//

import Foundation

extension UIImage {
    func round() -> UIImage {

        let imageGenerator: () -> UIImage = {
            let imageView: UIImageView = UIImageView(image: self)
            let layer = imageView.layer
            layer.masksToBounds = true
            layer.cornerRadius = imageView.bounds.size.width / 2.0
            UIGraphicsBeginImageContext(imageView.bounds.size)
            layer.render(in: UIGraphicsGetCurrentContext()!)
            let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return roundedImage!
        }

        if Thread.isMainThread {
            return imageGenerator()
        } else {

            var image: UIImage!
            DispatchQueue.main.sync {
                image = imageGenerator()
            }

            return image
        }
    }

    func tint(with fillColor: UIColor) -> UIImage {
        let image = withRenderingMode(.alwaysTemplate)
        let imageSize = CGSize(width: 200, height: 200)
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        return renderer.image { context in
            fillColor.set()
            image.draw(in: CGRect(origin: .zero, size: imageSize))
        }
    }
    
    func mergeWith(topImage: UIImage?) -> UIImage {
        guard let topImage = topImage else { return self }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let topImageOrigin = CGPoint(x: (size.width - topImage.size.width) / 2, y: (size.height - topImage.size.height) / 2)
            
            draw(at: .zero, blendMode: .copy, alpha: 1.0)
            topImage.draw(at: topImageOrigin, blendMode: .normal, alpha: 0.8)
        }
    }
}

extension Bundle {
    private class BundleFinder { }
    public static let chatBird = Bundle(for: BundleFinder.self)
}

extension String {
    static func initialsFor(name: String) -> String {
        var nameComponents = name.uppercased().components(separatedBy: CharacterSet.letters.inverted)
        nameComponents.removeAll(where: { $0.isEmpty} )

        let firstInitial = nameComponents.first?.first
        let lastInitial  = nameComponents.count > 1 ? nameComponents.last?.first : nil
        return (firstInitial != nil ? "\(firstInitial!)" : "") + (lastInitial != nil ? "\(lastInitial!)" : "")
    }
}
