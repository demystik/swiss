# Flutter Authentication Masterclass

# Volume 2: Production-Level Authentication

# Chapter 2 — Dependency Injection (DI): The Invisible Glue Holding Your App Together

---

# Welcome

In the previous chapter, you learned how professional applications are divided into layers.

Now we're going to answer one question:

> **"How do all these layers find each other?"**

For example...

Your Login Screen needs an `AuthProvider`.

The `AuthProvider` needs an `AuthRepository`.

The `AuthRepository` needs a `DioClient`.

The `DioClient` needs an `AuthInterceptor`.

The `AuthInterceptor` needs a `TokenStorage`.

Who creates all these objects?

Who gives them to each other?

This is where **Dependency Injection** comes in.

---

# What is Dependency Injection?

Let's forget programming for a minute.

Imagine you buy a new laptop.

What comes inside the box?

* Laptop
* Charger
* Power cable
* Manual

The laptop **depends** on the charger.

Without the charger,

it eventually dies.

Now imagine Dell ships the laptop like this:

```text
Laptop

No charger.

Go and build your own charger.
```

That would be ridiculous.

Instead...

The dependency is supplied.

The laptop receives what it needs.

That's Dependency Injection.

---

# In Flutter

Suppose you write:

```dart
class AuthRepository {
  final DioClient dio = DioClient();
}
```

Looks harmless.

But let's think.

Who created `DioClient`?

The repository did.

Now imagine tomorrow...

You want to replace Dio with another HTTP client.

You now have to modify every repository.

That's called **tight coupling.**

---

Instead...

```dart
class AuthRepository {

  final DioClient dio;

  AuthRepository({
    required this.dio,
  });

}
```

Now the repository doesn't care where Dio came from.

Somebody else provides it.

This is Dependency Injection.

---

# Why is this important?

Imagine your app has

```text
12 repositories

7 providers

3 APIs

Authentication

Notifications

Payments

Orders

Tracking

Maps

Chat
```

Without Dependency Injection...

Every class creates another class.

Soon your project looks like this.

```text
Provider

↓

Repository

↓

Dio

↓

Interceptor

↓

Storage

↓

Another Repository

↓

Another Service

↓

Another Repository
```

Nobody knows

who created what.

---

With DI

Everything becomes predictable.

Every object receives its dependencies.

Nothing creates anything unnecessarily.

---

# What is a Dependency?

Anything your class needs.

Example

```dart
class AuthRepository {

    final DioClient dio;

}
```

Dependency?

```text
DioClient
```

Example

```dart
class AuthProvider {

    final AuthRepository repository;

}
```

Dependency?

```text
AuthRepository
```

Example

```dart
class AuthInterceptor {

    final TokenStorage storage;

}
```

Dependency?

```text
TokenStorage
```

A dependency is simply:

> Something another class needs to function.

---

# The Wrong Way

Suppose you build a hospital.

Every doctor buys

their own:

* bed

* microscope

* scanner

* computer

* printer

Chaos.

That's exactly what beginners do.

```dart
class AuthProvider {

    final repo = AuthRepository(
        dioClient: DioClient(),
    );

}
```

Now the Provider is responsible for building the repository.

Bad idea.

---

# The Right Way

Somebody else builds everything.

```dart
final dio = DioClient();

final repo = AuthRepository(
    dioClient: dio,
);

final provider = AuthProvider(
    repo,
);
```

Notice something.

Nobody creates anything inside themselves.

Everything is supplied.

---

# Constructor Injection

This is the most common DI style.

Example

```dart
class AuthProvider {

    final AuthRepository repository;

    AuthProvider(this.repository);

}
```

Simple.

Professional.

Easy to test.

---

# Property Injection

Less common.

```dart
class AuthProvider {

    AuthRepository? repository;

}
```

Later...

```dart
provider.repository = repo;
```

Not recommended.

Too easy to forget.

---

# Method Injection

Example

```dart
login(AuthRepository repository)
```

Useful sometimes.

But not for permanent dependencies.

---

# Constructor Injection Wins

You'll see this almost everywhere.

Because

* dependencies never become null

* object is complete immediately

* easier testing

* immutable

---

# How your project already uses DI

Look at your `main.dart`.

```dart
final dioClient = DioClient();

final authRepository = AuthRepository(
    dioClient: dioClient,
);

final authProvider = AuthProvider(
    authRepository,
);
```

That's Dependency Injection.

You already use it.

You just didn't know its name.

---

Then

```dart
ChangeNotifierProvider(

    create: (_)

    => authProvider,

)
```

Flutter injects the provider into the widget tree.

Another form of DI.

---

# But there's a problem...

Imagine

20 repositories.

Your main.dart becomes...

```dart
final dio = DioClient();

final authRepository = AuthRepository(dio);

final riderRepository = RiderRepository(dio);

final orderRepository = OrderRepository(dio);

final paymentRepository = PaymentRepository(dio);

final notificationRepository = NotificationRepository(dio);

final analyticsRepository = AnalyticsRepository(dio);

...
```

Then

```dart
final authProvider ...

final riderProvider ...

final orderProvider ...

final paymentProvider ...

...
```

