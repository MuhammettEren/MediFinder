//
//  Application_utility.swift
//  MediFinder
//
//  Created by Muhammet Eren on 7.01.2026.
//

import Foundation
import UIKit

final class Application_utility {
    static var rootViewController: UIViewController? {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return nil
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return nil
        }
        
        return root
    }
}
