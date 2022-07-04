//
//  SessionPageView.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/4/22.
//

import SwiftUI

struct SessionPageView: View {
    
    let section: LessonSection
    let tasks: [LessonTask]
    let session: FirestoreSession
    let sectionsCount: Int
    
    @State var textinput: String = ""
    @FocusState var focusedField: String?
    
    var filteredTasks: [LessonTask] {
        let filtered = tasks.filter { $0.sectionId == section.uid }
        return filtered.sorted { $0.order < $1.order }
    }
    
    let attrStr = try! AttributedString(markdown: "Hello **World**!\n[This is a link](www.google.com)", options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace))
    
    func markdownify(_ text: String) -> AttributedString {
        return try! AttributedString(
            markdown: text.replacingOccurrences(of: "/n", with: "\n"),
                    options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)
        )
    }
    
    var body: some View {
        ScrollView {
            ScrollViewReader { scroll in
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(section.name)
                            .font(.system(size: 32.0))
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        Text("Page \(section.order + 1) of \(sectionsCount)")
                            .font(.system(size: 15))
                            .foregroundColor(.gray)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .padding(.vertical, 6)
                    .cardContainer()
                    
                    ForEach(filteredTasks, id: \.uid) { task in
                        VStack(alignment: .leading, spacing: 12) {
                            
                            if !task.name.isEmpty {
                                Text(task.name)
                                    .font(.system(size: 20.0, weight: .bold))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            if !task.body.isEmpty {
                                Text(markdownify(task.body))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            
                            if task.type == .audio {
                                PlayerView(
                                    fileName: task.uid,
                                    sessionId: session.uid
                                )
                            }
                            
                            if task.type == .textInput {
                                SessionPageInputView(
                                    sessionId: session.uid,
                                    taskId: task.uid,
                                    scroll: scroll,
                                    focusedField: $focusedField
                                )
                            }
                        }
                        .cardContainer()
                        .id(task.uid)
                    }
                    // Note:
                    // A workaround for SwiftUI’s lack of ability to scroll TextEditor into view.
                    // This is part 2. Part 1 is in SessionPageInputElement.
                    // Next generation of TextField will support multiline (via wwdc22).
                    Rectangle().frame(width: 1, height: 120).foregroundColor(.clear)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .onTapGesture {
                    if focusedField != nil {
                        focusedField = nil
                    }
                }
            }
        }
    }
}
