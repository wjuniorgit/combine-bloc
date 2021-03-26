//
//  CounterApp.swift
//  Counter
//
//  Created by Wellington Soares on 23/03/21.
//

import SwiftUI
import CombineBloc

@main
struct CounterApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(counterBloc: CounterBloc())
        }
    }
}

struct ContentView: View {
    let counterBloc: Bloc<CounterEvent, CounterState>

    var body: some View {
        VStack {
            Text("Counter App").padding()
            HStack {
                Button(action: {counterBloc.send(.decrement) }) {
                    Text("-") }.padding()
                BlocViewBuilder(bloc: counterBloc) {
                    state in
                    Text("\(state.count)") }.padding()
                Button(action: { counterBloc.send(.increment) }) {
                    Text("+") }.padding()
            }
        }.font(.title)
    }
}
