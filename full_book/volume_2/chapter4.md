# **Volume 2 – Building a Production-Ready Flutter Authentication System**

# **Chapter 4 – Dependency Injection & Object Lifetime**

## *Why We Created Only One DioClient, One AuthProvider, and One Repository (and Why Creating Them Twice Causes Mysterious Bugs)*

---

# Goal of this chapter

By the end of this chapter you will understand:

* What Dependency Injection (DI) actually means
* Why professional Flutter apps rarely use `new` objects everywhere
* Why creating multiple `DioClient`s caused your authentication problem
* What Object Lifetime means
* Singleton vs Multiple Instances
* Why Provider is also a Dependency Injection framework
* How large Flutter projects organize objects
* How to know when to create one object and when to create many

This chapter is one of the most important in Flutter architecture.

---

# First...

Let's answer the scary question.

## What is Dependency Injection?

Most beginners hear the term and think

> "This sounds like computer science."

It isn't.

It's actually very simple.

Dependency Injection simply means

> **Instead of creating what you need yourself, someone else gives it to you.**

That's all.

Seriously.

---

# A real-life example

Imagine you're a chef.

You need vegetables.

Option 1

Every time you cook

You leave the kitchen

↓

Go to the market

↓

Buy vegetables

↓

Come back

↓

Cook

Very stressful.

---

Option 2

Someone brings fresh vegetables every morning.

You simply use them.

Much easier.

That person "injects" the vegetables.

That's Dependency Injection.

---

# Flutter example

Without DI

```dart
class AuthRepository {

  final dio = Dio();

}
```

Every repository creates its own Dio.

Now imagine

```text
AuthRepository

↓

creates Dio #1
```

Then

```text
RiderRepository

↓

creates Dio #2
```

Then

```text
WalletRepository

↓

creates Dio #3
```

Then

```text
OrderRepository

↓

creates Dio #4
```

Then

```text
NotificationRepository

↓

creates Dio #5
```

Five different Dio objects.

Five different interceptors.

Five different configurations.

Five different headers.

Five different bugs.

---

Instead...

```dart
final dioClient = DioClient();
```

Create ONE.

Then give it to everyone.

```text
main.dart

↓

DioClient

↓

AuthRepository

↓

RiderRepository

↓

WalletRepository

↓

DeliveryRepository
```

Everybody shares one object.

This is Dependency Injection.

---

# Why is this better?

Imagine your access token changes.

If every repository has its own Dio

```text
Repository A

Old Token
```

Repository B

```text
New Token
```

Repository C

```text
No Token
```

Repository D

```text
Expired Token
```

Chaos.

---

With one Dio

```text
All repositories

↓

Same Dio

↓

Same token

↓

Same interceptors

↓

Same configuration
```

Everything stays synchronized.

---

# Remember your bug?

A few days ago...

Your app looked like this

```dart
final authRepository =
    AuthRepository(dioClient: DioClient());
```

Then

```dart
RiderRepository(
    dioClient: DioClient()
)
```

Notice something?

You accidentally wrote

```dart
DioClient()
```

Twice.

That means

Two completely different objects.

```text
DioClient A

↓

Auth
```

and

```text
DioClient B

↓

Riders
```

Your login stored the token inside one object.

Your Riders API used another object.

So it sent

```text
Authorization:

(empty)
```

Or an outdated token.

That is exactly why your authentication kept failing.

---

The fix

```dart
final dioClient = DioClient();
```

One object.

Then

```dart
AuthRepository(
dioClient: dioClient
)
```

and

```dart
RiderRepository(
dioClient: dioClient
)
```

Now both share everything.

Professional architecture.

---

# What exactly is an Object?

When you write

```dart
final dio = DioClient();
```

Flutter creates something in memory.

That "something"

is called an Object.

Think of it like a real machine.

Every object has

Own memory

Own variables

Own methods

Own state

---

Example

```dart
final car1 = Car();
```

Different from

```dart
final car2 = Car();
```

Even though they're both cars.

If

```text
car1.color

=

Red
```

car2 is NOT automatically red.

They're different objects.

The same thing happened with your DioClient.

---

# Object Lifetime

This is another scary name.

But it's easy.

Object Lifetime simply means

> **How long does this object stay alive?**

Example

```dart
build(){

final controller = TextEditingController();

}
```

Every rebuild

↓

New controller

↓

Old controller disappears

Bad.

---

Instead

```dart
class _LoginState{

late TextEditingController controller;

}
```

Created once.

Lives until the page closes.

Much better.

---

Now think about DioClient.

Should Dio exist only for one screen?

No.

Should it disappear after rebuild?

No.

Should every page have one?

No.

It should live

For the entire app.

That's why we create it inside

```dart
main()
```

