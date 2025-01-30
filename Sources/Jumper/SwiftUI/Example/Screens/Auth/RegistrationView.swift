// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct RegistrationView: View {
    let onClose: () -> Void
    let onTermsTap: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Create Account")
                    .font(.title2)
                // Add registration form here
                
                Button("Terms & Conditions") {
                    onTermsTap()
                }
            }
            .padding()
            .navigationBarItems(trailing: Button("Close", action: onClose))
        }
    }
} 