// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Coordinator that manages profile flow
/// Features:
/// - Profile settings
/// - Profile editing
/// - Logout handling
final class ProfileCoordinator: StackCoordinator {
    var onLogout: () -> Void = {}
    
    override func makeRootView() -> AnyView {
        AnyView(
            ProfileScreen(
                onSettingsTap: { [weak self] in
                    self?.showSettings()
                },
                onEditTap: { [weak self] in
                    self?.showEditProfile()
                }
            ).makeView()
        )
    }
    
    private func showSettings() {
        push(SettingsScreen(onLogout: { [weak self] in
            self?.onLogout()
        }))
    }
    
    private func showEditProfile() {
        push(EditProfileScreen(onSave: { [weak self] in
            self?.pop()
        }))
    }
} 