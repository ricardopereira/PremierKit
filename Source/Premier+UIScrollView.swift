//
//  Premier+UIScrollView.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UIScrollView {

    public func scrollToBottom(_ animated: Bool = false) {
        let offsetY = self.contentSize.height - self.frame.size.height
        self.setContentOffset(CGPoint(x: 0, y: max(0, offsetY)), animated: animated)
    }

}
