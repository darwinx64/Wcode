//
//  FileTreeView.swift
//  Wcode
//
//  Created by paige on 10/21/24.
//

import SwiftUI
import Combine

struct FileTreeView: View {
    struct FileItem: Hashable, Identifiable, CustomStringConvertible {
        var id: Self { self }
        var name: String
        var url: [URL] = [URL(string: "/Applications")!]
        var children: [FileItem]? = nil
        var description: String {
            switch children {
            case nil:
                return "doc.text"
            case .some(let children):
                return children.isEmpty ? "folder" : "folder.fill"
            }
        }
    }
    @State var selected: FileItem? = nil
    let fileHierarchyData: [FileItem] = [
        FileItem(name: "users", children:
                    [FileItem(name: "user1234", children:
                                [FileItem(name: "Photos", children:
                                            [FileItem(name: "photo001.jpg"),
                                             FileItem(name: "photo002.jpg")]),
                                 FileItem(name: "Movies", children:
                                            [FileItem(name: "movie001.mp4")]),
                                 FileItem(name: "Documents", children: [])
                                ]),
                     FileItem(name: "newuser", children:
                                [FileItem(name: "Documents", children: [])
                                ])
                    ]),
        FileItem(name: "private", children: nil)
    ]
    
    var body: some View {
        List(fileHierarchyData, children: \.children, selection: $selected) { item in
            HStack{
                Image(systemName: item.description)
                    .frame(width: 16, height: 16)
                Text(item.name)
            }
            .contextMenu {
                Button { NSWorkspace.shared.activateFileViewerSelecting(item.url) } label: {
                    Text("Show in Finder")
                }
                Divider()
                Button {} label: {
                    Text("Open in Tab")
                }
                Button {} label: {
                    Text("Open in Window")
                }
                Divider()
                Button {} label: {
                    Text("Delete")
                }
                Divider()
            }
        }
    }
}

struct FileTreeViewTest: View {
    var body: some View {
        NavigationSplitView {
            FileTreeView()
        } detail: {
            CodeEditorViewWrapper()
        }
    }
}

#Preview {
    FileTreeViewTest()
}
