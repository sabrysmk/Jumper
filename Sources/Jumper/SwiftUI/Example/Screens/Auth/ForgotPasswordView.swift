// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct ForgotPasswordView: View {
    let onClose: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Reset Password")
                    .font(.title2)
                // Add form fields here
            }
            .padding()
            .navigationBarItems(trailing: Button("Close", action: onClose))
        }
    }
} 