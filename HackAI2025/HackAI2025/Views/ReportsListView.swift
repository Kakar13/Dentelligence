//
//  ReportsListView.swift
//  HackAI2025
//
//  Created by Vikas Kakar on 2/23/25.
//

import SwiftUI
import SwiftData

struct ReportsListView: View {
    @Query private var patients: [Patient]
    @State private var selectedTreatment: Treatment?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        List {
            ForEach(patients) { patient in
                Section {
                    ForEach(patient.treatments) { treatment in
                        NavigationLink {
                            TreatmentDetailView(treatment: treatment)
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(treatment.name)
                                    .font(.headline)
                                
                                Text(dateFormatter.string(from: treatment.date))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                } header: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(patient.name)
                            .font(.headline)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Reports")
    }
}
