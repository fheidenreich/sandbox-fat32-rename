//
//  ViewController.swift
//  sandbox-fat32-rename
//
//  Created by Florian on 18.03.21.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet weak var folderTextField: NSTextField!
    @IBOutlet weak var selectFolderButton: NSButton!
    @IBOutlet weak var createTestFileButton: NSButton!
    @IBOutlet weak var renameFileButton: NSButton!
    @IBOutlet weak var readFromFileButton: NSButton!

    private var bookmarkData: Data?

    override func viewDidLoad() {
        super.viewDidLoad()

        createTestFileButton.isEnabled = false
        renameFileButton.isEnabled = false
        readFromFileButton.isEnabled = false
    }

    private func accessSecurityScopedURL() throws -> (Bool, URL?) {
        guard let bookmark = bookmarkData else {
            return (false, nil)
        }
        var isStale = false
        let url = try URL(resolvingBookmarkData: bookmark, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: &isStale)
        if isStale {
            bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
        }
        let success = url.startAccessingSecurityScopedResource()
        return (success, url)
    }

    // 1.
    @IBAction func selectFolder(_ sender: Any) {
        let openPanel = NSOpenPanel()
        openPanel.message = "Please choose a folder on an external FAT32-formatted volume."
        openPanel.canChooseFiles = false
        openPanel.canChooseDirectories = true

        if openPanel.runModal() == NSApplication.ModalResponse.OK {
            guard let url = openPanel.urls.first else {
                return
            }
            do {
                bookmarkData = try url.bookmarkData(options: .withSecurityScope, includingResourceValuesForKeys: nil, relativeTo: nil)
                folderTextField.stringValue = url.path
                createTestFileButton.isEnabled = true
            } catch {
                NSApplication.shared.presentError(error)
            }
        }
    }

    // 2.
    @IBAction func createTestFile(_ sender: Any) {
        do {
            let (success, url) = try accessSecurityScopedURL()
            guard let folderURL = url, success else {
                print("Cannot access security scoped resource")
                return
            }
            defer {
                folderURL.stopAccessingSecurityScopedResource()
            }

            let fileURL = folderURL.appendingPathComponent("test.txt")
            let fileContent = "This is a test"
            try fileContent.write(toFile: fileURL.path, atomically: false, encoding: .utf8)

            renameFileButton.isEnabled = true

        } catch {
            NSApplication.shared.presentError(error)
        }
    }

    // 3.
    @IBAction func renameTestFile(_ sender: Any) {
        do {
            let (success, url) = try accessSecurityScopedURL()
            guard let folderURL = url, success else {
                print("Cannot access security scoped resource")
                return
            }
            defer {
                folderURL.stopAccessingSecurityScopedResource()
            }

            let fileURL = folderURL.appendingPathComponent("test.txt")

            let handle = try FileHandle(forReadingFrom: fileURL)
            handle.closeFile()

            let tempDirectoryURL = try FileManager.default.url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: fileURL, create: true)

            // This part serves as a stub to the external C++ library I'm using in the original code
            // that uses a temporary file to write changes and uses rename() to atomically replace the
            // original file with the temporary file upon success.
            let writeHelper = ExternalWriteHelper()
            let writeSuccess = writeHelper.write(fileURL.path, with: tempDirectoryURL.appendingPathComponent("test.tmp").path)
            if !writeSuccess {
                print("Cannot write to and rename temporary file")
                return
            }

            readFromFileButton.isEnabled = true

        } catch {
            NSApplication.shared.presentError(error)
        }
    }

    // 4.
    @IBAction func readFromTestFile(_ sender: Any) {
        do {
            let (success, url) = try accessSecurityScopedURL()
            guard let folderURL = url, success else {
                print("Cannot access security scoped resource")
                return
            }
            defer {
                folderURL.stopAccessingSecurityScopedResource()
            }

            let fileURL = folderURL.appendingPathComponent("test.txt")

            // 💥
            let handle = try FileHandle(forReadingFrom: fileURL)
            handle.closeFile()

        } catch {
            NSApplication.shared.presentError(error)
        }
    }
}

