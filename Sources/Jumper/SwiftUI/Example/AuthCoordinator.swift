// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

public class AuthCoordinator: SwiftUICoordinator {
    @Published private var isAuthenticated = false
    
    public override func makeRootView() -> AnyView {
        AnyView(
            Group {
                if isAuthenticated {
                    HomeScreen(onLogout: { [weak self] in
                        self?.isAuthenticated = false
                    }).makeView()
                } else {
                    LoginScreen(
                        onLogin: { [weak self] in
                            self?.isAuthenticated = true
                        },
                        onForgotPassword: { [weak self] in
                            self?.showForgotPassword()
                        }
                    ).makeView()
                }
            }
        )
    }
    
    private func showForgotPassword() {
        let screen = ForgotPasswordScreen { [weak self] in
            self?.dismiss()
        }
        present(screen)
    }
} 
