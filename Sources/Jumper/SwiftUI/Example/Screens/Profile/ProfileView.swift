// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct ProfileView: View {
    let onSettingsTap: () -> Void
    let onEditTap: () -> Void
    
    var body: some View {
        List {
            Section {
                Text("John Doe")
                    .font(.title2)
                Text("john@example.com")
                    .foregroundColor(.secondary)
            }
            
            Section {
                Button("Edit Profile") {
                    onEditTap()
                }
                
                Button("Settings") {
                    onSettingsTap()
                }
            }
        }
        .navigationTitle("Profile")
    }
} 