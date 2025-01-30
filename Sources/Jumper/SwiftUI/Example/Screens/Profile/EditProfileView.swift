// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct EditProfileView: View {
    @State private var name = "John Doe"
    @State private var email = "john@example.com"
    let onSave: () -> Void
    
    var body: some View {
        Form {
            Section {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
            }
            
            Section {
                Button("Save Changes") {
                    onSave()
                }
            }
        }
        .navigationTitle("Edit Profile")
    }
} 