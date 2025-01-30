// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// A coordinator that manages a navigation stack with advanced features
///
/// `StackCoordinator` provides stack-based navigation with history support, allowing
/// users to navigate forward and backward through screens.
///
/// Example of basic usage:
/// ```swift
/// class AppNavigator: StackCoordinator {
///     func showProfile(userId: String) {
///         push(ProfileScreen(userId: userId))
///     }
///     
///     func showSettings() {
///         push(SettingsScreen())
///     }
///     
///     override func makeRootView() -> AnyView {
///         AnyView(
///             HomeScreen()
///                 .navigationBarItems(
///                     trailing: Button("Settings") {
///                         showSettings()
///                     }
///                 )
///         )
///     }
/// }
/// ```
///
/// Example with deep linking:
/// ```swift
/// class ProductNavigator: StackCoordinator {
///     func handle(_ deepLink: JumperDeepLink) -> Bool {
///         guard deepLink.components.first == "products" else { return false }
///         
///         if let productId = deepLink.components[safe: 1] {
///             // Navigate to specific product
///             push(ProductScreen(id: productId))
///             return true
///         }
///         
///         // Show products list
///         setRoot(ProductListScreen())
///         return true
///     }
/// }
/// ```
///
/// Example with state restoration:
/// ```swift
/// class SearchNavigator: StackCoordinator {
///     override func makeRootView() -> AnyView {
///         AnyView(
///             SearchScreen()
///                 .onDisappear {
///                     // Save search history when leaving
///                     navigationHistory.addState(NavigationState(
///                         path: path,
///                         sheetScreen: nil,
///                         fullScreenCover: nil
///                     ))
///                 }
///         )
///     }
/// }
open class StackCoordinator: SwiftUICoordinator {
    /// Whether there are screens to go back to
    public var canGoBack: Bool {
        !path.isEmpty || navigationHistory.canGoBack
    }
    
    /// Whether there are screens to go forward to
    public var canGoForward: Bool {
        navigationHistory.canGoForward
    }
    
    /// Pushes a screen onto the navigation stack
    /// - Parameter screen: The screen to push
    public func push<S: JumperScreen>(_ screen: S) {
        // Remove any forward history
        if navigationHistory.canGoForward {
            navigationHistory.clearForward()
        }
        
        // Present the screen
        present(screen)
    }
    
    /// Pops the top screen from the navigation stack
    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
        
        // Add new state to history
        navigationHistory.addState(NavigationState(
            path: path,
            sheetScreen: sheetScreen,
            fullScreenCover: fullScreenCover
        ))
    }
    
    /// Pops to a specific screen in the navigation stack
    /// - Parameter screen: The screen to pop to
    /// - Warning: Current implementation clears the entire navigation stack and re-presents the target screen.
    ///           This may cause a visible UI flash as the stack is rebuilt.
    /// - TODO: Implement a more sophisticated solution that:
    ///         1. Maintains the navigation stack state
    ///         2. Provides smooth transitions
    ///         3. Possibly uses a custom stack implementation alongside NavigationPath
    public func popTo<S: JumperScreen>(_ screen: S) {
        // Clear the path and re-present the screen
        path = NavigationPath()
        present(screen)
        
        // Add new state to history
        navigationHistory.addState(NavigationState(
            path: path,
            sheetScreen: sheetScreen,
            fullScreenCover: fullScreenCover
        ))
    }
    
    /// Replaces the current navigation stack with a new screen
    /// - Parameter screen: The screen to show
    public func setRoot<S: JumperScreen>(_ screen: S) {
        // Clear the stack
        path = NavigationPath()
        
        // Present the screen
        present(screen)
    }
    
    /// Goes back in the navigation history
    public override func goBack() {
        guard canGoBack else { return }
        
        if !path.isEmpty {
            pop()
        } else if let state = navigationHistory.goBack() {
            applyState(state)
        }
    }
    
    /// Goes forward in the navigation history
    public override func goForward() {
        guard canGoForward else { return }
        
        if let state = navigationHistory.goForward() {
            applyState(state)
        }
    }
    
    /// Creates and returns the root view for this coordinator
    public override func makeRootView() -> AnyView {
        AnyView(
            StackCoordinatorView(coordinator: self)
        )
    }
    
    /// Applies a navigation state to the coordinator
    public override func applyState(_ state: NavigationState) {
        super.applyState(state)
    }
}

/// Internal view for StackCoordinator to handle the actual navigation
private struct StackCoordinatorView: View {
    @ObservedObject var coordinator: StackCoordinator
    
    var body: some View {
        NavigationStack(path: $coordinator.path) {
            coordinator.makeRootView()
                .navigationDestination(for: AnyJumperScreen.self) { screen in
                    screen.makeView()
                }
                .sheet(item: $coordinator.sheetScreen) { screen in
                    screen.makeView()
                }
                .fullScreenCover(item: $coordinator.fullScreenCover) { screen in
                    screen.makeView()
                }
        }
    }
} 
