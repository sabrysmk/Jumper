// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// A coordinator that manages modal presentations with advanced features
///
/// `ModalCoordinator` provides sophisticated modal presentation capabilities with
/// support for different presentation styles, transitions, and a modal stack.
///
/// Example of basic usage:
/// ```swift
/// class AuthCoordinator: ModalCoordinator {
///     func showLogin() {
///         present(LoginScreen(), style: .sheet)
///     }
///     
///     func showTerms() {
///         present(TermsScreen(),
///                style: .popup,
///                transition: .fade,
///                dismissible: true)
///     }
///     
///     func showOnboarding() {
///         present(OnboardingScreen(),
///                style: .fullScreen,
///                transition: .slide(.bottom),
///                dismissible: false)
///     }
/// }
/// ```
///
/// Example with nested modals:
/// ```swift
/// class CheckoutCoordinator: ModalCoordinator {
///     func startCheckout() {
///         // Show main checkout screen
///         present(CheckoutScreen(), style: .sheet)
///         
///         // Show address selection on top
///         present(AddressScreen(), style: .popup)
///         
///         // Show payment selection after address
///         present(PaymentScreen(), style: .popup)
///     }
///     
///     func completeCheckout() {
///         // Dismiss all modals at once
///         dismissAll()
///     }
/// }
/// ```
///
/// Example with custom transitions:
/// ```swift
/// class TutorialCoordinator: ModalCoordinator {
///     func showTutorial() {
///         present(TutorialScreen(),
///                style: .popup,
///                transition: .custom(
///                    AnyTransition
///                        .scale(scale: 0.8)
///                        .combined(with: .opacity)
///                ),
///                dismissible: true)
///     }
/// }
open class ModalCoordinator: SwiftUICoordinator {
    /// Stack of modal screens
    @Published private(set) var modalStack: [ModalScreen] = []
    
    /// The currently visible modal screen
    public var currentModal: ModalScreen? {
        modalStack.last
    }
    
    /// Presents a screen modally
    /// - Parameters:
    ///   - screen: The screen to present
    ///   - style: The presentation style
    ///   - transition: The transition animation
    ///   - dismissible: Whether the modal can be dismissed by the user
    public func present<S: JumperScreen>(
        _ screen: S,
        style: ModalStyle = .sheet,
        transition: ModalTransition = .default,
        dismissible: Bool = true
    ) {
        let modalScreen = ModalScreen(
            screen: AnyJumperScreen(screen),
            style: style,
            transition: transition,
            dismissible: dismissible
        )
        modalStack.append(modalScreen)
    }
    
    /// Dismisses the current modal screen
    public override func dismiss() {
        guard !modalStack.isEmpty else { return }
        modalStack.removeLast()
    }
    
    /// Dismisses all modal screens
    public func dismissAll() {
        modalStack.removeAll()
    }
    
    /// Dismisses modal screens until a specific screen
    /// - Parameter screen: The screen to dismiss to
    public func dismissTo<S: JumperScreen>(_ screen: S) {
        guard let index = modalStack.firstIndex(where: { $0.screen.id == AnyHashable(screen.id) }) else { return }
        modalStack.removeSubrange((index + 1)...)
    }
    
    /// Creates and returns the root view for this coordinator
    public override func makeRootView() -> AnyView {
        AnyView(
            ModalCoordinatorView(coordinator: self)
        )
    }
}

/// Style of modal presentation
public enum ModalStyle: Equatable {
    /// Present as a sheet from the bottom
    case sheet
    /// Present as a full screen cover
    case fullScreen
    /// Present in a popup window
    case popup
}

/// Transition animation for modal presentation
public enum ModalTransition: Equatable {
    /// Default system transition
    case `default`
    /// Fade transition
    case fade
    /// Slide from direction
    case slide(Edge)
    /// Scale effect
    case scale
    /// Custom transition
    case custom(AnyTransition)
    
