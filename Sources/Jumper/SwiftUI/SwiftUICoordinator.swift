
import SwiftUI

/// A base class for SwiftUI coordinators that provides common functionality
open class SwiftUICoordinator: SwiftUICoordinable {
    public typealias RootView = AnyView
    
    /// The navigation path for this coordinator
    @Published public var path: NavigationPath
    
    /// The currently presented sheet screen
    @Published public var sheetScreen: AnyJumperScreen?
    
    /// The currently presented full screen cover
    @Published public var fullScreenCover: AnyJumperScreen?
    
    /// The parent coordinator if any
    public weak var parent: (any SwiftUICoordinable)?
    
    /// Creates a new coordinator
    /// - Parameter parent: The parent coordinator if any
    public init(parent: (any SwiftUICoordinable)? = nil) {
        self.parent = parent
        self.path = NavigationPath()
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
