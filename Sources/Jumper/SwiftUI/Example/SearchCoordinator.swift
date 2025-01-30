// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

/// Coordinator that manages search flow
/// Features:
/// - Search results navigation
/// - Result details
final class SearchCoordinator: StackCoordinator {
    override func makeRootView() -> AnyView {
        AnyView(
            SearchScreen(
                onResultTap: { [weak self] resultId in
                    self?.push(SearchResultScreen(resultId: resultId))
                }
            ).makeView()
        )
    }
} 