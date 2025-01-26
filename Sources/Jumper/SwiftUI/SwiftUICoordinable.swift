// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Type erasing container for JumperScreen
public struct AnyJumperScreen: Identifiable, Hashable {
    private let _makeView: () -> AnyView
    private let _presentationStyle: JumperPresentationStyle
    public let id: AnyHashable
    
    public init<S: JumperScreen>(_ screen: S) {
        self._makeView = { AnyView(screen.makeView()) }
        self._presentationStyle = screen.presentationStyle
        self.id = AnyHashable(screen.id)
    }
    
    public func makeView() -> AnyView {
        _makeView()
    }
    
    public var presentationStyle: JumperPresentationStyle {
        _presentationStyle
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: AnyJumperScreen, rhs: AnyJumperScreen) -> Bool {
        lhs.id == rhs.id
    }
}

/// A protocol that defines a coordinator in SwiftUI.
/// This is the core protocol for all coordinators in the SwiftUI version of Jumper.
public protocol SwiftUICoordinable: ObservableObject {
    /// The type of view that this coordinator manages
    associatedtype RootView: View
    
    /// The navigation path for this coordinator
    var path: NavigationPath { get set }
    
    /// The currently presented sheet screen
    var sheetScreen: AnyJumperScreen? { get set }
    
    /// The currently presented full screen cover
    var fullScreenCover: AnyJumperScreen? { get set }
    
    /// Creates and returns the root view for this coordinator
    /// - Returns: A SwiftUI view of type RootView
    func makeRootView() -> AnyView
    
    /// Dismisses the current screen
    func dismiss()
    
    /// Pops to root view
    func popToRoot()
}

/// Default implementation for SwiftUICoordinable
public extension SwiftUICoordinable {
    func dismiss() {
        if sheetScreen != nil {
            sheetScreen = nil
        } else if fullScreenCover != nil {
            fullScreenCover = nil
        } else if !path.isEmpty {
            path.removeLast()
        }
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
} 