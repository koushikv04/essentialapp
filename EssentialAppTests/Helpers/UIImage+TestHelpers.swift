//
//  UIImage+TestHelpers.swift
//  EssentialApp
//
//  Created by Kouv on 17/01/2025.
//
import UIKit

public extension UIImage {
    static func make(withColor color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        return UIGraphicsImageRenderer(size: rect.size,format:format).image { context in
            color.setFill()
            context.fill(rect)
        }
    }
}