Perfect place.

---

# Object Lifetime Chart

```text
App Starts

↓

Create DioClient

↓

Lives

↓

Login

↓

Home

↓

Profile

↓

Orders

↓

Payments

↓

Notifications

↓

Logout

↓

App closes

↓

Object destroyed
```

That's its lifetime.

---

# Why Provider is also Dependency Injection

Many people think Provider is only State Management.

Not true.

Provider is also a Dependency Injection tool.

Look at this

```dart
ChangeNotifierProvider(

create: (_) => AuthProvider()

)
```

Who creates AuthProvider?

Provider.

Who gives it to the rest of the app?

Provider.

That is literally Dependency Injection.

---

Another example

Without Provider

```dart
LoginScreen(){

final auth = AuthProvider();

}
```

Home

```dart
Home(){

final auth = AuthProvider();

}
```

Settings

```dart
Settings(){

final auth = AuthProvider();

}
```

Three providers.

Three different states.

Bad.

---

With Provider

```text
main.dart

↓

Provider

↓

One AuthProvider

↓

Shared everywhere
```

Perfect.

---

# Singleton

You'll hear this word often.

Singleton simply means

"There should only ever be one."

Examples

Only one

```text
FirebaseApp
```

Only one

```text
SharedPreferences
```

Only one

```text
SecureStorage
```

Only one

```text
DioClient
```

Usually.

---

Things that should usually be singletons

```text
API Client

Logger

Database

Secure Storage

Analytics

Authentication Manager

Firebase

Notification Service
```

Only one needed.

---

Things that should NOT be singletons

```text
LoginController

SearchController

AnimationController

TextEditingController

FormController
```

These belong to individual screens.

Every page needs its own.

---

# How do professionals decide?

Ask one question.

> Does everyone need to share this?

If YES

Create one.

If NO

Create many.

---

Example

Token Storage

Every page needs it.

One instance.

---

Shopping Cart

Every page needs it.

One instance.

---

AnimationController

Home animation.

Profile animation.

Login animation.

Each page needs its own.

Different instances.

---

# Your Project Architecture

Right now your app is becoming something like this

```text
main.dart

↓

DioClient

↓

Repositories

↓

Providers

↓

UI
```

Let's draw it.

```text
main.dart
        │
        │
        ▼
+------------------+
|    DioClient     |
+------------------+
        │
        │
        ▼
+------------------+
| AuthRepository   |
+------------------+

+------------------+
| RiderRepository  |
+------------------+

+------------------+
| WalletRepository |
+------------------+
        │
        ▼
+------------------+
| AuthProvider     |
+------------------+

+------------------+
| RiderProvider    |
+------------------+
        │
        ▼
Flutter UI
```

Notice

Nobody creates Dio anymore.

Everyone receives it.

Beautiful architecture.

---

# Another Beginner Mistake

Creating repositories inside widgets.

Example

```dart
Widget build(){

final repo = RiderRepository();

}
```

Bad.

Every rebuild

↓

New Repository

↓

New Dio

↓

New Interceptors

↓

Memory waste

Instead

Inject it once.

---

# Large Company Architecture

Companies like

Google

Uber

Airbnb

PayPal

usually have

```text
main

↓

Dependency Injection

↓

Services

↓

Repositories

↓

Providers

↓

Screens
```

Exactly the same idea.

Only much bigger.

---

# Rule to Remember

Whenever you write

```dart
SomeClass()
```

Ask yourself

Should there be

One?

or

Many?

If you're unsure, think about whether the object represents:

* **A shared service** (one instance)
* **A screen-specific controller** (many instances)

This simple question will prevent many architectural mistakes.

---

# Chapter Summary

You learned:

* Dependency Injection means **receiving dependencies instead of creating them yourself**.
* `DioClient` should be created once and shared across the app.
* Creating multiple `DioClient` instances can lead to inconsistent authentication, headers, and interceptors.
* Object Lifetime describes how long an object should exist in memory.
* Provider is both a **State Management** and **Dependency Injection** solution.
* Singletons are ideal for shared services like networking, storage, and authentication.
* Controllers tied to individual screens should usually have separate instances.
* Professional Flutter apps separate object creation (`main.dart`) from object usage (repositories, providers, and UI).

---

# Coming Next

## **Volume 2 – Chapter 5**

# **Building a Professional Networking Layer**

You'll learn how professional Flutter apps organize networking using:

* `ApiConstants`
* `DioClient`
* Interceptors
* Repositories
* Request flow
* Response flow
* Error handling flow
* Why we almost never call `dio.get()` directly from the UI
* How a request travels from a button tap all the way to the backend and back again

This chapter will complete your understanding of the networking architecture that powers the authentication system you've been building.
