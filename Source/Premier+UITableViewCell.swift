//
//  Premier+UITableViewCell.swift
//  PremierKit
//
//  Created by Ricardo Pereira on 20/09/2018.
//  Copyright © 2018 Ricardo Pereira. All rights reserved.
//

import UIKit

extension UITableViewCell {

    public static var reuseIdentifier: String {
        return String(describing: self)
    }

}
