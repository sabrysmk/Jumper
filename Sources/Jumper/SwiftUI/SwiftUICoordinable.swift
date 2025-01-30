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

/// A protocol that defines the core functionality of a SwiftUI coordinator
///
/// This protocol provides the foundation for building coordinators that manage navigation
/// and presentation of screens in a SwiftUI application.
///
/// Example of a basic coordinator:
/// ```swift
/// class MainCoordinator: SwiftUICoordinable {
///     var path = NavigationPath()
///     var navigationHistory = NavigationHistory()
///     weak var parent: (any SwiftUICoordinable)?
///     
///     func makeRootView() -> AnyView {
///         AnyView(
///             HomeScreen()
///                 .navigationDestination(for: AnyJumperScreen.self) { screen in
///                     screen.makeView()
///                 }
///         )
///     }
/// }
/// ```
///
/// Example of coordinator with deep linking:
/// ```swift
/// class AppCoordinator: SwiftUICoordinable {
///     func handle(_ deepLink: JumperDeepLink) -> Bool {
///         switch deepLink.components.first {
///         case "profile":
///             present(ProfileScreen(userId: deepLink.components[1]))
///             return true
///         case "settings":
///             present(SettingsScreen())
///             return true
///         default:
///             return false
///         }
///     }
/// }
/// ```
///
/// Example of state persistence:
/// ```swift
/// class AuthCoordinator: SwiftUICoordinable {
///     func saveState() -> Data? {
///         // Save current authentication state
///         try? JSONEncoder().encode(currentUser)
///     }
///     
///     func restore(from data: Data) {
///         // Restore authentication state
///         currentUser = try? JSONDecoder().decode(User.self, from: data)
///     }
/// }
public protocol SwiftUICoordinable: ObservableObject {
    /// The type of view that this coordinator manages
    associatedtype RootView: View
    
    /// The navigation path for this coordinator
    var path: NavigationPath { get set }
    
    /// The currently presented sheet screen
    var sheetScreen: AnyJumperScreen? { get set }
    
    /// The currently presented full screen cover
    var fullScreenCover: AnyJumperScreen? { get set }
    
    /// Navigation history for back/forward support
    var navigationHistory: NavigationHistory { get }
    
    /// Creates and returns the root view for this coordinator
    /// - Returns: A SwiftUI view of type RootView
    func makeRootView() -> AnyView
    
    /// Dismisses the current screen
    func dismiss()
    
    /// Pops to root view
    func popToRoot()
    
    /// Navigate back in history
    func goBack()
    
    /// Navigate forward in history
    func goForward()
}

/// Represents the navigation history
public class NavigationHistory: ObservableObject {
    /// The history of navigation states
    private var history: [NavigationState] = []
    /// The current index in the history
    private var currentIndex: Int = -1
    
    /// Whether we can go back in history
    public var canGoBack: Bool { currentIndex > 0 }
    /// Whether we can go forward in history
    public var canGoForward: Bool { currentIndex < history.count - 1 }
    
    /// The current navigation state
    public var currentState: NavigationState? {
        guard currentIndex >= 0 && currentIndex < history.count else { return nil }
        return history[currentIndex]
    }
    
    /// Adds a new state to the history
    public func addState(_ state: NavigationState) {
        // Remove any forward history
        if currentIndex < history.count - 1 {
            history.removeSubrange((currentIndex + 1)...)
        }
        
        history.append(state)
        currentIndex = history.count - 1
    }
    
    /// Clears forward history
    public func clearForward() {
        if currentIndex < history.count - 1 {
            history.removeSubrange((currentIndex + 1)...)
        }
    }
    
    /// Moves back in history
    public func goBack() -> NavigationState? {
        guard canGoBack else { return nil }
        currentIndex -= 1
        return currentState
    }
    
    /// Moves forward in history
    public func goForward() -> NavigationState? {
        guard canGoForward else { return nil }
        currentIndex += 1
        return currentState
    }
}

/// Represents a single navigation state
public struct NavigationState {
    public let path: NavigationPath
    public let sheetScreen: AnyJumperScreen?
    public let fullScreenCover: AnyJumperScreen?
    
    public init(
        path: NavigationPath,
        sheetScreen: AnyJumperScreen?,
        fullScreenCover: AnyJumperScreen?
    ) {
        self.path = path
        self.sheetScreen = sheetScreen
        self.fullScreenCover = fullScreenCover
    }
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
        
        // Add new state to history
        navigationHistory.addState(NavigationState(
            path: path,
            sheetScreen: sheetScreen,
            fullScreenCover: fullScreenCover
        ))
    }
    
    func popToRoot() {
        path.removeLast(path.count)
        
        // Add new state to history
        navigationHistory.addState(NavigationState(
            path: path,
            sheetScreen: sheetScreen,
            fullScreenCover: fullScreenCover
        ))
    }
    
    func goBack() {
        if let state = navigationHistory.goBack() {
            applyState(state)
        }
    }
    
    func goForward() {
        if let state = navigationHistory.goForward() {
            applyState(state)
        }
    }
    
    private func applyState(_ state: NavigationState) {
        path = state.path
        sheetScreen = state.sheetScreen
        fullScreenCover = state.fullScreenCover
    }
} 