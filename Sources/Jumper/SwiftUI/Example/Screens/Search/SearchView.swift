// Copyright (c) 2024 iDevs.io. All rights reserved.

import SwiftUI

struct SearchView: View {
    @State private var searchText = ""
    let onResultTap: (String) -> Void
    
    var body: some View {
        List {
            TextField("Search", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.vertical, 8)
            
            if !searchText.isEmpty {
                ForEach(1...3, id: \.self) { index in
                    Button("Search Result #\(index)") {
                        onResultTap("result_\(index)")
                    }
                }
            }
        }
        .navigationTitle("Search")
    }
} 