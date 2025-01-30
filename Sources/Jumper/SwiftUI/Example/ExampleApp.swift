// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Main application entry point that demonstrates the Jumper navigation framework
/// This example shows how to:
/// - Set up tab-based navigation
/// - Handle authentication flow
/// - Implement deep linking
/// - Manage application state
public struct ExampleApp: View {
    @StateObject private var coordinator = MainCoordinator()
    
    public init() {}
    
    public var body: some View {
        coordinator.makeRootView()
            .withCoordinator(coordinator)
    }
}

#Preview {
    ExampleApp()
} 