# Volume 1 — Chapter 6

# The Repository Layer (Your Bridge Between Flutter and the Backend)

> **Goal of this chapter:**
>
> By the end of this chapter, you'll understand:
>
> * What a Repository is
> * Why we never call Dio directly from Providers
> * How to create a Repository from scratch
> * How to organize API methods
> * How data flows from API → Repository → Provider → UI
> * Repository best practices used in professional Flutter projects

---

# Before we begin...

Let's remember where we are.

So far we have built:

```
Backend API
      ↑
   Dio Client
      ↑
 Interceptors
      ↑
Repositories   ← (Today's topic)
      ↑
Providers
      ↑
UI
```

Today we're building this layer.

---

# Imagine You're Building Uber

Suppose your app needs to:

* Login
* Register
* Get Profile
* Get Riders
* Book Delivery
* Cancel Delivery
* Update Profile

Question...

Should your HomeScreen directly call Dio?

Like this?

```dart
class HomeScreen {

 Dio dio = Dio();

 dio.get(...)

}
```

No.

Very bad practice.

Why?

Because now your UI knows:

* API URLs
* JSON
* HTTP
* Dio

Your UI has become your backend.

---

Professional apps NEVER do this.

Instead they use a Repository.

---

# What exactly is a Repository?

Very simple definition.

A Repository is a class whose only job is:

> "Talk to the backend."

Nothing more.

Nothing less.

It knows

* which endpoint

* what request body

* query parameters

* response

* model conversion

The Provider doesn't know these things.

The UI definitely shouldn't know these things.

---

Think of it like this.

```
UI
 │
 │
 ▼
Provider
 │
 │
 ▼
Repository
 │
 │
 ▼
Backend API
```

The Provider only says

> "Repository, please get riders."

The Repository figures out HOW.

---

# Real World Analogy

Imagine you're in a restaurant.

You want fried rice.

Do you enter the kitchen?

No.

You tell the waiter.

The waiter tells the chef.

The chef cooks.

The waiter brings food.

```
Customer
     ↓
 Waiter
     ↓
 Chef
```

Flutter equivalent

```
UI
 ↓
Provider
 ↓
Repository
 ↓
Server
```

Repository = Waiter.

---

# Why is Repository Important?

Imagine tomorrow.

Backend developer changes

```
/api/login
```

to

```
/api/v2/login
```

Without Repository...

You'll edit 18 different screens.

With Repository...

Only one file changes.

Done.

---

# Where should Repository live?

Professional folder structure

```
features/

    auth/

        repository/

             auth_repository.dart

    riders/

        repository/

             rider_repository.dart

    deliveries/

        repository/

             delivery_repository.dart

    profile/

        repository/

             profile_repository.dart
```

Every feature gets its own repository.

---

# Creating your first Repository

Suppose we're building Authentication.

Create

```
auth_repository.dart
```

Inside

```dart
class AuthRepository {

}
```

Nothing else.

Repository starts empty.

---

Next...

Repository needs Dio.

How?

Dependency Injection.

```dart
class AuthRepository {

    final DioClient dioClient;

    AuthRepository({
        required this.dioClient,
    });

}
```

Exactly what you did.

Excellent architecture.

---

Why not create Dio here?

Don't do this.

```dart
final dio = Dio();
```

Bad.

Instead

Receive it.

```
main.dart

↓

Create Dio once

↓

Pass it everywhere
```

One Dio instance.

Whole app.

---

# First Repository Method

Let's create Login.

Provider will later call

```dart
repository.login(...)
```

So Repository needs

```dart
Future<Map<String,dynamic>> login({

required String email,

required String password,

}) async {

}
```

---

Inside

```dart
final response =
await dioClient.dio.post(
```

Endpoint

```dart
ApiConstants.login,
```

Body

```dart
data: {

"email": email,

"password": password,

},
```

Return

```dart
return response.data;
```

Done.

---

Notice something.

Repository never says

```
show snackbar

navigate

loading

```

Never.

Repository ONLY returns data.

---

# Repository should never know UI

Bad

```dart
ScaffoldMessenger...
```

Bad

```dart
Navigator.push(...)
```

Bad

```dart
showDialog(...)
```

Repository is not Flutter UI.

It only handles backend communication.

---

# Second Repository Method

Register.

Same pattern.

```dart
Future<Map<String,dynamic>>

register(...)
```

↓

POST

↓

return response.data

Nothing more.

---

# Third Repository Method

Current user.

```dart
Future<UserModel>

getCurrentUser()
```

Notice...

This returns UserModel

instead of

Map.

Why?

Because Repository is allowed to convert JSON into Models.

Example

Backend sends

```
{
 name
 email
 phone
}
```

Repository converts

↓

```dart
UserModel.fromJson(...)
```

Provider receives

```
UserModel
```

Not JSON.

Cleaner.

---

# Another Example

Rider Repository

```dart
Future<RiderResponse>

getRiders(...)
```

