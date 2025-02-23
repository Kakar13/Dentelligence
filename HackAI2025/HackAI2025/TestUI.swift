////
////  TestUI.swift
////  HackAI2025
////
////  Created by Mihir Joshi on 2/22/25.
////
//
//import SwiftUI
//
//struct TestUI: View {
//    @State var modelResponse: String = ""
//    @State var isLoading: Bool = false
//    @State var dentalProcedure = ProcedureObj(title: "Root Canal", tags: [], transcription: "")
//    
//    // New state variables for form
//    @State private var selectedProcedure = "Root Canal"
//    @State private var newTranscription: String = ""
//    @State private var newTagNote: String = ""
//    
//    // Define procedure options
//    let procedureOptions = ["Root Canal", "Cavities", "Orthodontics"]
//    
//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 20) {
//                // Title Section
//                VStack(alignment: .leading) {
//                    Text("Procedure Type")
//                        .font(.headline)
//                    Picker("Select Procedure", selection: $selectedProcedure) {
//                        ForEach(procedureOptions, id: \.self) { procedure in
//                            Text(procedure).tag(procedure)
//                        }
//                    }
//                    .pickerStyle(.menu)
//                    .onChange(of: selectedProcedure) { _, newValue in
//                        dentalProcedure.title = newValue
//                    }
//                }
//                
//                // Tags Section
//                VStack(alignment: .leading) {
//                    Text("Tags")
//                        .font(.headline)
//                    
//                    HStack {
//                        TextField("Add new tag", text: $newTagNote)
//                            .textFieldStyle(RoundedBorderTextFieldStyle())
//                        
//                        Button(action: {
//                            if !newTagNote.isEmpty {
//                                dentalProcedure.tags.append(TemplateTag(note: newTagNote))
//                                newTagNote = ""
//                            }
//                        }) {
//                            Text("Add Tag")
//                        }
//                    }
//                    
//                    // Display existing tags
//                    FlowLayout(alignment: .leading, spacing: 8) {
//                        ForEach(dentalProcedure.tags) { tag in
//                            TagView(tag: tag, onDelete: {
//                                dentalProcedure.tags.removeAll { $0.id == tag.id }
//                            })
//                        }
//                    }
//                }
//                
//                // Transcription Section
//                VStack(alignment: .leading) {
//                    Text("Transcription")
//                        .font(.headline)
//                    TextEditor(text: $newTranscription)
//                        .frame(height: 150)
//                        .border(Color.gray.opacity(0.2))
//                        .onChange(of: newTranscription) { _, newValue in
//                            dentalProcedure.transcription = newValue
//                        }
//                }
//                
//                // Generate Response Button
//                Button {
//                    generateModelResponse()
//                } label: {
//                    HStack {
//                        Text("Generate Response")
//                        if isLoading {
//                            ProgressView()
//                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
//                        }
//                    }
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                }
//                .disabled(isLoading)
//                
//                if !modelResponse.isEmpty {
//                    Text("Response:")
//                        .font(.headline)
//                    Text(modelResponse)
//                        .padding()
//                        .background(Color.gray.opacity(0.1))
//                        .cornerRadius(8)
//                }
//            }
//            .padding()
//        }
//    }
//    
//    private func generateModelResponse() {
//        isLoading = true
//        modelResponse = ""
//        
//        Task {
//            modelResponse = await fetchResposne(dentalProcedure: dentalProcedure)
//            isLoading = false
//        }
//    }
//}
//
//// Helper view for individual tags
//struct TagView: View {
//    let tag: TemplateTag
//    let onDelete: () -> Void
//    
//    var body: some View {
//        HStack {
//            Text(tag.note)
//                .padding(.horizontal, 8)
//                .padding(.vertical, 4)
//            Button(action: onDelete) {
//                Image(systemName: "xmark.circle.fill")
//                    .foregroundColor(.red)
//            }
//        }
//        .background(Color.gray.opacity(0.2))
//        .cornerRadius(8)
//    }
//}
//
//// Helper view for flowing layout of tags
//struct FlowLayout: Layout {
//    var alignment: HorizontalAlignment = .center
//    var spacing: CGFloat = 8
//    
//    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
//        let result = FlowResult(
//            in: proposal.width ?? 0,
//            subviews: subviews,
//            spacing: spacing
//        )
//        return result.size
//    }
//    
//    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
//        let result = FlowResult(
//            in: bounds.width,
//            subviews: subviews,
//            spacing: spacing
//        )
//        
//        for (index, subview) in subviews.enumerated() {
//            let point = result.points[index]
//            subview.place(at: CGPoint(x: point.x + bounds.minX, y: point.y + bounds.minY), proposal: .unspecified)
//        }
//    }
//    
//    struct FlowResult {
//        var size: CGSize = .zero
//        var points: [CGPoint] = []
//        
//        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
//            var currentX: CGFloat = 0
//            var currentY: CGFloat = 0
//            var lineHeight: CGFloat = 0
//            
//            for subview in subviews {
//                let viewSize = subview.sizeThatFits(.unspecified)
//                
//                if currentX + viewSize.width > maxWidth {
//                    currentX = 0
//                    currentY += lineHeight + spacing
//                    lineHeight = 0
//                }
//                
//                points.append(CGPoint(x: currentX, y: currentY))
//                lineHeight = max(lineHeight, viewSize.height)
//                currentX += viewSize.width + spacing
//                
//                size.width = max(size.width, currentX)
//                size.height = currentY + lineHeight
//            }
//        }
//    }
//}
