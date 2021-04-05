//
//  TodosApp.swift
//  Todos
//
//  Created by Wellington Soares on 31/03/21.
//

import SwiftUI
import Combine

@main
struct TodosApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}


struct ContentView: View {
    let todosBloc = TodosBloc(repository: MockTodosRepository())
    var body: some View {
        TodosViewRoot(todosBloc: todosBloc) }
}

