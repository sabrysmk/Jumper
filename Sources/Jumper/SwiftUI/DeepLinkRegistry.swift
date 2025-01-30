// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Registry for deep link handlers and screen mappings
///
/// The registry maintains a mapping of URL patterns to screen types and handlers,
/// allowing for dynamic navigation based on deep links.
///
/// - TODO: Future improvements for deep linking:
///   1. Routing improvements:
///      - Support for nested coordinators (tab -> stack -> modal)
///      - Enhanced query parameters handling
///      - URL and parameters validation
///   2. State management:
///      - Full navigation state preservation in URLs
///      - Navigation history restoration from URLs
///      - Error handling during state restoration
///   3. Additional features:
///      - Universal Links support
///      - Deferred deep links (for post-authentication handling)
///      - Deep links analytics
public final class DeepLinkRegistry {
    /// Shared instance of the registry
    public static let shared = DeepLinkRegistry()
    
    /// Registered deep link handlers
    private var handlers: [String: DeepLinkHandler] = [:]
    
    /// Registered URL schemes
    private var schemes: Set<String> = []
    
    /// Registered universal link domains
    private var universalLinkDomains: Set<String> = []
    
    private init() {}
    
    /// Creates a test instance of the registry
    /// - Parameter forTesting: Must be true, ensures this initializer is only used for testing
    /// - Note: This initializer is only available for testing purposes
    internal init(forTesting: Bool) {
        precondition(forTesting, "Use shared instance for production code")
    }
    
    /// Registers a deep link handler for a specific path pattern
    /// - Parameters:
    ///   - pattern: The path pattern to match (e.g., "profile/*")
    ///   - handler: The handler to process matching deep links
    public func register(pattern: String, handler: DeepLinkHandler) {
        handlers[pattern] = handler
    }
    
    /// Registers a URL scheme for the application
    /// - Parameter scheme: The URL scheme to register (e.g., "myapp")
    public func registerScheme(_ scheme: String) {
        schemes.insert(scheme)
    }
    
    /// Registers a domain for universal links
    /// - Parameter domain: The domain to register (e.g., "example.com")
    public func registerUniversalLinkDomain(_ domain: String) {
        universalLinkDomains.insert(domain)
    }
    
    /// Handles a URL by finding and executing the appropriate handler
    /// - Parameter url: The URL to handle
    /// - Returns: True if the URL was handled, false otherwise
    @discardableResult
    public func handle(url: URL) -> Bool {
        // Validate URL scheme or universal link domain
        guard isValidURL(url) else { return false }
        
        // Create deep link from URL
        let deepLink = JumperDeepLink(url: url)
        
        // Find matching handler
        for (pattern, handler) in handlers {
            if matches(path: deepLink.components.joined(separator: "/"), pattern: pattern) {
                return handler.handle(deepLink: deepLink)
            }
        }
        
        return false
    }
    
    /// Checks if a URL matches registered schemes or universal link domains
    /// - Parameter url: The URL to validate
    /// - Returns: True if the URL is valid for this application
    private func isValidURL(_ url: URL) -> Bool {
        if let scheme = url.scheme {
            return schemes.contains(scheme)
        }
        
        if let host = url.host {
            return universalLinkDomains.contains(host)
        }
        
        return false
    }
    
    /// Checks if a path matches a pattern
    /// - Parameters:
    ///   - path: The path to check
    ///   - pattern: The pattern to match against
    /// - Returns: True if the path matches the pattern
    private func matches(path: String, pattern: String) -> Bool {
        let pathComponents = path.split(separator: "/")
        let patternComponents = pattern.split(separator: "/")
        
        guard pathComponents.count == patternComponents.count else { return false }
        
        for (path, pattern) in zip(pathComponents, patternComponents) {
            if pattern == "*" { continue }
            if path != pattern { return false }
        }
        
        return true
    }
}

// MARK: - Pattern Building

@resultBuilder
public struct PatternBuilder {
    /// A component in a deep link pattern
    public struct Component {
        let value: String
        
        public static func fixed(_ value: String) -> Component {
            Component(value: value)
        }
        
        public static var wildcard: Component {
            Component(value: "*")
        }
    }
    
    public static func buildBlock(_ components: Component...) -> String {
        components.map(\.value).joined(separator: "/")
    }
    
    public static func buildExpression(_ expression: String) -> Component {
        .fixed(expression)
    }
    
    public static func buildExpression(_ component: Component) -> Component {
        component
    }
    
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? .wildcard
    }
    
    public static func buildEither(first component: Component) -> Component {
        component
    }
    
    public static func buildEither(second component: Component) -> Component {
        component
    }
    
    public static func buildArray(_ components: [Component]) -> Component {
        .fixed(components.map(\.value).joined(separator: "/"))
    }
} 

