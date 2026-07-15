# Flutter Authentication Masterclass

# Volume 1 – Foundation

# Chapter 3: Building the Network Layer (Dio + Repository)

> **Goal of this chapter**
>
> By the end of this chapter you will understand:
>
> * what Dio actually is
> * why every app needs a network layer
> * why we don't call the API directly from the UI
> * how repositories work
> * how data flows through the app
> * exactly what files to create
> * exactly what each file is responsible for
> * why this architecture is used by professional Flutter developers

---

# Before we start...

Let's pretend your Flutter app is a restaurant.

The customer wants food.

Who does he talk to?

Not the chef.

He talks to the waiter.

The waiter talks to the chef.

The chef cooks.

The waiter brings the food back.

Your Flutter app works exactly like that.

```
UI
 ↓
Provider
 ↓
Repository
 ↓
Dio
 ↓
Internet
 ↓
Backend Server
```

Each layer has one job.

---

# The biggest mistake beginners make

Most beginners write something like this.

```dart
ElevatedButton(
  onPressed: () async {
    final response = await Dio().post(
      "https://example.com/login",
      data: {...},
    );
  },
)
```

It works.

But it is terrible architecture.

Why?

Because now

The UI

* knows the API
* knows the URL
* knows Dio
* knows networking

Imagine changing your server.

You'll edit 40 screens.

Professional apps NEVER do this.

---

# The Professional Architecture

Instead of

```
UI
 ↓
Internet
```

We build

```
UI
 ↓
Provider
 ↓
Repository
 ↓
Dio Client
 ↓
Internet
```

Every layer has one responsibility.

---

# Meet Dio

Think of Dio as your app's browser.

Whenever your app wants something from the internet,

Dio is the one that goes.

```
Flutter
     ↓
   Dio
     ↓
 Backend
```

Without Dio,

Flutter cannot communicate with your server.

---

# Why not use http package?

Flutter already has

```
http
```

package.

So why does everyone use Dio?

Because Dio provides

✅ Interceptors

✅ Token Injection

✅ Logging

✅ Timeouts

✅ Retry

✅ File Upload

✅ Download Progress

✅ Better Error Handling

Everything needed for real apps.

---

# Folder Structure

Inside

```
lib
```

create

```
core/
    constants/
    network/
        interceptors/
    storage/

features/
    auth/
        repository/
```

---

# File 1

## api_constants.dart

Purpose

Stores every endpoint.

Never hardcode URLs everywhere.

Instead of

```dart
"https://myapi.com/login"
```

we write

```dart
ApiConstants.login
```

Example

```dart
class ApiConstants {

  static const baseUrl =
      "https://swiss-logistics.onrender.com/api/v1/";

  static const login = "auth/login/";

  static const register = "auth/register/";

  static const currentUser = "auth/me/";

  static const refresh = "auth/refresh_token/";

}
```

---

# Why?

Imagine the backend changes

```
api/v1
```

to

```
api/v2
```

Without constants

You edit

40 files.

With constants

You edit

ONE line.

---

# File 2

## dio_client.dart

This is the heart of networking.

Its job

* create Dio
* configure Dio
* attach interceptors
* define timeout
* define base URL

Nothing else.

Example

```dart
class DioClient {

  late final Dio dio;

  DioClient(){

      dio = Dio(
        BaseOptions(
          baseUrl: ApiConstants.baseUrl,
        ),
      );

  }

}
```

Notice

It does NOT login.

It does NOT register.

It only prepares Dio.

Think of it as

Buying the delivery bike.

The bike hasn't delivered anything yet.

---

# Base URL

Without Base URL

Every request becomes

```dart
https://swiss-logistics.onrender.com/api/v1/login/

https://swiss-logistics.onrender.com/api/v1/register/

https://swiss-logistics.onrender.com/api/v1/me/
```

Repeating this

100 times.

Instead

Set

```dart
baseUrl
```

once.

Then later

```dart
dio.post(ApiConstants.login)
```

Dio automatically combines them.

```
baseUrl

+

login endpoint

=

final URL
```

---

# Timeouts

Example

```dart
connectTimeout:
receiveTimeout:
```

These protect your app.

Imagine

Internet dies.

Without timeout

The loading spinner spins forever.

With timeout

After

15 seconds

Flutter says

"Connection timed out."

Much better.

---

# File 3

Pretty Dio Logger

This is only for developers.

It prints

```
Request

Headers

Body

Response

Errors
```

Like you saw

```
POST

Status 200

Response

Access Token

Refresh Token
```

Without Logger

Debugging becomes very difficult.

---

# File 4

Repository

This is where beginners usually get confused.

