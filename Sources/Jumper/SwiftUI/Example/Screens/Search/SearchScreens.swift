// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct SearchScreen: JumperScreen {
    let id = UUID()
    let onResultTap: (String) -> Void
    
    func makeView() -> some View {
        SearchView(onResultTap: onResultTap)
    }
}

struct SearchResultScreen: JumperScreen {
    let id = UUID()
    let resultId: String
    
    func makeView() -> some View {
        SearchResultView(resultId: resultId)
    }
} 