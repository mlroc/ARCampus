//
//  DetailView.swift
//  ARCampus
//
//  Created by Michael Liu on 12/4/24.
//

import SwiftUI

struct DetailView: View {
    var detailText: String
    
    var body: some View {
        VStack {
            Text("Detailed Information")
                .font(.headline)
                
            Text(detailText)
                .font(.body)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        }
        .navigationTitle("Detail")
    }
}
