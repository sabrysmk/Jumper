// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct SearchResultView: View {
    let resultId: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Search Result Details")
                .font(.title)
            Text("Result ID: \(resultId)")
        }
        .navigationTitle("Result Details")
    }
} 