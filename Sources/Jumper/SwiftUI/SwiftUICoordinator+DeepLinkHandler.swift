// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

extension SwiftUICoordinator: DeepLinkHandler {
    /// Creates a screen from a deep link if possible
    /// This method should be implemented by concrete coordinator subclasses
    /// - Parameter deepLink: The deep link to create a screen from
    /// - Returns: A screen instance if the deep link can be handled, nil otherwise
    public func createScreen(from deepLink: JumperDeepLink) -> (any JumperScreen)? {
        // This should be implemented by concrete coordinator subclasses
        return nil
    }
    
    /// Presents a screen in response to a deep link
    /// - Parameter screen: The screen to present
    private func present(_ screen: any JumperScreen) {
        switch screen.presentationStyle {
        case .automatic:
            // For automatic, we default to push if in a navigation context,
            // otherwise present as a sheet
            if !path.isEmpty {
                path.append(AnyJumperScreen(screen))
            } else {
                sheetScreen = AnyJumperScreen(screen)
            }
        case .push:
            path.append(AnyJumperScreen(screen))
        case .sheet:
            sheetScreen = AnyJumperScreen(screen)
        case .fullScreen:
            fullScreenCover = AnyJumperScreen(screen)
        case .modal:
            sheetScreen = AnyJumperScreen(screen)
        }
    }
} 