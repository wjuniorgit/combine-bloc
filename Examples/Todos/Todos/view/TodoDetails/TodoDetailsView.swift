//
//  TodoDetailsView.swift
//  Todos
//
//  Created by Wellington Soares on 05/04/21.
//

import SwiftUI

struct TodoDetailsView: View {
  let state: ValidTodoState
  let toggleIsDone: () -> Void
  let updateName: (String) -> Void
  let updateDescription: (String) -> Void
  let save: () -> Void
  let remove: () -> Void

  var body: some View {
    VStack {
      VStack(alignment: .leading) {
        TextField(
          "Todo Name",
          text: Binding(
            get: { state.name },
            set: { updateName($0) }
          )
        )
        .font(.title)
        .padding()
        .border(Color.black.opacity(0.2), width: 2)
        .cornerRadius(5.0)
        Text("Please add a Name to your todo")
          .foregroundColor(Color.red)
          .font(.caption)
          .opacity(state.isNameValid ? 0.0 : 1.0)
      }.padding()
      Spacer()
      VStack(alignment: .leading) {
        Text("Description")
          .font(.caption)
        TextEditor(
          text: Binding(
            get: { state.description },
            set: { updateDescription($0) }
          )
        ).padding()
          .border(Color.black.opacity(0.2), width: 2)
          .cornerRadius(5.0)
      }.padding()
      Spacer()
      Button(action: { toggleIsDone() }) {
        Image(systemName: state.isDone ? "checkmark.square" : "square")
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 40)
      }.padding()
      Spacer()
      HStack {
        Button("Save", action: { save() })
          .disabled(state.isEdited && state.isNameValid ? false : true)
          .padding()
        Spacer()
        Button("Remove", action: { remove() })
          .disabled(state.isSaved ? false : true)
          .foregroundColor(Color.red)
          .opacity(state.isSaved ? 1.0 : 0.0)
          .padding()
      }
    }.navigationBarTitle(state.isSaved ? "Edit Todo" : "New Todo")
  }
}
