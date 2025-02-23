import SwiftData
import Foundation
import SwiftUI
import SwiftWhisper
import AudioKit

struct HomeView: View {
    var patient = Patient(name: "John Doe", dateOfBirth: Date(), gender: "Male", treatments: [])
    var body: some View {
        NavigationStack {
            VStack(spacing: 30) {
                
                // App Title
                Text("Dentology")
                    .font(.largeTitle)
                    .bold()
                
                // Logo Image
                Image("tooth")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 100)
                
                Spacer()
                
                // Navigation Buttons
                VStack(spacing: 15) {
                    NavigationLink(destination: NewReportView(patient: patient)) {
                        Label("New Report", systemImage: "plus.circle.fill")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    
                    NavigationLink(destination: ReportsListView()) {
                        Label("View Reports", systemImage: "list.bullet.clipboard")
                            .font(.title3)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                }
                .padding(.bottom, 30)
            }
            .padding()
        }
    }
}


struct NewReportView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var patientName = ""
    @State private var selectedTreatment = "Root Canal"
    @State private var selectedGender = "Male"
    @State private var dob = Date()
    @State private var navigate = false
    let patient: Patient
    
    let treatments = ["Root Canal", "Cavities", "Orthodontics"]
    let sex = ["Male", "Female"]
    
    var body: some View {
        Form {
            Section("Patient Information") {
                TextField("Patient Name", text: $patientName)
                
                DatePicker("Date of Birth", selection: $dob, displayedComponents: .date)
                    .datePickerStyle(.compact)
                
                Picker("Sex", selection: $selectedGender) {
                    ForEach(sex, id: \.self) { gender in
                        Text(gender).tag(gender)
                    }
                }
                .pickerStyle(.segmented)
            }
            
            Picker("Treatment", selection: $selectedTreatment) {
                ForEach(treatments, id: \.self) { treatment in
                    Text(treatment)
                }
            }
            .pickerStyle(.menu)
            
            Section {
                Button(action: {
                    navigate = true
                }) {
                    Text("Begin")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(patientName.isEmpty ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(patientName.isEmpty)
                .navigationDestination(isPresented: $navigate) {
                    // Create a new patient with the entered information
                    RecordingView(
                        patient: Patient(
                            name: patientName,
                            dateOfBirth: dob,
                            gender: selectedGender
                        ),
                        treatmentName: selectedTreatment
                    )
                }
            }
        }
        .navigationTitle("New Report")
    }
}

struct ReportPreviewView: View {
    let treatment: Treatment
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack {
            if let pdfURL = treatment.pdfURL {
                PDFKitView(url: pdfURL)
            } else {
                Text("Error generating PDF")
                    .foregroundColor(.red)
            }
        }
        .navigationTitle("Report Preview")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    if let pdfURL = treatment.pdfURL {
                        let activityVC = UIActivityViewController(
                            activityItems: [pdfURL],
                            applicationActivities: nil
                        )
                        
                        // Get the window scene for presentation
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first,
                           let rootVC = window.rootViewController {
                            activityVC.popoverPresentationController?.sourceView = rootVC.view
                            rootVC.present(activityVC, animated: true)
                        }
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
    }
}
