// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct ForgotPasswordScreen: JumperScreen {
    let id = UUID()
    let onSendEmail: () -> Void
    
    func makeView() -> some View {
        ForgotPasswordView(onClose: onSendEmail)
    }
}

struct RegistrationScreen: JumperScreen {
    let id = UUID()
    let onClose: () -> Void
    let onTermsTap: () -> Void
    
    func makeView() -> some View {
        RegistrationView(
            onClose: onClose,
            onTermsTap: onTermsTap
        )
    }
}

struct TermsScreen: JumperScreen {
    let id = UUID()
    let onClose: () -> Void
    
    func makeView() -> some View {
        TermsView(onClose: onClose)
    }
} 