    public static func == (lhs: ModalTransition, rhs: ModalTransition) -> Bool {
        switch (lhs, rhs) {
        case (.default, .default),
             (.fade, .fade),
             (.scale, .scale):
            return true
        case let (.slide(edge1), .slide(edge2)):
            return edge1 == edge2
        case (.custom(_), .custom(_)):
            return true // Can't compare AnyTransition, assume equal
        default:
            return false
        }
    }
}

/// Represents a modal screen with its presentation properties
public struct ModalScreen: Identifiable, Equatable {
    public let id = UUID()
    public let screen: AnyJumperScreen
    public let style: ModalStyle
    public let transition: ModalTransition
    public let dismissible: Bool
    
    public static func == (lhs: ModalScreen, rhs: ModalScreen) -> Bool {
        lhs.id == rhs.id
    }
}

/// Internal view for ModalCoordinator to handle the actual modal presentations
private struct ModalCoordinatorView: View {
    @ObservedObject var coordinator: ModalCoordinator
    
    var body: some View {
        coordinator.makeRootView()
            .modifier(ModalStackModifier(stack: coordinator.modalStack) {
                coordinator.dismiss()
            })
    }
}

/// Modifier to handle the stack of modal presentations
private struct ModalStackModifier: ViewModifier {
    let stack: [ModalScreen]
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content.modifier(
            ModalPresenterModifier(
                stack: stack,
                onDismiss: onDismiss
            )
        )
    }
}

/// Modifier to present modal screens
private struct ModalPresenterModifier: ViewModifier {
    let stack: [ModalScreen]
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content
            .modifier(SheetPresenterModifier(stack: stack.filter { $0.style == .sheet }, onDismiss: onDismiss))
            .modifier(FullScreenPresenterModifier(stack: stack.filter { $0.style == .fullScreen }, onDismiss: onDismiss))
            .modifier(PopupPresenterModifier(stack: stack.filter { $0.style == .popup }, onDismiss: onDismiss))
    }
}

/// Modifier to present sheet modals
private struct SheetPresenterModifier: ViewModifier {
    let stack: [ModalScreen]
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content.sheet(item: Binding(
            get: { stack.last },
            set: { _ in onDismiss() }
        )) { modal in
            modal.screen.makeView()
                .transition(transition(for: modal.transition))
                .interactiveDismissDisabled(!modal.dismissible)
        }
    }
    
    private func transition(for modalTransition: ModalTransition) -> AnyTransition {
        switch modalTransition {
        case .default:
            return .opacity.combined(with: .scale)
        case .fade:
            return .opacity
        case .slide(let edge):
            return .move(edge: edge)
        case .scale:
            return .scale
        case .custom(let transition):
            return transition
        }
    }
}

/// Modifier to present full screen modals
private struct FullScreenPresenterModifier: ViewModifier {
    let stack: [ModalScreen]
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        content.fullScreenCover(item: Binding(
            get: { stack.last },
            set: { _ in onDismiss() }
        )) { modal in
            modal.screen.makeView()
                .transition(transition(for: modal.transition))
                .interactiveDismissDisabled(!modal.dismissible)
        }
    }
    
    private func transition(for modalTransition: ModalTransition) -> AnyTransition {
        switch modalTransition {
        case .default:
            return .opacity.combined(with: .scale)
        case .fade:
            return .opacity
        case .slide(let edge):
            return .move(edge: edge)
        case .scale:
            return .scale
        case .custom(let transition):
            return transition
        }
    }
}

/// Modifier to present popup modals
private struct PopupPresenterModifier: ViewModifier {
    let stack: [ModalScreen]
    let onDismiss: () -> Void
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            ForEach(stack) { modal in
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if modal.dismissible {
                            onDismiss()
                        }
                    }
                
                modal.screen.makeView()
                    .transition(transition(for: modal.transition))
                    .zIndex(1)
            }
        }
    }
    
    private func transition(for modalTransition: ModalTransition) -> AnyTransition {
        switch modalTransition {
        case .default:
            return .opacity.combined(with: .scale)
        case .fade:
            return .opacity
        case .slide(let edge):
            return .move(edge: edge)
        case .scale:
            return .scale
        case .custom(let transition):
            return transition
        }
    }
} 
