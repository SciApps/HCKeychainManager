# HCKeychainManager

## A utility for storing property list objects securely

`HCKeychainManager` is an Objective-C class which enables developers to seamlessly use the iOS Keychain in their projects for storing strings, binary data or structured information, as long as it is serializable as a property list.

## Usage

### Use case #1

This dynamic, not statically type-safe but more convenient way uses modern Objective-C subscripting syntac using string keys. The class implements `+ objectForKeyedSubscript:` and `+setObject:forKeyedSubscript:`, so you can use it as if it was a dictionary. For example:

```
HCKeychainManager.self[@"foo"] = @"bar";
HCKeychainManager.self[@"qux"] = @1337;
HCKeychainManager.self[@"lol"] = @[ @"arrays", @"work", @"too" ];

NSLog(@"%@", HCKeychainManager.self[@"lol"]);
```

### Use case #2

This statically type-safe approach requires you to add properties to the class. This is accomplished in three steps:

1. Add the `@property` declarations to the `@interface`. There is a `#warning` and three example comments in the header file that guide you. The properties should be marked `(nonatomic, copy, nullable, class)`.
2. For each property, add a corresponding `@dynamic` directive in the `@implementation` part of the class. Again, there are commented examples and a `#warning` in the appropriate place. This tells the compiler that the implementation of these properties will be provided at runtime.
3. For each property, add the property name(s) as an `NSString` to the `propertyNames` array within the `+ initialize` method. This place is marked with a `#warning` as well, and comments show the example again.

If you are done, recompile the class, and it will automatically handle each property, with the additional benefit that you will have static type checking by the compiler. You can use the class properties like this:

```
HCKeychainManager.foo = @"secret text";
NSLog(@"%@", HCKeychainManager.foo);
```
