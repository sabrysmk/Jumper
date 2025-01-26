// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

public struct ForgotPasswordScreen: JumperScreen {
    public let id = UUID()
    private let onSendEmail: () -> Void
    
    public init(onSendEmail: @escaping () -> Void) {
        self.onSendEmail = onSendEmail
    }
    
    public var presentationStyle: JumperPresentationStyle {
        .sheet
    }
    
    public func makeView() -> some View {
        VStack(spacing: 20) {
            Text("Forgot Password")
                .font(.title)
            
            Button("Send Reset Email") {
                onSendEmail()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
} 