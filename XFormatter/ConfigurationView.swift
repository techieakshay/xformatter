//
//  ConfigurationView.swift
//  XFormatter
//
//  Created by Akshay Soni  on 17/10/24.
//
import SwiftUI

struct ConfigurationView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var customFormatOptions: String = ""

    var body: some View {
        VStack {
            Text("Configuration Settings")
                .font(.largeTitle)
                .padding()

            // TextEditor for custom format options
            TextEditor(text: $customFormatOptions)
                .frame(height: 300) // Set height for the text area
                .padding()
                .border(Color.gray, width: 1) // Optional: Add a border for better visibility
                .onAppear {
                    loadCustomOptions() // Load saved options on appear
                }

            Button("Save") {
                saveCustomOptions()
                presentationMode.wrappedValue.dismiss()
            }
            .padding()
        }
        .frame(width: 600) // Set the desired width here
        .padding()
    }

    private func saveCustomOptions() {
        // Write the custom format options to a file in the /tmp directory
        let fileURL = URL(fileURLWithPath: "/tmp/SwiftFormatConfig.txt")
        do {
            try customFormatOptions.write(to: fileURL, atomically: true, encoding: .utf8)
            print("Configuration saved to \(fileURL.path)") // Debugging statement
        } catch {
            print("Failed to write to file: \(error.localizedDescription)")
        }
        UserDefaults.standard.set(customFormatOptions, forKey: "CustomFormatOptions")
    }

    private func loadCustomOptions() {
        if let options = UserDefaults.standard.string(forKey: "CustomFormatOptions") {
            customFormatOptions = options
        }
    }
}
