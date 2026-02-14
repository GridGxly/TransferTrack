import SwiftUI
import VisionKit

@available(iOS 17.0, *)
struct TranscriptScannerSheet: View {
    let onCodeFound: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var scannedCodes: [String] = []
    @State private var isSupported = DataScannerViewController.isSupported
    @State private var isAvailable = DataScannerViewController.isAvailable

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if isSupported && isAvailable {
                    TranscriptDataScanner(scannedCodes: $scannedCodes)
                        .ignoresSafeArea(edges: .bottom)
                } else {
                    ContentUnavailableView(
                        "Camera Not Available",
                        systemImage: "camera.fill",
                        description: Text("This device doesn't support text scanning. Add courses manually instead.")
                    )
                }

                if !scannedCodes.isEmpty {
                    VStack(spacing: 8) {
                        Text("Detected Course Codes").font(.subheadline.weight(.semibold))
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 8) {
                                ForEach(scannedCodes, id: \.self) { code in
                                    HStack(spacing: 6) {
                                       
                                        Button {
                                            onCodeFound(code)
                                            scannedCodes.removeAll { $0 == code }
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "plus.circle.fill").font(.caption)
                                                Text(code).font(.subheadline.weight(.medium))
                                            }
                                        }

                                        Button {
                                            withAnimation(.spring(response: 0.25)) {
                                                scannedCodes.removeAll { $0 == code }
                                            }
                                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                        } label: {
                                            Image(systemName: "xmark.circle.fill")
                                                .font(.caption)
                                                .foregroundStyle(.white.opacity(0.7))
                                        }
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(Color.blue)
                                    .foregroundStyle(.white)
                                    .clipShape(Capsule())
                                    .transition(.scale.combined(with: .opacity))
                                }
                            }
                            .padding(.horizontal, 16)
                        }
                        Text("Tap code to add · ✕ to dismiss").font(.caption).foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 12)
                    .background(.regularMaterial)
                }
            }
            .navigationTitle("Scan Transcript")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

@available(iOS 17.0, *)
struct TranscriptDataScanner: UIViewControllerRepresentable {
    @Binding var scannedCodes: [String]

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.text()],
            qualityLevel: .balanced,
            recognizesMultipleItems: true,
            isHighFrameRateTrackingEnabled: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        try? uiViewController.startScanning()
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        let parent: TranscriptDataScanner
        private let courseCodePattern = /[A-Z]{2,4}\s?\d{4}[A-Z]?/

        init(parent: TranscriptDataScanner) {
            self.parent = parent
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            if case .text(let text) = item {
                let content = text.transcript
                let matches = content.matches(of: courseCodePattern)
                for match in matches {
                    let code = String(match.output).trimmingCharacters(in: .whitespaces)
                    let normalized = normalizeCode(code)
                    if !parent.scannedCodes.contains(normalized) {
                        DispatchQueue.main.async {
                            self.parent.scannedCodes.append(normalized)
                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                        }
                    }
                }
            }
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addedItems {
                if case .text(let text) = item {
                    let content = text.transcript
                    let matches = content.matches(of: courseCodePattern)
                    for match in matches {
                        let code = String(match.output).trimmingCharacters(in: .whitespaces)
                        let normalized = normalizeCode(code)
                        if !parent.scannedCodes.contains(normalized) {
                            DispatchQueue.main.async {
                                self.parent.scannedCodes.append(normalized)
                            }
                        }
                    }
                }
            }
        }

        private func normalizeCode(_ raw: String) -> String {
            let cleaned = raw.uppercased().trimmingCharacters(in: .whitespaces)
            if cleaned.contains(" ") { return cleaned }
            let letters = cleaned.prefix(while: \.isLetter)
            let rest = cleaned.dropFirst(letters.count)
            if !letters.isEmpty && !rest.isEmpty {
                return "\(letters) \(rest)"
            }
            return cleaned
        }
    }
}
