//
//  ContentView.swift
//  gps2photos
//
//  Created by Astro on 1/24/21.
//

import Combine
import FontAwesomeSwiftUI
import SwiftUI

enum CriteriaToRun: Int {
    case hasImages = 1
    case hasQRImage = 2
    case hasGPXFile = 4
    case hasExiftool = 8
}

struct ContentView: View {
    static private let keepOriginalKey = "keepOriginal"
    
    @State private var dragOver = false
    @State private var fileItems: [FileItem] = []
    @State private var selected: Set<Int> = Set()
    @State private var criteriaMet: Int = 0
    @State private var qrImage: QRImage?
    @State private var gpsFile: URL?
    @State private var isRunning = false
    @State private var hasQRImage = false
    @State private var isProcessing = false
    @State private var hasExiftool = false
    @State private var hasSeenExiftoolAlert = false
    @State private var keepOriginal = false
    // meh, shouldn't have needed this, but a flag is needed so the keepOriginal value doesn't get reset
    // to false each time the app starts
    @State private var hasAppStarted = false
    
    private let imageProcessor = ImageProcessor()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy hh:mma"
        return formatter
    }()

    private var geoTagImage: GeoTagImage
    @ObservedObject private var progress: ProgressModel
    private var subscribers: Set<AnyCancellable> = []
    
    init() {
        let geoService = GeoTagImage()
        geoTagImage = geoService
        progress = geoService.progress
    }
    
    var body: some View {
        HStack {
                listView
                rightSideView
        }
        .frame(width: 640, height: 480, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        .onAppear(perform: appear)
        .onReceive(geoTagImage.$hasQRImage, perform: { newValue in
            hasQRImage = newValue
        })
        .onReceive(geoTagImage.$isProcessing, perform: { newValue in
            isProcessing = newValue
            if !isProcessing {
                fileItems = []
                criteriaMet = 0
                hasQRImage = false
                exiftoolCheck()
            }
        })
    }
    
    @ViewBuilder
    var listView: some View {
        VStack {
            if fileItems.isEmpty {
                emptyListView
            } else {
                itemsListView
            }
            
            HStack {
                Button(action: {
                    // Open file dialog
                    openFileDialog()
                }, label: {
                    Text(AwesomeIcon.plus.rawValue)
                })
                .font(.awesome(style: .solid, size: 10))
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: -15))
                .disabled(isProcessing == true)
                
                Button(action: {
                    // delete selected files
                    for index in selected {
                        fileItems.remove(at: index)
                    }
                    selected = Set()
                }, label: {
                    Text(AwesomeIcon.minus.rawValue)
                })
                .font(.awesome(style: .solid, size: 10))
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 0))
                .disabled(isProcessing == true)
                
                Button(action: {
                    fileItems = []
                    criteriaMet = criteriaMet & ~CriteriaToRun.hasGPXFile.rawValue & ~CriteriaToRun.hasImages.rawValue & ~CriteriaToRun.hasQRImage.rawValue
                }, label: {
                    Text("Clear")
                })
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 8, trailing: 0))
                .disabled(isProcessing == true)
                Spacer().frame(maxWidth: .infinity, maxHeight: 1)
            }
        }
    }
    
    @ViewBuilder
    var rightSideView: some View {
        VStack {
            Spacer()
            VStack(alignment: .leading) {
                Text("Check List")
                CheckedItem(text: "Images to geotag", flagValue: CriteriaToRun.hasImages.rawValue, criteria: $criteriaMet)
                CheckedItemBool(text: "gps4camera QR code image", disableIcon: AwesomeIcon.question.rawValue, isEnabled: $hasQRImage)
                CheckedItem(text: "gps4camera GPX file", flagValue: CriteriaToRun.hasGPXFile.rawValue, criteria: $criteriaMet)
                CheckedItem(text: "ExifTool installed", flagValue: CriteriaToRun.hasExiftool.rawValue, disabledColor: .red, disableIcon: AwesomeIcon.times.rawValue, criteria: $criteriaMet)
                
                Toggle(isOn: $keepOriginal) {
                    Text("Keep Originals")
                }
                .onReceive([self.keepOriginal].publisher.first(), perform: { value in
                    if hasAppStarted {
                        print("New value: \(value)")
                        UserDefaults.standard.setValue(value, forKey: ContentView.keepOriginalKey)
                    }
                })
            }
            .padding()
            Spacer()
            ProgressBar(progressModel: progress).frame(height: 10).padding(EdgeInsets(top: 0, leading: 20, bottom: 0, trailing: 20))
            Spacer()
            Button(action: {
                if isProcessing {
                    geoTagImage.cancel()
                    progress.index = 1
                    progress.totalTasks = 1
                    progress.taskName = "Cancelled"
                    isProcessing = false
                } else {
                    geoTagImage.processImages(list: fileItems, qrImage: qrImage, gpsFile: gpsFile, keepOriginal: keepOriginal)
                }
            }, label: {
                Text(isProcessing ? "Cancel" : "Geotag Images")
            })
            .disabled(criteriaMet != 13)
            Spacer()
        }
    }
    
    var emptyListView: some View {
        ZStack {
            Rectangle()
                .fill(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                    return dropHandler(providers)
                }
                .border(dragOver ? Color.red : Color.clear)
                .animation(.default)

            VStack {
                Text("Drag and drop files and folders here.")
            }
        }

    }
    
    var itemsListView: some View {
        VStack {

            List(0 ..< fileItems.count, id: \.self, selection: $selected) { index in
                let item = fileItems[index]

                HStack {
                    VStack(alignment: .leading) {
                        Text(item.url.lastPathComponent)
                            .font(.headline)
                        Text(dateFormatter.string(from: item.date() ?? Date()))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .onDrop(of: ["public.file-url"], isTargeted: $dragOver) { providers -> Bool in
                return dropHandler(providers)
            }
            .onDeleteCommand(perform: {
                var indexSet = IndexSet()
                for index in selected {
                    indexSet.insert(index)
                }
                
                // TODO: when delete, check criteriaMet and update!
                
                fileItems.remove(atOffsets: indexSet)
            })
            .border(dragOver ? Color.red : Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.default)
        }
    }
    
    private func dropHandler(_ providers: [NSItemProvider]) -> Bool {
        for provider in providers {
            provider.loadDataRepresentation(forTypeIdentifier: "public.file-url", completionHandler: { (data, error) in
                
                guard let data = data,
                      let path = NSString(data: data, encoding: 4),
                      let url = URL(string: path as String)
                else {
                    return
                }

                fileItems = processUrl(url: url, appendTo: fileItems)
            })
        }
        return true
    }
    
    private func processUrl(url: URL, appendTo: [FileItem]) -> [FileItem] {
        // if url is file, create FileItem(url: url) and return it
        // if url is directory, scan directory for files and add each file
        let isDirectory = (try? url.resourceValues(forKeys: [.isDirectoryKey]))?.isDirectory ?? false
        var files = appendTo
        
        guard isDirectory else {
            checkFile(url: url)
            files.append(FileItem(url: url))
            return files
        }
        
        guard let contents = try? FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: [.skipsHiddenFiles, .skipsPackageDescendants]) else {
            return files
        }
        
        let sorted = contents.sorted { (left, right) -> Bool in
            return left.absoluteString < right.absoluteString
        }
        
        for file in sorted {
            files = processUrl(url: file, appendTo: files)
        }
        
        return files
    }
    
    private func checkFile(url: URL) {
        let fileExt = url.pathExtension.lowercased()
        
        if fileExt == "gpx" {
            gpsFile = url
            criteriaMet = criteriaMet | CriteriaToRun.hasGPXFile.rawValue
            return
        }

        criteriaMet = criteriaMet | CriteriaToRun.hasImages.rawValue
    }
    
    private func exiftoolCheck() {
        // check if exiftool exists
        let result = Shell.run("exiftool -ver")
        hasExiftool = result.1 == 0
        criteriaMet = hasExiftool ? criteriaMet | CriteriaToRun.hasExiftool.rawValue : criteriaMet
    }
    
    private func appear() {
        // Interesting.  In macos 10.14, appear() is getting called before exiftoolCheck() has had a chance to run.
        // If hasExifTool is still false, try checking for exiftool.  
        if !hasExiftool {
            exiftoolCheck()
        }

        if !hasExiftool && !hasSeenExiftoolAlert {
            hasSeenExiftoolAlert = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                showAlert(message: "ExifTool is missing.", informative: "Install ExifTool from https://exiftool.org/ and restart gps2photos.")
            }
        }
        
        hasAppStarted = true
        keepOriginal = UserDefaults.standard.bool(forKey: ContentView.keepOriginalKey)
    }
    
    private func showAlert(message: String, informative: String) {
        let alert = NSAlert()
        alert.messageText = message
        alert.informativeText = informative
        alert.alertStyle = .critical
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
    
    private func openFileDialog() {
        let dialog = NSOpenPanel()
        dialog.title = "Select files or folders| gsp2photos"
        dialog.showsResizeIndicator = true
        dialog.showsHiddenFiles = false
        dialog.allowsMultipleSelection = true
        dialog.canChooseDirectories = true
        dialog.canChooseFiles = true
        
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            for url in dialog.urls {
                fileItems = processUrl(url: url, appendTo: fileItems)
            }
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
