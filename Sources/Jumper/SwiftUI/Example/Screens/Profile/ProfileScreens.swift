// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct ProfileScreen: JumperScreen {
    let id = UUID()
    let onSettingsTap: () -> Void
    let onEditTap: () -> Void
    
    func makeView() -> some View {
        ProfileView(
            onSettingsTap: onSettingsTap,
            onEditTap: onEditTap
        )
    }
}

struct SettingsScreen: JumperScreen {
    let id = UUID()
    let onLogout: () -> Void
    
    func makeView() -> some View {
        SettingsView(onLogout: onLogout)
    }
}

struct EditProfileScreen: JumperScreen {
    let id = UUID()
    let onSave: () -> Void
    
    func makeView() -> some View {
        EditProfileView(onSave: onSave)
    }
} 