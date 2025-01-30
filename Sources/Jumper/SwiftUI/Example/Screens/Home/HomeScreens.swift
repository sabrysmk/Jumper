// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct PostDetailsScreen: JumperScreen {
    let id = UUID()
    let postId: String
    
    func makeView() -> some View {
        PostDetailsView(postId: postId)
    }
}

struct UserProfileScreen: JumperScreen {
    let id = UUID()
    let userId: String
    
    func makeView() -> some View {
        UserProfileView(userId: userId)
    }
} 