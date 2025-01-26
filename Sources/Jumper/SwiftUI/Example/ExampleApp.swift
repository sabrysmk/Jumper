// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

public struct ExampleApp: View {
    @StateObject private var coordinator = AuthCoordinator()
    
    public init() {}
    
    public var body: some View {
        coordinator.makeRootView()
            .withCoordinator(coordinator)
    }
}

#Preview {
    ExampleApp()
} 