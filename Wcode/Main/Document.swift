//
//  Document.swift
//  Wcode
//
//  Created by samara on 1/24/24.
//

import Foundation
import Cocoa

class Document: NSDocument {
    var windowController: WindowController?
    var cachedURL: URL?

    override func makeWindowControllers() {
        let controller = WindowController()
        windowController = controller
        
        if let cachedURL = cachedURL {
            if let codeEditorView = windowController?.codeEditorView as? CodeEditorView {
                codeEditorView.loadURL(cachedURL)
            }
        }
        windowController!.window!.setFrameUsingName(windowController!.windowFrameAutosaveName)
        addWindowController(windowController!)
        windowController!.window!.makeKeyAndOrderFront(nil)
        windowController!.window!.center()
    }

    override func read(from fileURL: URL, ofType typeName: String) throws {
        cachedURL = fileURL
    }

    override func write(to fileURL: URL, ofType typeName: String) throws {
        if let codeEditorView = windowController?.codeEditorView as? CodeEditorView {
            codeEditorView.saveURL(fileURL)
        }
    }

    deinit {
        windowController = nil
        cachedURL = nil
    }
}
