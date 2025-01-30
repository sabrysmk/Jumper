// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct SettingsView: View {
    let onLogout: () -> Void
    
    var body: some View {
        List {
            Section {
                Toggle("Push Notifications", isOn: .constant(true))
                Toggle("Email Notifications", isOn: .constant(false))
            }
            
            Section {
                Button("Logout", role: .destructive) {
                    onLogout()
                }
            }
        }
        .navigationTitle("Settings")
    }
} 