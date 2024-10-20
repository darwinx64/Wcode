//
//  CodeEditorView.swift
//  Wcode
//
//  Created by samara on 1/23/24.
//

import Foundation
import DVTBridge
import WebKit
import Cocoa
import SwiftUI

/// This is a view that uses private DVT frameworks to mimic the one found in Xcode
///
/// The whole point of Zcode/Ycode originally was to use these DVT frameworks but
/// I've been considering potentially making my own later because this project has
/// been becoming a bit more serious than I originally anticipated
class CodeEditorView: DVTSourceTextScrollView, NSTextViewDelegate {
    private static var isFrameworkInitialized = false
    private var frameworkInitPredicate: Int = 0
    
    var codeStorage: DVTTextStorage!
    var codeView: DVTSourceTextView!
    var hasBeenSaved = false
    
    private static var frameworkInitOnce: () = {
        DispatchQueue.once {
            DVTDeveloperPaths.initializeApplicationDirectoryName("something")
            DVTPlugInManager.default().scan(forPlugIns: nil)
            DVTSourceSpecification.searchForAndRegisterAllAvailableSpecifications()
            DVTTheme.initialize()
            
            let shared = DVTTextPreferences.shared()
            shared?.enableTypeOverCompletions = TYPE_OVER_COMPLETIONS
            shared?.useSyntaxAwareIndenting = AUTO_INDENT
            shared?.autoInsertClosingBrace = AUTO_CLOSE_BRACE
            shared?.autoInsertOpenBracket = AUTO_OPEN_BRACKET
            shared?.trimTrailingWhitespace = true
            
            CodeEditorView.isFrameworkInitialized = true
        }
    }()
    
    override init(frame rect: NSRect) {
        _ = CodeEditorView.frameworkInitOnce
        
        super.init(frame: rect)
        
        self.hasBeenSaved = false
        self.loadURL(nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func loadURL(_ codeURL: URL?) {
        var codeString = ""
        if let codeURL = codeURL {
            codeString = try! String(contentsOf: codeURL, encoding: .utf8)
            hasBeenSaved = true
        }
        
        codeStorage = DVTTextStorage(string: codeString)
        
        if let codeURL = codeURL {
            let codeFile = DVTFilePath(forFileURL: codeURL)
            if let codeType = DVTFileDataType(for: codeFile, error: nil) {
                var language = DVTSourceCodeLanguage(for: codeType)

                if language == nil {
                    if let identifier = LANGUAGE_FALLBACKS()[codeURL.pathExtension] {
                        language = DVTSourceCodeLanguage(identifier: identifier)
                    }
                }
                
                self.codeStorage.language = language
            }
        }
        
        
        codeStorage.usesTabs = USE_TABS
        codeStorage.wrappedLineIndentWidth = Int32(WRAP_INDENT)
        
        codeView = DVTSourceTextView()
        codeView.layoutManager?.replaceTextStorage(codeStorage)
        codeView.isHorizontallyResizable = true
        codeView.wrapsLines = WRAP
        codeView.allowsUndo = true
        codeView.maxSize = NSMakeSize(CGFloat.greatestFiniteMagnitude, CGFloat.greatestFiniteMagnitude)
        codeView.usesFindBar = true
        codeView.delegate = self

        if !WRAP_ON_WORDS {
            codeView.layoutManager?.typesetter = CodeEditorWrapAnywhereTypesetter()
        }
        
        documentView = codeView
        hasVerticalScroller = true
        hasHorizontalScroller = false
        
        if SHOW_LINE_NUMBERS {
            let sidebarView = DVTTextSidebarView(scrollView: self, orientation: .verticalRuler)
            sidebarView.drawsLineNumbers = true
            
            verticalRulerView = sidebarView
            hasVerticalRuler = true
            rulersVisible = true
        }
    }
    
    func textDidChange(_ notification: Notification) {
        guard let textView = notification.object as? NSTextView else { return }
        print(textView.string)
        if let font = NSFont(name: "SF Mono Medium", size: 19.0) {
            let fullRange = NSMakeRange(0, self.codeView.string.count)
            self.codeView.textStorage?.addAttribute(.font, value: font, range: fullRange)
        }
    }
    
    @objc func undo() {
        self.codeView.undoManager?.undo()
    }
    
    @objc func redo() {
        self.codeView.undoManager?.redo()
    }
    
    @objc func validateUserInterfaceItem(_ item: NSValidatedUserInterfaceItem) -> Bool {
        if item.action == #selector(undo) {
            return self.codeView.undoManager?.canUndo ?? false
        } else if item.action == #selector(redo) {
            return self.codeView.undoManager?.canRedo ?? false
        }
        return true
    }
    
    func saveURL(_ codeURL: URL) {
        codeView.breakUndoCoalescing()
        
        do {
            try codeStorage.string.write(to: codeURL, atomically: false, encoding: .utf8)
            
            if !hasBeenSaved {
                loadURL(codeURL)
            }
            
            hasBeenSaved = true
        } catch {
            print("error saving file: \(error)")
        }
    }

    
    deinit {
        print("xcodeview: deinnit")
    }
}

#warning("Credit where its due: https://gist.github.com/nil-biribiri/67f158c8a93ff0a5d8c99ff41d8fe3bd")

extension DispatchQueue {
    private static var _onceTracker = [String]()
    
    /**
     Executes a block of code, associated with a auto generate unique token by file name + fuction name + line of code, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     */
    public class func once(file: String = #file,
                           function: String = #function,
                           line: Int = #line,
                           block: () -> Void) {
        let token = "\(file):\(function):\(line)"
        once(token: token, block: block)
    }
    
    /**
     Executes a block of code, associated with a unique token, only once.  The code is thread safe and will
     only execute the code once even in the presence of multithreaded calls.
     
     - parameter token: A unique reverse DNS style name such as com.vectorform.<name> or a GUID
     - parameter block: Block to execute once
     */
    public class func once(token: String,
                           block: () -> Void) {
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        guard !_onceTracker.contains(token) else { return }
        
        _onceTracker.append(token)
        block()
    }
}
