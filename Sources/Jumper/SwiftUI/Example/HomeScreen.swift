// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

public struct HomeScreen: JumperScreen {
    public let id = UUID()
    private let onLogout: () -> Void
    
    public init(onLogout: @escaping () -> Void) {
        self.onLogout = onLogout
    }
    
    public func makeView() -> some View {
        VStack(spacing: 20) {
            Text("Home Screen")
                .font(.title)
            
            Button("Logout") {
                onLogout()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
} 