Repository

↓

GET

↓

response.data

↓

RiderResponse.fromJson()

↓

Return RiderResponse

Done.

---

# Why convert inside Repository?

Suppose backend sends

```
Map
```

Provider now has to do

```dart
fromJson()
```

Bad.

Provider shouldn't care about JSON.

Repository already knows backend.

Let Repository convert it.

---

Professional Rule

Repository returns

Models

NOT

Raw JSON

whenever possible.

---

# Repository and Token Storage

Sometimes Repository also saves data.

Example

Login.

Backend returns

```
Access Token

Refresh Token
```

Repository can do

```dart
saveAuthData(...)
```

Because

Saving authentication data

belongs to backend communication.

Not UI.

---

Example

```
Backend

↓

Repository

↓

Secure Storage

↓

Done
```

Provider doesn't know HOW tokens are stored.

Only knows

```
repository.saveAuthData()
```

---

# Should Repository call notifyListeners()?

Never.

Repository isn't a Provider.

Wrong

```dart
notifyListeners();
```

Wrong

```dart
isLoading=true;
```

Wrong

```dart
error = ...
```

Repository simply returns data.

---

# Where should Loading be?

Provider.

Example

```
Provider

↓

loading=true

↓

Repository.login()

↓

loading=false

↓

notifyListeners()
```

Correct.

---

# Repository doesn't manage state

Repository

knows

✔ HTTP

✔ JSON

✔ Models

Provider

knows

✔ Loading

✔ Error

✔ UI state

Very important difference.

---

# Error Handling

Should Repository catch every error?

Usually yes.

Example

```dart
try{

...

}catch(e){

rethrow;

}
```

Notice

We don't swallow errors.

We pass them upward.

Provider decides

what to show.

---

# One Repository per Feature

Never do this

```
AppRepository
```

containing

* login

* riders

* delivery

* wallet

* profile

5000 lines.

Instead

```
AuthRepository

DeliveryRepository

WalletRepository

RiderRepository

ProfileRepository
```

Small.

Easy.

Maintainable.

---

# Repository Lifecycle

Example

```
User presses Login

↓

Provider.login()

↓

Repository.login()

↓

POST request

↓

Response

↓

Repository returns data

↓

Provider updates state

↓

notifyListeners()

↓

UI rebuilds
```

This flow should become second nature.

---

# Common Beginner Mistakes

## Mistake 1

Calling Dio inside UI.

Wrong.

---

## Mistake 2

Calling Dio inside Provider.

Wrong.

Provider should use Repository.

---

## Mistake 3

Repository showing Snackbars.

Wrong.

---

## Mistake 4

Repository navigating screens.

Wrong.

---

## Mistake 5

Repository changing loading variables.

Wrong.

---

## Mistake 6

Returning raw JSON everywhere.

Better

Return Models.

---

# Your Mental Model

Whenever you need an API, ask yourself:

**Does this talk to the server?**

If YES →

Repository.

**Does this update app state?**

If YES →

Provider.

**Does this display information?**

If YES →

UI.

That single decision tree will keep your architecture clean.

---

# Professional Folder Structure (Current Progress)

```
lib/
│
├── core/
│   ├── network/
│   │     ├── dio_client.dart
│   │     ├── auth_interceptor.dart
│   │     └── error_interceptor.dart
│   │
│   ├── constants/
│   │     └── api_constants.dart
│   │
│   └── storage/
│         └── token_storage.dart
│
├── features/
│   ├── auth/
│   │     ├── models/
│   │     ├── repository/
│   │     │      └── auth_repository.dart
│   │     ├── providers/
│   │     └── screens/
│   │
│   ├── riders/
│   │     ├── models/
│   │     ├── repository/
│   │     │      └── rider_repository.dart
│   │     ├── providers/
│   │     └── screens/
│   │
│   └── deliveries/
│         ├── repository/
│         ├── providers/
│         └── screens/
│
└── main.dart
```

---

# Chapter Summary

By now, you should understand that:

* A Repository is the only layer that communicates with the backend.
* It uses `DioClient` to send HTTP requests.
* It converts JSON into Dart models before returning data.
* It should never contain UI code (`Navigator`, `SnackBar`, `notifyListeners`, etc.).
* Each feature should have its own repository.
* Providers depend on repositories, and repositories depend on `DioClient`.
* This separation keeps your code modular, testable, and easy to maintain.

---

# End of Chapter 6

## Next Chapter (Chapter 7)

**The Provider Layer (State Management Masterclass)**

This is where everything comes together. We'll cover:

* Why Provider exists
* `ChangeNotifier` explained from scratch
* `notifyListeners()` demystified
* Loading, success, error, and empty states
* Writing providers like a senior Flutter developer
* How data flows from Repository → Provider → UI
* Common Provider mistakes and how to avoid them

This chapter is one of the most important in the entire course because it teaches you how to make your app react to data changes automatically.
