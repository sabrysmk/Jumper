// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct LoginView: View {
    let onLoginTap: () -> Void
    let onForgotPasswordTap: () -> Void
    let onRegisterTap: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome Back")
                .font(.title)
            
            Button("Login") {
                onLoginTap()
            }
            .buttonStyle(.borderedProminent)
            
            Button("Forgot Password?") {
                onForgotPasswordTap()
            }
            
            Button("Create Account") {
                onRegisterTap()
            }
        }
        .padding()
    }
} 