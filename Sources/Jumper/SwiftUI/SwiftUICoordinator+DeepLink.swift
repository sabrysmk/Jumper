// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

extension SwiftUICoordinator {
    /// Registers this coordinator as a deep link handler
    /// - Parameters:
    ///   - pattern: The pattern to match
    ///   - registry: The registry to register with (defaults to shared)
    public func registerDeepLinkHandler(
        pattern: String,
        in registry: DeepLinkRegistry = .shared
    ) {
        registry.register(pattern: pattern, handler: self)
    }
    
    /// Registers multiple deep link patterns for this coordinator
    /// - Parameters:
    ///   - patterns: The patterns to match
    ///   - registry: The registry to register with (defaults to shared)
    public func registerDeepLinkHandlers(
        patterns: [String],
        in registry: DeepLinkRegistry = .shared
    ) {
        patterns.forEach { pattern in
            registerDeepLinkHandler(pattern: pattern, in: registry)
        }
    }
    
    /// Registers deep link patterns using the pattern builder
    /// - Parameters:
    ///   - pattern: The pattern builder closure
    ///   - registry: The registry to register with (defaults to shared)
    public func registerDeepLinkHandler(
        @PatternBuilder pattern: () -> String,
        in registry: DeepLinkRegistry = .shared
    ) {
        let patternString = pattern()
        registerDeepLinkHandler(pattern: patternString, in: registry)
    }
}

// MARK: - Convenience Methods

extension SwiftUICoordinator {
    /// Creates a deep link URL for this coordinator
    /// - Parameters:
    ///   - path: The path components
    ///   - parameters: Additional URL parameters
    ///   - scheme: The URL scheme to use
    /// - Returns: A URL representing the deep link
    public func createDeepLink(
        path: [String],
        parameters: [String: String] = [:],
        scheme: String
    ) -> URL? {
        var components = URLComponents()
        components.scheme = scheme
        components.path = "/" + path.joined(separator: "/")
        
        if !parameters.isEmpty {
            components.queryItems = parameters.map { key, value in
                URLQueryItem(name: key, value: value)
            }
        }
        
        return components.url
    }
    
    /// Opens a deep link URL
    /// - Parameter url: The URL to open
    /// - Returns: True if the URL was handled successfully
    @discardableResult
    public func openDeepLink(_ url: URL) -> Bool {
        DeepLinkRegistry.shared.handle(url: url)
    }
} 