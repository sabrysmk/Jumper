// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// A protocol that defines a presentable screen in SwiftUI.
/// This is the core protocol for all screens in the SwiftUI version of Jumper.
public protocol JumperScreen: Identifiable, Hashable {
    /// The type of view that this screen presents
    associatedtype Content: View
    
    /// Creates and returns the SwiftUI view for this screen
    /// - Returns: A SwiftUI view of type Content
    func makeView() -> Content
    
    /// The presentation style for this screen
    /// Defaults to automatic if not implemented
    var presentationStyle: JumperPresentationStyle { get }
}

/// Default implementation for presentation style and Hashable
public extension JumperScreen {
    var presentationStyle: JumperPresentationStyle {
        .automatic
    }
    
    // Default Hashable implementation
    func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(Self.self))
        hasher.combine(id)
    }
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

/// Defines how a screen should be presented in SwiftUI
public enum JumperPresentationStyle {
    /// Automatic presentation style based on context
    case automatic
    /// Present as a push navigation
    case push
    /// Present modally
    case modal
    /// Present as a full screen cover
    case fullScreen
    /// Present as a sheet
    case sheet
} 