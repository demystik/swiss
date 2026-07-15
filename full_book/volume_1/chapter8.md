# Volume 1 — Chapter 8

# Dependency Injection & Application Startup (The Hidden Backbone of Every Professional Flutter App)

> **Goal of this chapter**
>
> By the end of this chapter, you'll understand:
>
> * What Dependency Injection (DI) really is
> * Why `main.dart` creates everything
> * Why we create only one `DioClient`
> * What "injecting dependencies" actually means
> * Why your app starts the way it does
> * What `MultiProvider` really does
> * The complete startup flow of a Flutter application
> * Common dependency injection mistakes

---

# Before We Begin...

Look at the architecture you've built.

```text
Backend
   ↑
Dio Client
   ↑
Repositories
   ↑
Providers
   ↑
UI
```

One question remains...

**Who creates all these objects?**

Someone has to create

* DioClient
* AuthRepository
* RiderRepository
* AuthProvider
* RidersProvider

Who does it?

The answer is...

## main.dart

This is why `main.dart` is one of the most important files in Flutter.

---

# What Happens When You Open an App?

Imagine you tap WhatsApp.

Within milliseconds...

The app has to

* initialize Flutter
* initialize Firebase
* initialize networking
* initialize authentication
* load saved user
* create providers
* build the first screen

All before you see anything.

Your app works exactly the same.

---

# Startup Timeline

Let's simplify it.

```text
User taps app

↓

main()

↓

Initialize Flutter

↓

Create Services

↓

Create Repositories

↓

Create Providers

↓

Restore Login

↓

runApp()

↓

Flutter builds UI
```

Everything before `runApp()` is preparation.

---

# Your main.dart

You wrote something like this:

```dart
void main() async {

WidgetsFlutterBinding.ensureInitialized();

final dioClient = DioClient();

final authRepository = AuthRepository(
    dioClient: dioClient);

final authProvider =
    AuthProvider(authRepository);

await authProvider.loadUser();

runApp(...);

}
```

This is actually a professional startup flow.

Let's understand every line.

---

# Step 1

```dart
WidgetsFlutterBinding.ensureInitialized();
```

Question.

Why can't we just call `runApp()`?

Because some things need Flutter to be ready.

Examples

* Secure Storage
* Shared Preferences
* Firebase
* Camera
* Hive
* SQLite

Without this line...

Flutter plugins may crash.

---

Think of it like this.

```text
Flutter Engine

↓

Ready?

↓

YES

↓

Plugins can work
```

---

# Step 2

Create Dio.

```dart
final dioClient = DioClient();
```

Question...

Why here?

Why not inside every Repository?

---

Imagine this.

```text
AuthRepository

↓

creates Dio

RiderRepository

↓

creates Dio

DeliveryRepository

↓

creates Dio

WalletRepository

↓

creates Dio
```

Now you have

Five Dio objects.

Five interceptors.

Five configurations.

Huge waste.

---

Professional apps create ONE.

```text
main.dart

↓

One DioClient

↓

Everybody shares it
```

Much cleaner.

---

# Step 3

Create Repository

Example

```dart
final authRepository =
AuthRepository(
dioClient: dioClient,
);
```

Notice something.

Repository DID NOT create Dio.

Instead...

Dio was given to it.

This is called

## Dependency Injection

---

# What is Dependency Injection?

Scary name.

Very simple idea.

Instead of creating something yourself...

Someone gives it to you.

Example

Instead of

```dart
class AuthRepository{

final dio = Dio();

}
```

We do

```dart
class AuthRepository{

final DioClient dioClient;

AuthRepository(this.dioClient);

}
```

We injected it.

---

# Real Life Analogy

Imagine you're a chef.

Should you build a farm?

Raise chickens?

Grow tomatoes?

No.

Someone brings ingredients to you.

You simply cook.

That's Dependency Injection.

---

Flutter example

Instead of creating

```dart
Dio()
```

inside Repository...

Someone gives Repository an already prepared Dio.

---

# Why is Dependency Injection Better?

Imagine tomorrow.

You want to replace Dio.

Instead of

```text
Dio
```

You now use

```text
HttpClient
```

Without DI...

Every Repository changes.

With DI...

Only one place changes.

Beautiful.

---

# Step 4

Create Provider

```dart
final authProvider =
AuthProvider(authRepository);
```

Again...

Provider didn't create Repository.

Repository was injected.

Pattern repeats.

---

Architecture becomes

```text
main.dart

↓

Repository

↓

Provider
```

---

# Step 5

Restore Login

This line

```dart
await authProvider.loadUser();
```

is extremely important.

---

Imagine.

Yesterday

User logged in.

Closed app.

Today

User opens app.

Should they login again?

No.

App should remember.

---

How?

Secure Storage.

---

Startup Flow

```text
App starts

↓

loadUser()

↓

Read Access Token

↓

Exists?

↓

YES

↓

Request current user

↓

Success

↓

Authenticated

↓

Dashboard
```

---

If token doesn't exist

```text
No Token

↓

Unauthenticated

↓

Login Screen
```

This is exactly what your app does.

---

# Why before runApp()?

Question.

Why not

```dart
runApp();

loadUser();
```

Because UI would first build.

Then suddenly change.

User sees flickering.

Professional apps avoid this.