Soon

main.dart becomes

700 lines.

Not nice.

---

# Enter Service Locator

Instead of creating objects manually...

We create them once.

Later...

Anybody can ask for them.

Think of a hotel reception.

You don't know

which room your friend is in.

You ask reception.

Reception knows.

The Service Locator works the same way.

---

The most popular Flutter package

```text
get_it
```

Think of it as

Flutter's reception desk.

---

# Without get_it

```dart
final dio = DioClient();

final repo = AuthRepository(
    dioClient: dio,
);

final provider = AuthProvider(repo);
```

---

With get_it

You register once.

```dart
getIt.registerSingleton(
    DioClient(),
);
```

Later

Anywhere.

```dart
final dio = getIt<DioClient>();
```

Magic.

---

# Registering Services

Suppose

```dart
final storage = TokenStorage();
```

Instead

```dart
getIt.registerSingleton(
    TokenStorage(),
);
```

Now anywhere

```dart
getIt<TokenStorage>()
```

returns the same object.

---

# Singleton

Created once.

Lives forever.

Example

```text
DioClient

TokenStorage

Logger

SharedPreferences

Analytics
```

These should usually be singletons.

---

# Factory

Creates a new object every time.

Example

```dart
registerFactory(
    () => AuthProvider(),
)
```

Every request

gets a fresh provider.

---

# Lazy Singleton

Best of both worlds.

Object isn't created

until first use.

```dart
registerLazySingleton(

    () => DioClient(),

);
```

Nothing happens immediately.

Only when needed.

Saves memory.

---

# Which one should you use?

| Object            | Type           |
| ----------------- | -------------- |
| DioClient         | Lazy Singleton |
| TokenStorage      | Lazy Singleton |
| SharedPreferences | Lazy Singleton |
| Logger            | Singleton      |
| AuthRepository    | Lazy Singleton |
| RiderRepository   | Lazy Singleton |
| AuthProvider      | Factory        |
| RidersProvider    | Factory        |

---

# Why Providers are Factories

Providers hold UI state.

Imagine

loading

error

selected item

search text

scroll position

Those shouldn't be shared forever.

Each screen gets its own provider.

---

# Why Repositories are Singletons

Repositories don't store UI state.

They're services.

One instance is enough.

---

# Why DioClient is Singleton

Imagine

10 DioClients.

Each one has

* interceptors

* connections

* configuration

Wasteful.

One DioClient.

Everyone shares it.

---

# The Dependency Tree

Professional apps look like this.

```text
TokenStorage

↓

AuthInterceptor

↓

DioClient

↓

Repositories

↓

UseCases

↓

Providers

↓

UI
```

Notice something.

Everything points downward.

Never upward.

---

# A Common Beginner Mistake

```dart
class AuthRepository {

    final provider = AuthProvider(...);

}
```

Repository depending on Provider.

Huge mistake.

Repositories should never know about UI.

---

Correct

```text
UI

↓

Provider

↓

UseCase

↓

Repository

↓

Data Source
```

Only downward.

Never reverse.

---

# Another Mistake

Creating dependencies inside build methods.

```dart
Widget build(context){

    final repo = AuthRepository();

}
```

Every rebuild

creates another repository.

Very expensive.

---

# Rule

Never create long-lived services inside

```dart
build()
```

Create them once.

Inject them.

---

# Testing Becomes Easy

Suppose

Backend is offline.

Instead of

```dart
AuthRepository()
```

You inject

```dart
FakeAuthRepository()
```

The Provider never notices.

Testing becomes simple.

---

# Your Swiss Logistics App

Your current project already does several things correctly:

✔ Constructor Injection

```dart
AuthRepository(dioClient: dioClient)
```

✔ Provider Injection

```dart
ChangeNotifierProvider
```

✔ Shared DioClient

```dart
final dioClient = DioClient();
```

That's a strong foundation.

As the app grows, you'll likely replace manual wiring in `main.dart` with `get_it` or another DI framework.

---

# Chapter Summary

Today you learned:

* What Dependency Injection really means.
* What a dependency is.
* Why creating objects inside classes is a bad habit.
* Constructor Injection vs Property Injection vs Method Injection.
* Why Constructor Injection is preferred.
* Singleton, Lazy Singleton, and Factory lifecycles.
* Why `get_it` exists.
* How to choose which objects should be singletons and which should be factories.
* How Dependency Injection improves testing, maintenance, and scalability.

Most importantly, you discovered that **you've already been using Dependency Injection**—now you understand the principles behind it.

---

# Up Next (Volume 2 — Chapter 3)

## **State Management for Authentication: Thinking Like Flutter Instead of React**

In the next chapter, we'll go beyond simply using `Provider`. You'll learn:

* What "state" actually is.
* Why widgets rebuild.
* How `ChangeNotifier` works internally.
* When to call `notifyListeners()`.
* Common mistakes that cause unnecessary rebuilds.
* How to organize authentication state professionally.
* Why experienced Flutter developers think about state before they write UI.

This chapter will help you stop treating Provider as "magic" and start understanding exactly what happens when your app updates.
