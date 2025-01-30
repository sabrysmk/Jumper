// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// A base class for SwiftUI coordinators that provides common navigation functionality
///
/// This class implements the `SwiftUICoordinable` protocol and provides a foundation for
/// building coordinators with navigation stack, modal presentations, and state management.
///
/// Example of basic usage:
/// ```swift
/// class AppCoordinator: SwiftUICoordinator {
///     override func makeRootView() -> AnyView {
///         AnyView(
///             HomeScreen()
///                 .onTapGesture {
///                     present(ProfileScreen(userId: "123"))
///                 }
///         )
///     }
/// }
/// ```
///
/// Example of nested coordinators:
/// ```swift
/// class MainCoordinator: SwiftUICoordinator {
///     private let authCoordinator: AuthCoordinator
///     private let homeCoordinator: HomeCoordinator
///     
///     init() {
///         authCoordinator = AuthCoordinator()
///         homeCoordinator = HomeCoordinator()
///         super.init()
///         
///         authCoordinator.parent = self
///         homeCoordinator.parent = self
///     }
///     
///     override func makeRootView() -> AnyView {
///         if isAuthenticated {
///             return homeCoordinator.makeRootView()
///         } else {
///             return authCoordinator.makeRootView()
///         }
///     }
/// }
/// ```
///
/// Example of navigation state handling:
/// ```swift
/// class SettingsCoordinator: SwiftUICoordinator {
///     override func makeRootView() -> AnyView {
///         AnyView(
///             SettingsScreen()
///                 .onChange(of: scenePhase) { phase in
///                     if phase == .background {
///                         // Save navigation state when app goes to background
///                         saveState()
///                     }
///                 }
///         )
///     }
/// }
open class SwiftUICoordinator: SwiftUICoordinable {
    public typealias RootView = AnyView
    
    /// The navigation path for this coordinator
    @Published public var path: NavigationPath = NavigationPath()
    
    /// The currently presented sheet screen
    @Published public var sheetScreen: AnyJumperScreen?
    
    /// The currently presented full screen cover
    @Published public var fullScreenCover: AnyJumperScreen?
    
    /// Navigation history for back/forward support
    public let navigationHistory: NavigationHistory
    
    /// The parent coordinator if any
    public weak var parent: (any SwiftUICoordinable)?
    
    /// Creates a new coordinator
    /// - Parameter parent: The parent coordinator if any
    public init(parent: (any SwiftUICoordinable)? = nil) {
        self.navigationHistory = NavigationHistory()
        self.parent = parent
    }
    
    /// Creates and returns the root view for this coordinator
    /// Must be overridden by subclasses
    open func makeRootView() -> AnyView {
        fatalError("makeRootView() must be overridden")
    }
    
    /// Presents a screen using the specified presentation style
    /// - Parameter screen: The screen to present
    public func present<S: JumperScreen>(_ screen: S) {
        let anyScreen = AnyJumperScreen(screen)
        switch screen.presentationStyle {
        case .automatic, .push:
            path.append(anyScreen)
        case .modal, .sheet:
            sheetScreen = anyScreen
        case .fullScreen:
            fullScreenCover = anyScreen
        }
        
        // Add new state to history
        navigationHistory.addState(NavigationState(
            path: path,
            sheetScreen: sheetScreen,
            fullScreenCover: fullScreenCover
        ))
    }
    
    /// Dismisses the current screen
    open func dismiss() {
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
    
    /// Pops to root view
    open func popToRoot() {
        path.removeLast(path.count)
        
        // Add new state to history
        navigationHistory.addState(NavigationState(
            path: path,
            sheetScreen: sheetScreen,
            fullScreenCover: fullScreenCover
        ))
    }
    
    /// Navigate back in history
    open func goBack() {
        if let state = navigationHistory.goBack() {
            applyState(state)
        }
    }
    
    /// Navigate forward in history
    open func goForward() {
        if let state = navigationHistory.goForward() {
            applyState(state)
        }
    }
    
    /// Applies a navigation state
    open func applyState(_ state: NavigationState) {
        path = state.path
        sheetScreen = state.sheetScreen
        fullScreenCover = state.fullScreenCover
    }
}

/// View modifier for coordinator-based navigation
private struct CoordinatorViewModifier<T: SwiftUICoordinator>: ViewModifier {
    @ObservedObject var coordinator: T
    
    func body(content: Content) -> some View {
        NavigationStack(path: $coordinator.path) {
            content
                .sheet(item: $coordinator.sheetScreen) { screen in
                    screen.makeView()
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { screen in
                    screen.makeView()
                }
                .navigationDestination(for: AnyJumperScreen.self) { screen in
                    screen.makeView()
                }
                .toolbar {
                    ToolbarItemGroup(placement: .navigationBarLeading) {
                        if coordinator.navigationHistory.canGoBack {
                            Button(action: { coordinator.goBack() }) {
                                Image(systemName: "chevron.backward")
                            }
                        }
                    }
                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        if coordinator.navigationHistory.canGoForward {
                            Button(action: { coordinator.goForward() }) {
                                Image(systemName: "chevron.forward")
                            }
                        }
                    }
                }
        }
        .environmentObject(coordinator)
    }
}

/// View extension to support coordinator-based navigation
public extension View {
    /// Adds navigation support for a coordinator
    /// - Parameter coordinator: The coordinator to use for navigation
    /// - Returns: A view with navigation support
    func withCoordinator<T: SwiftUICoordinator>(_ coordinator: T) -> some View {
        modifier(CoordinatorViewModifier(coordinator: coordinator))
    }
} 
