// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Coordinator that manages authentication flow using modal presentations
/// Features:
/// - Modal presentations
/// - Sheets and full-screen covers
/// - Authentication state management
final class AuthCoordinator: ModalCoordinator {
    
    // MARK: - Public Properties
    
    var onAuthenticated: () -> Void = {}
    
    // MARK: - Private Properties
    
    private enum Sheet: Identifiable {
        case forgotPassword
        case registration
        case termsAndConditions
        
        var id: String {
            switch self {
            case .forgotPassword: return "forgotPassword"
            case .registration: return "registration"
            case .termsAndConditions: return "terms"
            }
        }
    }
    
    // MARK: - Root View
    
    override func makeRootView() -> AnyView {
        AnyView(LoginView(
            onLoginTap: { [weak self] in
                self?.onAuthenticated()
            },
            onForgotPasswordTap: { [weak self] in
                self?.presentSheet(.forgotPassword)
            },
            onRegisterTap: { [weak self] in
                self?.presentSheet(.registration)
            }
        ))
    }
    
    // MARK: - Navigation
    
    private func presentSheet(_ sheet: Sheet) {
        switch sheet {
        case .forgotPassword:
            let screen = ForgotPasswordScreen(onSendEmail: { [weak self] in
                self?.dismiss()
            })
            present(screen)
            
        case .registration:
            let screen = RegistrationScreen(
                onClose: { [weak self] in
                    self?.dismiss()
                },
                onTermsTap: { [weak self] in
                    self?.presentSheet(.termsAndConditions)
                }
            )
            present(screen)
            
        case .termsAndConditions:
            let screen = TermsScreen(onClose: { [weak self] in
                self?.dismiss()
            })
            present(screen)
        }
    }
}



