# Volume 1 – Authentication Masterclass

# Chapter 12: Authentication Architecture for Large Flutter Apps

> **"Good architecture isn't about making today's code work. It's about making next year's code easy to maintain."**

---

This chapter is one of the most overlooked topics among Flutter developers.

Many people can build authentication.

Very few can organize authentication properly.

There's a huge difference.

Imagine two developers.

Developer A writes code that works.

Developer B writes code that works **and** can still be understood after one year.

Professional companies hire Developer B.

Today, you're going to learn why.

---

# What is Software Architecture?

Architecture simply means:

> **How your project is organized.**

Nothing more.

Think about building a house.

Before construction starts, an architect decides:

* Where the kitchen goes
* Where the bedrooms go
* Where the electrical wiring goes
* Where the plumbing goes

If everything is randomly placed...

the house becomes impossible to maintain.

Flutter projects are exactly the same.

---

# Imagine a City

Suppose Lagos had no planning.

Hospitals mixed with airports.

Schools inside shopping malls.

Police stations beside fish markets.

Finding anything would become a nightmare.

Software is no different.

Every file needs a home.

---

# The Biggest Beginner Mistake

Many beginners start like this.

```
lib/

login.dart

register.dart

provider.dart

repository.dart

api.dart

storage.dart

utils.dart

helpers.dart

models.dart

dio.dart

interceptor.dart

constants.dart
```

Everything is mixed together.

It works...

until the project grows.

After six months...

Nobody knows where anything is.

---

# Professional Folder Structure

Instead, professionals organize by **feature**.

```
lib/

core/

features/

shared/

main.dart
```

This immediately tells you:

```
core
```

contains reusable code.

```
features
```

contains business features.

```
shared
```

contains reusable widgets.

Simple.

---

# Understanding "Core"

Core contains code used everywhere.

Example

```
core/

network/

storage/

constants/

utils/

theme/
```

Notice something.

None of these belong to a single screen.

They're shared.

---

## Example

```
core/network/

dio_client.dart

auth_interceptor.dart

error_interceptor.dart
```

Every feature uses networking.

So networking belongs in Core.

---

Likewise

```
core/storage/

token_storage.dart
```

Authentication uses it.

Orders use it.

Profile uses it.

Payments use it.

So it belongs in Core.

---

# Understanding Features

A feature is one business capability.

Examples

```
Authentication

Orders

Profile

Riders

Wallet

Messages

Payments
```

Each becomes its own folder.

```
features/

auth/

profile/

orders/

wallet/

messages/
```

---

Inside each feature

everything related to that feature stays together.

Example

```
features/auth/
```

contains

```
models

provider

repository

screens

widgets
```

Nothing outside authentication goes there.

---

# Professional Authentication Folder

```
features/

auth/

models/

user_model.dart

repository/

auth_repository.dart

providers/

auth_provider.dart

screens/

login_screen.dart

register_screen.dart

forgot_password_screen.dart

verify_otp_screen.dart

reset_password_screen.dart

widgets/

login_form.dart

password_field.dart

social_login_button.dart
```

Everything authentication-related is together.

---

# Why This Is Better

Suppose your boss says

> "Open Forgot Password."

Where do you look?

Easy.

```
features/

auth/

screens/

forgot_password_screen.dart
```

Done.

---

Imagine the beginner project.

You search through

```
40 folders

300 files

500 widgets
```

Just to find one screen.

---

# Every Feature Is Like a Mini App

This idea changes everything.

Instead of thinking

```
One Giant App
```

Think

```
Authentication App

+

Orders App

+

Wallet App

+

Profile App

+

Chat App
```

All living inside one Flutter project.

That's exactly how companies think.

---

# Why Providers Stay Inside Features

Example

```
AuthProvider
```

Who uses it?

Authentication.

Nobody else.

So it belongs here.

```
features/auth/providers/
```

---

Same with

```
OrdersProvider
```

belongs here

```
features/orders/providers/
```

Never mix providers.

---

# Why Models Stay Inside Features

Should

```
UserModel
```

live beside

```
OrderModel
```

No.

Because

Authentication owns UserModel.

Orders own OrderModel.

Wallet owns WalletModel.

Each feature owns its data.

---

# Repository Placement

```
AuthRepository
```

belongs inside

```
features/auth/repository/
```

because only Authentication uses it.

---

# Widgets

Don't dump every widget into one folder.

Instead

```
features/auth/widgets/

login_button.dart

login_form.dart

remember_me_checkbox.dart
```

Authentication widgets stay together.

---

Shared widgets

like

```
PrimaryButton

LoadingSpinner

ErrorView

EmptyState
```

go here

```
shared/widgets/
```

because every feature can reuse them.

---

# The Core Rule

Ask yourself one question.

> **Can another feature use this file?**

If YES

↓

Put it inside Core or Shared.

If NO

↓

Keep it inside its Feature.

This simple question solves almost every folder decision.

