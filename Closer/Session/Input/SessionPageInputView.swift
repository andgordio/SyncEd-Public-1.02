//
//  SessionPageInputElement.swift
//  Closer
//
//  Created by Andriy Gordiyenko on 6/6/22.
//

import SwiftUI

struct SessionPageInputView: View {
    
    @StateObject var viewModel = SessionPageInputViewController()
    
    var sessionId: String
    var taskId: String
    var scroll: ScrollViewProxy
    var focusedField: FocusState<String?>.Binding
    
    
    var body: some View {
        TextEditor(text: $viewModel.textinput)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .frame(minHeight: 120, maxHeight: 120)
            .focused(focusedField, equals: taskId)
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(Color("gray-tertiary"))
            )
            .onTapGesture {
                withAnimation {
                    // # Note
                    // A workaround for SwiftUI’s lack of ability to scroll TextEditor into view.
                    // This is part 1. Part 2 is in SessionPageView.
                    scroll.scrollTo(taskId, anchor: .trailing)
                }
            }
            .onAppear() {
                viewModel.initViewModel(sessionId: sessionId, taksId: taskId)
            }
            .onReceive(viewModel.timer) { _ in
                if focusedField.wrappedValue == taskId {
                    viewModel.pushUpdates()
                }
            }
    }
}
