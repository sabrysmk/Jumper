// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

public struct LoginScreen: JumperScreen {
    public let id = UUID()
    private let onLogin: () -> Void
    private let onForgotPassword: () -> Void
    
    public init(
        onLogin: @escaping () -> Void,
        onForgotPassword: @escaping () -> Void
    ) {
        self.onLogin = onLogin
        self.onForgotPassword = onForgotPassword
    }
    
    public func makeView() -> some View {
        VStack(spacing: 20) {
            Text("Login Screen")
                .font(.title)
            
            Button("Login") {
                onLogin()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Forgot Password") {
                onForgotPassword()
            }
        }
        .padding()
    }
} 