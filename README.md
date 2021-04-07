# Combine Bloc
> An implementation of the ´BLoC´ (Business Logic Component) with Apple's Combine framework.

[![Swift Version][swift-image]][swift-url]
[![License][license-image]][license-url]
[![Actions Status](https://github.com/wjuniorgit/combine-bloc/workflows/Swift/badge.svg)](https://github.com/wjuniorgit/combine-bloc/actions)

BLoC is a business logic layer abstraction in which you input an `Event` and it outputs a `State`. 
This abstraction contributes to the construction of reactive apps that respects the unidirectional data flow and have a single source of truth. 
A `Bloc` from the CombineBloc package is a composite object that has a `Subscriber` which reveives `Event` and a `Publisher` of `State`.
A closure is called inside the Bloc everytime a new `Event` is received by the `Subscriber`. This closure may emit a new `State` through the `Publisher`.

The key points are:
* Inputs and outputs are implemented with event-processing operators
* Dependencies must be injectable and platform agnostic

![](bloc.png)

This package is inspired by the concept of BLoC [proposed by Paolo Soares][bloc-video-url] on DartConf 2018 and by Felix Angelov's [Flutter Bloc State Management Library][bloc-lib-url]

## Installation

Add this project on your `Package.swift`

```swift
import CombineBloc

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/wjuniorgit/combine-bloc", from: "0.2.0"),
    ],
)
```

## Usage example

This package has three use case examples implemented:
* [Counter App][counter-example]
* [Login App][login-example]
* [Todos App][todo-example]


### Counter Bloc example
#### Counter Events
```swift
enum CounterEvent: Equatable {
case increment
case decrement
}
```
#### Counter State
```swift
struct CounterState: Equatable {
let count: Int
}
```
#### Counter Bloc
```swift
final class CounterBloc: Bloc<CounterEvent, CounterState> {
init() {
    super.init(initialValue: CounterState(count: 0)) {
        event, state, emit in
        switch event {
        case .increment:
            emit(CounterState(count: state.count + 1))
        case .decrement:
            emit(CounterState(count: state.count - 1))
        }
      }
    }
  }
```


## Release History

* 0.2.0
    * The first proper release
* 0.1.0
    * Work in progress

## Meta

Wellington Soares

Distributed under the MIT license. See ``LICENSE`` for more information.

[swift-image]:https://img.shields.io/badge/swift-5.3-orange.svg
[swift-url]: https://swift.org/
[license-image]: https://img.shields.io/badge/License-MIT-blue.svg
[license-url]: LICENSE
[bloc-video-url]: https://youtu.be/PLHln7wHgPE?t=1288
[bloc-lib-url]: https://bloclibrary.dev/
[counter-example]: (Examples/Counter/)
[login-example]: (Examples/login/)
[todo-example]: (Examples/Todos/)



