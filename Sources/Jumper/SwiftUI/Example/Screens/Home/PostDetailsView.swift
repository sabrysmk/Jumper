// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct PostDetailsView: View {
    let postId: String
    
    var body: some View {
        Text("Details for post: \(postId)")
            .navigationTitle("Post Details")
    }
} 