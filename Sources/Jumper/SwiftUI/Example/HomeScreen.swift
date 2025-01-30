// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Home screen that demonstrates stack-based navigation
/// Features:
/// - Push/pop navigation
/// - Nested navigation stack
/// - Deep linking support
struct HomeScreen: JumperScreen {
    let id = UUID()
    let onPostTap: (String) -> Void
    let onUserTap: (String) -> Void
    
    func makeView() -> some View {
        HomeFeedView(
            onPostTap: onPostTap,
            onUserTap: onUserTap
        )
    }
}

/// Coordinator that manages navigation within the Home tab
final class HomeCoordinator: StackCoordinator {
    override func makeRootView() -> AnyView {
        AnyView(
            HomeScreen(
                onPostTap: { [weak self] postId in
                    self?.push(PostDetailsScreen(postId: postId))
                },
                onUserTap: { [weak self] userId in
                    self?.push(UserProfileScreen(userId: userId))
                }
            ).makeView()
        )
    }
}

