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
    let save: () -> Void
    let remove: () -> Void

    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    TextField("Todo Name", text: Binding(get: { state.name }, set: { updateName($0) }))
                        .font(.title)
                    Text("Please add a Name to your todo").foregroundColor(Color.red)
                        .font(.caption2)
                        .opacity(state.isNameValid ? 0.0 : 1.0)
                }.padding()
                Spacer()
            }
            Spacer()
            Button(action: { toggleIsDone() }) {
                Image(systemName: state.isDone ? "checkmark.square" : "square").resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 40)
            }.padding()
            Spacer()
            HStack {
                Button("Save", action: { save() })
                    .disabled(state.canSave ? false : true)
                    .padding()
                Spacer()
                Button("Remove", action: { remove() })
                    .disabled(state.isSaved ? false : true)
                    .foregroundColor(Color.red)
                    .opacity(state.isSaved ? 1.0 : 0.0)
                    .padding()
            }
        }.padding().navigationBarTitle(state.isSaved ? "Edit Todo" : "New Todo")
    }
}
