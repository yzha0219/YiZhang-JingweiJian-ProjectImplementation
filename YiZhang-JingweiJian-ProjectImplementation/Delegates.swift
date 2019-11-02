//
//  PhotoDelegate.swift
//  YiZhang-JingweiJian-ProjectImplementation
//
//  Created by Yi Zhang on 31/10/19.
//  Copyright © 2019 Yi Zhang. All rights reserved.
//

import Foundation
import UIKit
protocol PhotoDelegate: AnyObject{
    func updatePhoto(image: UIImage)
    func readFilenames()
}
