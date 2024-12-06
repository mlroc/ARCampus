//
//  HistoryViewController.swift
//  ARCampus
//
//  Created by Michael Liu on 12/4/24.
//

import SwiftUI

struct HistoryViewController: View {
    var scannedHistory: [(name: String, date: Date, detailText: String)]
    
    var body: some View {
        VStack(spacing: 8){
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.gray.opacity(0.5))
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            NavigationView {
                List(scannedHistory, id: \.date) { item in
                    NavigationLink(destination: DetailView(detailText: item.detailText)){
                        VStack(alignment: .leading) {
                            Text(item.name)
                                .font(.headline)
                            Text("Scanned: \(item.date, formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .navigationTitle("History")
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
}
