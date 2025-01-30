// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// A protocol that defines a screen in the navigation system
///
/// Use this protocol to define screens that can be presented in your application.
/// Each screen has a unique identifier and presentation style.
///
/// Example of a basic screen:
/// ```swift
/// struct ProfileScreen: JumperScreen {
///     let userId: String
///     
///     var body: some View {
///         Text("Profile for user: \(userId)")
///     }
/// }
/// ```
///
/// Example of a screen with custom presentation style:
/// ```swift
/// struct SettingsScreen: JumperScreen {
///     var presentationStyle: PresentationStyle {
///         .modal
///     }
///     
///     var body: some View {
///         NavigationView {
///             List {
///                 Text("Settings")
///             }
///         }
///     }
/// }
/// ```
///
/// Example of a screen with state persistence:
/// ```swift
/// struct EditProfileScreen: JumperScreen, StatePersistable {
///     static var stateIdentifier: String { "edit-profile" }
///     
///     @State private var name: String = ""
///     
///     var body: some View {
///         Form {
///             TextField("Name", text: $name)
///         }
///     }
/// }
/// ```
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
    /// Present modally (similar to sheet)
    case modal
    /// Present as a full screen cover
    case fullScreen
    /// Present as a sheet from bottom
    case sheet
    
    /// The default presentation style
    public static var `default`: JumperPresentationStyle {
        .automatic
    }
} 