---

# The Dependency Flow

One of the biggest architecture lessons is understanding who is allowed to talk to whom.

Here's the professional flow.

```
UI

↓

Provider

↓

Repository

↓

DioClient

↓

Server
```

Never break this rule.

---

# What Should Never Happen

UI calling Repository directly.

```
Screen

↓

Repository
```

Wrong.

---

Provider calling Dio directly.

```
Provider

↓

Dio
```

Wrong.

---

Repository updating Widgets.

Impossible.

Repositories know nothing about Flutter UI.

---

# One Shared DioClient

This is something you already fixed.

Remember when you accidentally created two DioClients?

```
AuthRepository

↓

new DioClient()

RidersRepository

↓

new DioClient()
```

Bad.

Why?

Each one has

```
different interceptors

different settings

different token state
```

Instead

```
main.dart

↓

Create ONE DioClient

↓

Share it everywhere
```

Exactly what Dependency Injection does.

---

# What is Dependency Injection?

Scary name.

Simple idea.

Instead of creating objects yourself...

someone gives them to you.

Example.

Instead of

```dart
class RiderRepository {

   final dio = DioClient();
}
```

Do

```dart
class RiderRepository {

   final DioClient dio;

   RiderRepository(this.dio);
}
```

Now the repository doesn't create anything.

It receives it.

This is called **Dependency Injection (DI).**

---

# Why DI Matters

Imagine changing your API.

Without DI

You edit

```
20 repositories
```

With DI

You edit

```
one place

main.dart
```

Huge difference.

---

# What main.dart Really Does

Many beginners think

```
main.dart
```

starts the app.

It does.

But that's only 10% of its job.

The real responsibility is **assembling the application.**

Think of it like building a LEGO set.

```
Create Dio

↓

Create Repository

↓

Create Provider

↓

Connect everything

↓

Run App
```

That's why many developers call `main.dart` the **Composition Root**.

It composes (builds) the entire application.

---

# The Dependency Tree

Here's what your authentication project currently looks like.

```
main.dart

│

├── DioClient

│      │

│      ├── AuthInterceptor

│      └── ErrorInterceptor

│

├── AuthRepository

│      │

│      └── DioClient

│

├── RiderRepository

│      │

│      └── DioClient

│

├── AuthProvider

│      │

│      └── AuthRepository

│

└── RidersProvider

       │

       └── RiderRepository
```

Everything starts from `main.dart`.

Nothing creates its own dependencies.

That is professional architecture.

---

# What Happens When the App Grows?

Imagine Swiss Logistics becomes huge.

You add:

* Wallet
* Payments
* Notifications
* Live Tracking
* Chat
* Coupons
* Reviews
* Driver Management
* Analytics

Would you create another `DioClient` for each one?

No.

They all share the same networking layer.

That's the beauty of clean architecture.

---

# Architecture Checklist

Whenever you add a new feature, ask yourself:

### 1. Does it have screens?

Create:

```
screens/
```

---

### 2. Does it call APIs?

Create:

```
repository/
```

---

### 3. Does it manage state?

Create:

```
providers/
```

---

### 4. Does it have JSON?

Create:

```
models/
```

---

### 5. Does it have reusable UI?

Create:

```
widgets/
```

---

### 6. Does every feature need it?

If yes:

```
core/

or

shared/
```

---

# Common Architecture Mistakes

❌ Creating multiple `DioClient` instances.

✔ Create one and inject it everywhere.

---

❌ Putting every widget inside `widgets/`.

✔ Feature-specific widgets stay inside the feature.

---

❌ Putting all models in one folder.

✔ Models belong to the feature that owns them.

---

❌ Letting repositories create their own dependencies.

✔ Inject dependencies from `main.dart`.

---

❌ Writing business logic inside widgets.

✔ Business logic belongs in Providers.

---

❌ Mixing authentication code with rider code.

✔ Every feature should own its own files.

---

# Chapter Summary

By the end of this chapter, you now understand:

* What software architecture really means.
* Why Flutter projects should be organized by feature.
* The difference between `core`, `features`, and `shared`.
* Where models, providers, repositories, screens, and widgets belong.
* Why Dependency Injection is essential.
* Why `main.dart` is the application's Composition Root.
* How a single `DioClient` is shared across the app.
* How professional teams structure Flutter projects that scale to hundreds of files.

---

# Up Next: Chapter 13 — Building Authentication from Scratch (A Complete Walkthrough)

This is where everything you've learned comes together.

Instead of explaining concepts individually, we'll build an authentication system **from a completely empty Flutter project**.

You'll learn:

* Which file to create first.
* Why that file comes first.
* Exactly what code to write in each file.
* What you should expect after every step.
* How to know when something is wrong.
* How all the pieces connect together in real time.

By the end of the next chapter, you'll be able to build a professional JWT authentication system without copying tutorials—because you'll understand the reasoning behind every file and every line of code.
