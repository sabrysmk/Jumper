// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct TermsView: View {
    let onClose: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text("Terms and Conditions")
                    .font(.title2)
                Text("Long terms text goes here...")
            }
            .padding()
            .navigationBarItems(trailing: Button("Close", action: onClose))
        }
    }
} 