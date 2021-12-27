# Semi-Singleton
![Platforms](https://img.shields.io/badge/platform-macOS%20|%20iOS%20|%20tvOS%20|%20watchOS%20|%20Linux-lightgrey.svg?style=flat) [![SPM compatible](https://img.shields.io/badge/SPM-compatible-E05C43.svg?style=flat)](https://swift.org/package-manager/) [![License](https://img.shields.io/github/license/happn-tech/SemiSingleton.svg?style=flat)](License.txt) [![happn](https://img.shields.io/badge/from-happn-0087B4.svg?style=flat)](https://happn.com)

## What is a Semi-Singleton?
You all know the Singleton pattern.
A Semi-Singleton will be an object that will be returned as an already existing instance or a new one depending on whether there was already an instance in memory for the given id.

Here’s an example of a lifecycle of a Semi-Singleton object:
- A first client (`client1`) requests a semi-singleton object with id `obj`. Such an object does not already exists: it is instantiated. `client1` keeps a strong reference to this object for now.
- A second client (`client2`) requests a semi-singleton object with id `obj`. As the object already exists in memory, the same instance `client1` uses is returned.
- Both `client1` and `client2` release the semi-singleton they share. It is fully deallocated.
- A third client requests a semi-singleton object with id `obj`. As the previous semi-singleton with this id does not exist anymore, a new object is instantiated.

In code, a Semi-Singleton is any object conforming to the `SemiSingleton` or `SemiSingletonWithFallibleInit` protocol.

## How to use a Semi-Singleton?
```swift
/* First you need a “Store” that will hold the reference to the existing semi-singletons. */
let semiSingletonStore = SemiSingletonStore(forceClassInKeys: true)
/* To retrieve a semi-singleton instance, you ask the store to give you one. */
let s: MySemiSingleton = semiSingletonStore.semiSingleton(forKey: key)
```

## Use case
For instance, an “Action” object, when care should be taken that only one action run at the same time for the same subject.
The subject would be the Semi-Singleton key.
When the action is instantiated, if there is already an action in progress for the given subject, the already existing action will be returned, otherwise a new one is created.

## Credits
This project was originally created by [François Lamboley](https://github.com/Frizlab) while working at [happn](https://happn.com).
