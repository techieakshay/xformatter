//
//  ContentView.swift
//  XFormatter
//
//  Created by Akshay Soni  on 17/10/24.
//

import SwiftUI

struct ContentView: View {
    @State private var folderURL: URL? = nil
    @State private var showingFolderPicker = false
    @State private var folderSelected = false
    @State private var showErrorAlert = false
    @State private var output: String = ""
    @State private var errorMessage = ""
    @State private var showConfiguration: Bool = false

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    showConfiguration.toggle()
                }) {
                    Image(systemName: "gearshape.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 30, height: 30)
                        .foregroundColor(.blue)
                }
                .padding()
                .buttonStyle(PlainButtonStyle())
            }

            // Title
            Text("Select a Folder")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 40)

            // Description text
            Text("Choose a folder and click the button to proceed.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .padding(.bottom, 40)

            // Folder Display
            if let folderURL = folderURL {
                Text("Selected Folder: \(folderURL.path)")
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
            } else {
                Text("No Folder Selected")
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                    .padding(.horizontal)
            }

            Spacer() // Creates space between folder display and buttons

            // Folder Picker Button
            Button(action: {
                output = ""
                showingFolderPicker.toggle()
            }) {
                Text("Choose Folder")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(Color.blue)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
            .fileImporter(isPresented: $showingFolderPicker, allowedContentTypes: [.folder]) { result in
                do {
                    let folder = try result.get()
                    folderURL = folder
                    folderSelected = true
                } catch {
                    print("Error selecting folder: \(error.localizedDescription)")
                }
            }

            // Bottom space to push the "Proceed" button down
            Spacer().frame(height: 20)

            // Proceed Button at the Bottom
            Button(action: {
                if let folderPath = folderURL?.path {
                    runSwiftFormatter(at: folderPath)
                }
            }) {
                Text("Proceed")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: 300)
                    .background(folderSelected ? Color.green : Color.gray)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(!folderSelected) // Disable if no folder selected
            .alert(isPresented: $showErrorAlert) {
                Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
            }
            Spacer().frame(height: 20) // Extra padding at the bottom

            // Output display area
            if !output.isEmpty {
                Rectangle()
                    .fill(Color.black)
                    .frame(height: 120)
                    .cornerRadius(8)
                    .padding()
                    .overlay(Text(output) // Display output here
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil))
            }
        }
        .sheet(isPresented: $showConfiguration) {
            ConfigurationView() // Present the configuration view
        }
        .frame(maxHeight: .infinity) // Make sure content is spaced properly
        .padding(.bottom, 20) // Padding for safe area on the bottom
    }

    // Function to check if swiftformat is installed
    func runSwiftFormatter(at folderPath: String) {
        guard let swiftformatPath = findSwiftformat() else {
            errorMessage = "SwiftFormat is not installed. Please install it using 'brew install swiftformat'."
            showErrorAlert = true
            return
        }

        let process = Process()
        let pipe = Pipe()
        // Define the path for the config file in /tmp
        let configFileURL = URL(fileURLWithPath: "/tmp/SwiftFormatConfig.txt")
        // Using /bin/bash to run the command
        process.executableURL = URL(fileURLWithPath: "/bin/bash")
        // Check if the config file exists
        if FileManager.default.fileExists(atPath: configFileURL.path) {
            process.arguments = ["-c", "\(swiftformatPath) \"\(folderPath)\" --config \(configFileURL.path)"]
        } else {
            // If config file does not exist, run SwiftFormat without config
            process.arguments = ["-c", "\(swiftformatPath) \(folderPath)"]
        }
        process.standardOutput = pipe
        process.standardError = pipe

        do {
            try process.run()
            process.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""
            print("Output: \(output)")
            self.output = output

        } catch {
            errorMessage = "Failed to run SwiftFormat: \(error.localizedDescription)"
            showErrorAlert = true
        }
    }

    // Function to find the swiftformat path
    func findSwiftformat() -> String? {
        let commonPaths = ["/usr/local/bin/swiftformat", // Homebrew on Intel Macs
                           "/opt/homebrew/bin/swiftformat", // Homebrew on Apple Silicon Macs
                           "/usr/bin/swiftformat", // System-wide installs (unlikely)
                           "/bin/swiftformat"]

        let fileManager = FileManager.default
        for path in commonPaths {
            if fileManager.fileExists(atPath: path) {
                return path // Return the first found swiftformat path
            }
        }

        return nil // SwiftFormat not found
    }
}

#Preview {
    ContentView()
}
