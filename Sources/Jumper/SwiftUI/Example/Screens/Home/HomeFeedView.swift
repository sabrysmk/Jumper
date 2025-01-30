// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct HomeFeedView: View {
    let onPostTap: (String) -> Void
    let onUserTap: (String) -> Void
    
    var body: some View {
        List {
            ForEach(1...5, id: \.self) { index in
                VStack(alignment: .leading) {
                    Button("View Post #\(index)") {
                        onPostTap("post_\(index)")
                    }
                    Button("View Author") {
                        onUserTap("user_\(index)")
                    }
                }
            }
        }
        .navigationTitle("Home Feed")
    }
} 