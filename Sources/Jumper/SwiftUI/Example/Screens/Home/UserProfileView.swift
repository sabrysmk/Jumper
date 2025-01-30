// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct UserProfileView: View {
    let userId: String
    
    var body: some View {
        Text("Profile for user: \(userId)")
            .navigationTitle("User Profile")
    }
} 