//
//  CounterApp.swift
//  Counter
//
//  Created by Wellington Soares on 23/03/21.
//

import Combine
import CombineBloc
import SwiftUI

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
        Button(action: {
          Just(.decrement).subscribe(counterBloc.subscriber)
        }) {
          Text("-")
        }.padding()
        StateViewBuilder(bloc: counterBloc) {
          state in
          Text("\(state.count)")
        }.padding()
        Button(action: {
          Just(.increment).subscribe(counterBloc.subscriber)
        }) {
          Text("+")
        }.padding()
      }
    }.font(.title)
  }
}
