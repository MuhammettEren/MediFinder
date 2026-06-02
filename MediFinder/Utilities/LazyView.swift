//
//  LazyView.swift
//  MediFinder
//
//  Performance optimization utility for lazy view loading
//

import SwiftUI

/// Defers view creation until the view is actually rendered.
/// Useful for optimizing switch statements with many cases.
struct LazyView<Content: View>: View {
    
    let build: () -> Content
    
    init(_ build: @autoclosure @escaping () -> Content) {
        self.build = build
    }
    
    init(@ViewBuilder _ build: @escaping () -> Content) {
        self.build = build
    }
    
    var body: Content {
        build()
    }
}