Instead

```dart
await loadUser();

runApp();
```

Everything is already known.

Very smooth.

---

# Step 6

MultiProvider

```dart
MultiProvider(
providers:[...]
)
```

Question...

Why MultiProvider?

Because apps have multiple Providers.

Example

```text
Auth

Riders

Wallet

Delivery

Orders

Settings

Theme

Notifications
```

All need to exist.

---

Without MultiProvider

You would write

```dart
ChangeNotifierProvider(

child:

ChangeNotifierProvider(

child:

ChangeNotifierProvider(

child:

...
```

Very ugly.

MultiProvider fixes that.

---

# What does Provider actually store?

Example

```dart
ChangeNotifierProvider(

create: (_) =>

AuthProvider(...)

)
```

Flutter stores it.

Anywhere below

you can access it.

Like magic.

---

# Dependency Graph

Look carefully.

```text
main.dart

↓

DioClient

↓

AuthRepository

↓

AuthProvider

↓

Login Screen
```

Every object depends on the previous one.

---

# Why shouldn't Provider create Repository?

Wrong

```dart
class AuthProvider{

final repo=

AuthRepository();

}
```

Now Provider controls Repository.

Hard to test.

Hard to replace.

---

Instead

```dart
AuthProvider(

repository
)
```

Much cleaner.

---

# Composition Root

Professional term.

Your

```text
main.dart
```

is called

## Composition Root

Meaning

> The place where the whole application is assembled.

Everything starts here.

Professional developers immediately check `main.dart` to understand a project.

---

# One Object, Many Users

Look at your code.

```dart
final dioClient = DioClient();
```

Now

AuthRepository uses it.

RiderRepository uses it.

DeliveryRepository uses it.

WalletRepository uses it.

Same object.

Shared everywhere.

Exactly what we want.

---

# Singleton vs New Object

Imagine

```dart
DioClient()
```

called 20 times.

You create

20 Dio instances.

Not ideal.

Instead

One.

Shared.

---

Think of electricity.

A house has one electrical supply.

Not one power station per room.

---

# Startup Flow (Complete)

```text
User taps app

↓

main()

↓

Flutter initialized

↓

Create Dio

↓

Create Repository

↓

Create Provider

↓

Load saved token

↓

Authenticated?

↓

Yes → Dashboard

↓

No → Login

↓

runApp()

↓

Flutter builds UI
```

This is how most professional apps work.

---

# Your Current Architecture

```text
main.dart

↓

DioClient

↓

AuthRepository

↓

AuthProvider

↓

GoRouter

↓

MaterialApp

↓

Screens
```

Very solid.

---

# Common Beginner Mistakes

## Mistake 1

Creating Dio inside every Repository.

Wrong.

---

## Mistake 2

Creating Repository inside Provider.

Wrong.

---

## Mistake 3

Creating Provider inside Widget.

Wrong.

---

## Mistake 4

Not awaiting initialization.

Wrong.

---

## Mistake 5

Calling Secure Storage before

```dart
WidgetsFlutterBinding.ensureInitialized();
```

Can crash.

---

## Mistake 6

Creating Providers inside build()

Very bad.

Every rebuild creates new objects.

---

# Professional Folder Structure

```text
lib/
│
├── main.dart      ← Composition Root
│
├── core/
│   ├── network/
│   ├── storage/
│   └── constants/
│
├── features/
│   ├── auth/
│   ├── riders/
│   ├── delivery/
│   ├── wallet/
│   └── profile/
```

Everything begins in `main.dart`.

---

# Mental Model

Whenever you build a Flutter app, ask yourself:

> **Who creates this object?**

If it's a service used across the app (like `DioClient` or `FirebaseAuth`), create it once in `main.dart`.

> **Who needs this object?**

Pass it down through constructors.

That is Dependency Injection.

---

# Mini Challenge

Without looking back, answer these:

1. Why do we call `WidgetsFlutterBinding.ensureInitialized()`?
2. Why do we create only one `DioClient`?
3. What does "Dependency Injection" actually mean?
4. Why is `main.dart` called the Composition Root?
5. Why should `loadUser()` run before `runApp()`?
6. What problem does `MultiProvider` solve?
7. Why shouldn't a Provider create its own Repository?
8. Which object is shared between `AuthRepository` and `RiderRepository` in your app?
9. What happens if you create Providers inside `build()`?
10. Draw the startup flow of your app from `main()` to the Home Screen.

If you can answer these comfortably, you've crossed a major milestone. You now understand how professional Flutter apps are assembled before the first screen appears.

---

# End of Chapter 8

## Next Chapter (Chapter 9)

**Flutter Navigation Masterclass (GoRouter from Beginner to Professional)**

This chapter will cover:

* Why navigation is more than just moving between screens
* The difference between `Navigator` and `GoRouter`
* Declarative vs imperative navigation
* Understanding routes, stacks, and navigation history
* `go()`, `push()`, `pop()`, and `replace()` explained with diagrams
* Nested navigation and `StatefulShellRoute`
* Protected routes (like your authentication flow)
* Deep linking fundamentals
* How your current router works, line by line
* Professional navigation architecture used in production Flutter apps

By the end of that chapter, you'll understand not just *how* to navigate, but *why* modern Flutter apps structure navigation the way they do.
