//
//  UIImage+.swift
//  Picterest
//
//  Created by 이경민 on 2022/07/29.
//

import UIKit

extension UIImage {
    func resizeImageTo(newWidth: CGFloat) -> UIImage? {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
}
