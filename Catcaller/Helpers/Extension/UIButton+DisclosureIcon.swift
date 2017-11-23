//
//  UIButton+DisclosureIcon.swift
//  Catcaller
//
//  Created by Nicolas Dreux on 14/11/2017.
//  Copyright © 2017 Nicolas Dreux. All rights reserved.
//

import UIKit

extension UIButton
{
    /*
     Add right arrow disclosure indicator to the button with normal and
     highlighted colors for the title text and the image
     */
    func disclosureButton(baseColor:UIColor)
    {
        self.setTitleColor(baseColor, for: .normal)
        self.setTitleColor(baseColor.withAlphaComponent(0.3), for: .highlighted)

        guard let image = UIImage(named: "disclosureIcon")?.withRenderingMode(.alwaysTemplate) else
        {
            return
        }
        guard let imageHighlight = UIImage(named: "disclosureIcon")?.alpha(0.3)?.withRenderingMode(.alwaysTemplate) else
        {
            return
        }

        self.imageView?.contentMode = .scaleAspectFit

        self.setImage(image, for: .normal)
        self.setImage(imageHighlight, for: .highlighted)
        self.imageEdgeInsets = UIEdgeInsetsMake(0, self.bounds.size.width-image.size.width*1.5, 0, 0)

        let bottomBorder: CALayer = CALayer()
        bottomBorder.borderColor = UIColor.lightGray.cgColor
        bottomBorder.borderWidth = 1
        bottomBorder.frame = CGRect(origin: CGPoint(x: 15, y: 30), size: CGSize(width: self.layer.frame.width - 30, height: 1))

        self.layer.addSublayer(bottomBorder)
    }

}
