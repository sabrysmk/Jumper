// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Represents a deep link in the application
public struct JumperDeepLink: Hashable {
    /// The path components of the deep link
    public let components: [String]
    /// Additional parameters for the deep link
    public let parameters: [String: String]
    
    public init(url: URL) {
        let components = url.pathComponents.filter { $0 != "/" }
        var parameters: [String: String] = [:]
        
        if let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems {
            for item in queryItems {
                if let value = item.value {
                    parameters[item.name] = value
                }
            }
        }
        
        self.components = components
        self.parameters = parameters
    }
    
    public init(components: [String], parameters: [String: String] = [:]) {
        self.components = components
        self.parameters = parameters
    }
}

/// Protocol for screens that can be created from a deep link
public protocol DeepLinkable {
    /// Creates a screen instance from a deep link if possible
    /// - Parameter deepLink: The deep link to create the screen from
    /// - Returns: A screen instance if the deep link can be handled, nil otherwise
    static func create(from deepLink: JumperDeepLink) -> Self?
}

/// Protocol for coordinators that can handle deep links
public protocol DeepLinkHandler {
    /// Creates a screen from a deep link if possible
    /// - Parameter deepLink: The deep link to create a screen from
    /// - Returns: A screen instance if the deep link can be handled, nil otherwise
    func createScreen(from deepLink: JumperDeepLink) -> (any JumperScreen)?
    
    /// Handles a deep link
    /// - Parameter deepLink: The deep link to handle
    /// - Returns: True if the deep link was handled, false otherwise
    func handle(deepLink: JumperDeepLink) -> Bool
}

extension DeepLinkHandler where Self: SwiftUICoordinator {
    public func handle(deepLink: JumperDeepLink) -> Bool {
        // Reset navigation if needed
        path.removeLast(path.count)
        sheetScreen = nil
        fullScreenCover = nil
        
        // Try to create screens from deep link components
        var currentComponents = [String]()
        var handled = false
        
        for component in deepLink.components {
            currentComponents.append(component)
            let currentDeepLink = JumperDeepLink(
                components: currentComponents,
                parameters: deepLink.parameters
            )
            
            if let screen = createScreen(from: currentDeepLink) {
                switch screen.presentationStyle {
                case .automatic:
                    // For automatic, we default to push if in a navigation context,
                    // otherwise present as a sheet
                    if !path.isEmpty {
                        path.append(AnyJumperScreen(screen))
                    } else {
                        sheetScreen = AnyJumperScreen(screen)
                    }
                case .push:
                    path.append(AnyJumperScreen(screen))
                case .sheet:
                    sheetScreen = AnyJumperScreen(screen)
                case .fullScreen:
                    fullScreenCover = AnyJumperScreen(screen)
                case .modal:
                    sheetScreen = AnyJumperScreen(screen)
                }
                handled = true
            }
        }
        
        return handled
    }
} 