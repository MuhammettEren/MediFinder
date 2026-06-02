//
//  SwipeBackExtension.swift
//  MediFinder
//
//  Created by Muhammet Eren on 7.01.2026.
//

import Foundation
import SwiftUI


extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = self
    }
    
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return viewControllers.count > 1
    }
}