Let's simplify.

Suppose someone presses

Login.

Should Provider know

```
POST

https://...
```

No.

Provider shouldn't know.

Repository knows.

Provider simply says

```
Login this user.
```

Repository says

```
Okay.
I'll call the API.
```

---

# Think of Repository like this

Restaurant

```
Customer

↓

Waiter

↓

Chef
```

Customer

doesn't enter the kitchen.

Provider

doesn't touch Dio.

Repository is the waiter.

---

# Example Login

Repository

```dart
Future<Map<String,dynamic>> login({

required String email,
required String password,

}) async {

final response = await dioClient.dio.post(

ApiConstants.login,

data:{

"email":email,

"password":password,

},

);

return response.data;

}
```

Notice

Repository never updates UI.

Never shows SnackBar.

Never changes screens.

Its only job

Talk to API.

---

# Register

Almost identical.

```dart
register(...)
```

↓

POST

↓

return response.data

Done.

---

# Get Current User

```dart
dio.get(
ApiConstants.currentUser,
);
```

Again

Repository only fetches data.

Nothing more.

---

# Why Repository Exists

Without repository

Provider becomes

500 lines long.

With repository

Provider becomes cleaner.

---

Instead of

```
Provider

↓

Dio

↓

API
```

You get

```
Provider

↓

Repository

↓

Dio

↓

API
```

---

# Data Flow

When user presses Login

```
Button
```

↓

calls

```
AuthProvider.login()
```

↓

Provider calls

```
Repository.login()
```

↓

Repository calls

```
Dio.post()
```

↓

Dio sends request

↓

Backend

↓

returns JSON

↓

Repository returns JSON

↓

Provider updates state

↓

UI rebuilds

---

Visual

```
User

↓

Button

↓

Provider

↓

Repository

↓

Dio

↓

Backend

↓

Repository

↓

Provider

↓

notifyListeners()

↓

Consumer

↓

Screen updates
```

That flow happens almost everywhere in Flutter apps.

---

# Why Provider doesn't know Dio

Because tomorrow

Imagine

Backend changes.

You only modify Repository.

UI remains untouched.

This is called

**Separation of Concerns.**

Each class has only ONE responsibility.

---

# Why Repository doesn't know Widgets

Repository should work even if there is

No UI.

You could even call it from

Tests

Console

Background Service

Because it has no dependency on Flutter widgets.

---

# Common Beginner Mistakes

## Mistake 1

Calling Dio inside Widget

❌ Wrong

---

## Mistake 2

Putting URLs inside Provider

❌ Wrong

---

## Mistake 3

Using multiple Dio instances

❌ Wrong

Use one shared `DioClient`.

This is exactly what you fixed in your Swiss Logistics project.

---

## Mistake 4

Hardcoding URLs

❌ Wrong

Use

```
ApiConstants
```

---

## Mistake 5

Putting business logic inside UI

Wrong

UI should only display data.

---

# What You Should Have After This Chapter

By now your project should contain something close to this:

```
lib/
│
├── core/
│   ├── constants/
│   │   └── api_constants.dart
│   │
│   ├── network/
│   │   ├── dio_client.dart
│   │   └── interceptors/
│   │
│   └── storage/
│
├── features/
│   └── auth/
│       └── repository/
│           └── auth_repository.dart
```

And the flow should be:

```
UI
 ↓
Provider
 ↓
Repository
 ↓
DioClient
 ↓
Backend
```

---

# Chapter Summary

In this chapter, you learned that:

* **Dio** is the networking engine that sends HTTP requests.
* **ApiConstants** stores URLs and endpoints in one place for easy maintenance.
* **DioClient** creates and configures a single shared Dio instance.
* **PrettyDioLogger** helps you see every request and response while developing.
* **Repository** is the only layer that should communicate with the API.
* The UI should never know about URLs or Dio.
* Data always flows through the layers in this order:

```
UI
 ↓
Provider
 ↓
Repository
 ↓
DioClient
 ↓
Backend
```

This architecture keeps your app organized, testable, and easy to maintain as it grows.

---

## Up Next — Chapter 4

**Secure Token Storage (Flutter Secure Storage)**

In the next chapter, we'll cover one of the most important parts of authentication:

* What JWT access and refresh tokens are.
* Why you should never store tokens in SharedPreferences.
* How `flutter_secure_storage` protects your users.
* Building `TokenStorage` from scratch.
* Saving, reading, updating, and deleting tokens.
* Understanding token lifecycles and expiration.
* Preparing the app for automatic token refresh.

This chapter will connect directly to the authentication flow you've already built and set the foundation for interceptors and automatic re-authentication.
