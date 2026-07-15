# Volume 1 – Chapter 15

# Dio, HTTP Requests, and Networking Architecture

> **Goal of this chapter**
>
> By the end of this chapter, you'll understand:
>
> * What HTTP really is
> * What actually happens when you press a login button
> * Why Dio exists
> * Why professional Flutter apps use one Dio instance
> * What `BaseOptions` are
> * What Interceptors are
> * The complete life cycle of an API request
> * Why repositories never create Dio
> * How your networking layer is structured
> * How to build a networking architecture that can support hundreds of APIs

---

# Before We Start...

Most beginners think this happens:

```text
Flutter

↓

Backend
```

Not exactly.

Many things happen in between.

When you press Login...

Your app sends an HTTP request.

The server processes it.

The server sends back a response.

Flutter receives it.

Flutter converts JSON into objects.

Then your UI updates.

Let's learn every single step.

---

# Imagine Ordering Food

Suppose you're hungry.

You open Uber Eats.

You press

```text
Order Pizza
```

What happens?

Not magic.

The process looks like this:

```text
You

↓

Uber Eats App

↓

Internet

↓

Restaurant

↓

Pizza

↓

Internet

↓

Your App

↓

You
```

Flutter works exactly the same way.

---

# Your App is NOT Talking to the Database

Many beginners think

```text
Flutter

↓

Database
```

Wrong.

Flutter NEVER talks to the database.

Instead

```text
Flutter

↓

Backend API

↓

Database
```

Backend protects the database.

Flutter only talks to APIs.

---

# What Is HTTP?

HTTP simply means

> A language computers use to communicate over the internet.

Think of it as English.

You speak English.

The restaurant understands English.

Both communicate.

Similarly

Flutter speaks HTTP.

Backend understands HTTP.

---

# What Is a Request?

Imagine writing a letter.

```text
Dear Bank,

Please tell me my account balance.

Thanks.
```

You send it.

That's a request.

---

Flutter does exactly this.

```http
GET /auth/me
```

Meaning

> Dear Backend,

Tell me who is logged in.

---

# What Is a Response?

Backend replies.

```json
{
  "name":"Samad",
  "email":"abc@gmail.com"
}
```

That's the response.

---

# Request + Response

Everything on the internet works like this.

```text
Request

↓

Server

↓

Response
```

Google.

Facebook.

Instagram.

Netflix.

Everything.

---

# HTTP Methods

There are many request types.

The most common are:

---

## GET

Meaning

> Give me information.

Example

```http
GET /riders
```

Backend returns

```text
All Riders
```

Nothing changes.

GET only reads.

---

## POST

Meaning

> Create something.

Example

```http
POST /login
```

Backend creates

A login session.

Returns token.

---

## PUT

Meaning

Replace everything.

Example

```http
PUT /profile
```

Replace old profile completely.

---

## PATCH

Meaning

Update only part.

Example

```http
PATCH /profile
```

Change only

Phone Number.

Everything else stays.

---

## DELETE

Meaning

Remove something.

Example

```http
DELETE /address/7
```

Deletes Address #7.

---

# Most Apps Mostly Use

```text
GET

POST

PATCH

DELETE
```

Over and over.

---

# What Is Dio?

Flutter has two popular HTTP libraries.

```text
http package

Dio
```

The http package is simple.

Dio is professional.

Think of them like cars.

http package

```text
Toyota Corolla
```

Reliable.

Simple.

---

Dio

```text
Mercedes S-Class
```

Much more powerful.

---

# Why Developers Love Dio

Because Dio already includes

✔ Timeouts

✔ Interceptors

✔ File Upload

✔ File Download

✔ Automatic JSON

✔ Better Errors

✔ Cancellation

✔ Progress Tracking

Everything.

---

# Your DioClient

You created

```dart
class DioClient
```

This is one of the most important classes in your project.

Why?

Because EVERY request goes through it.

---

Imagine a city's water supply.

Every house gets water from one place.

Not ten places.

Similarly

Every API request should come from ONE Dio instance.

---

# Why Only One Dio?

Imagine this.

Login creates

```text
Dio #1
```

Profile creates

```text
Dio #2
```

Orders creates

```text
Dio #3
```

Notifications creates

```text
Dio #4
```

Each one has different settings.

Different headers.

Different interceptors.

Chaos.

Instead

One shared Dio.

Much cleaner.

---

# Your Architecture

```text
DioClient

↓

One Dio

↓

Entire App
```

Everything uses it.

Repositories.

Providers.

Authentication.

Riders.

Orders.

Payments.

Everything.

---

# BaseOptions

Inside your code

```dart
BaseOptions(
 baseUrl: ...
)
```

This sets defaults.

Imagine buying a new phone.

Before using it

You choose

Language

Time Zone

Wallpaper

Brightness

Default settings.

BaseOptions are exactly that.

---

# Your Base URL

Instead of writing

```text
https://swiss-logistics.onrender.com/api/v1/
```

every time...

You write

```dart
baseUrl
```

Now request becomes

```dart
dio.get("riders/");
```

instead of

```dart
dio.get(
"https://swiss-logistics.onrender.com/api/v1/riders/"
);
```

Cleaner.

---

# connectTimeout

Imagine calling someone.

Phone rings.

Rings.

Rings.

After one minute...

Still nothing.

Eventually you hang up.

That's timeout.

Your app waits

15 seconds.

Then stops.

Otherwise users wait forever.

---

# receiveTimeout

Different.

Connection succeeded.

Backend started working.

But backend never responds.

Your app waits

15 seconds.

Then stops.

Another safety mechanism.

---

# contentType

You used

```dart
application/json
```

Meaning

"I'm sending JSON."

Backend now knows how to read your request.

---

# Life of a Login Request

Let's trace it.

User presses

```text
LOGIN
```

Screen calls

```dart
provider.login()
```

Provider calls

```dart
repository.login()
```

Repository calls

```dart
dio.post()
```

Dio creates

HTTP Request.

---

Before sending...

Interceptors run.

---

Then request travels

```text
Phone

↓

Internet

↓

Render Server

↓

Django

↓

Database
```

Database replies.

Django returns JSON.

Internet sends JSON.

Phone receives JSON.

Repository converts JSON.

Provider updates state.

UI rebuilds.

Complete journey.

---

# What Are Interceptors?

Imagine airport security.

Before entering airplane

Everyone passes security.

Every single passenger.

Not optional.

Interceptors work exactly like that.

Every request passes through them.

Every response passes through them.

---

# Your AuthInterceptor

Before request leaves phone

It checks

```dart
Access Token?
```

If found

It adds

```http
Authorization:

Bearer token
```

Now backend knows who you are.

Without interceptor...

Every repository would manually add token.

Very repetitive.

---

Instead

One interceptor.

Everything automatically gets authenticated.

Professional.

---

# Request Lifecycle

Every request follows this order.

```text
Repository

↓

Dio

↓

Request Interceptors

↓

Internet

↓

Backend

↓

Response

↓

Response Interceptors

↓

Repository
```

Same every time.

---

# PrettyDioLogger

You added

```dart
PrettyDioLogger()
```

This is only for developers.

Users never see it.

It prints

```text
Request URL

Headers

Body

Response

Errors
```

Very useful.

Without it

Debugging becomes difficult.

---

# Repository Never Creates Dio

Notice

```dart
RiderRepository(
 required DioClient
)
```

Excellent.

Repository receives Dio.

It doesn't create it.

Why?

Imagine every repository creating

```dart
Dio()
```

Now

Auth Repository

has one Dio.

Orders Repository

another Dio.

Profile Repository

another Dio.

Interceptors become inconsistent.

One shared Dio is always better.

---

# Why Dependency Injection?

Instead of

```dart
final dio = Dio();
```

inside repository...

You pass it in.

```dart
Repository(dioClient)
```

Benefits:

✔ Easy testing

✔ Easy mocking

✔ One configuration

✔ Shared interceptors

Professional architecture.

---

# JSON Travels Through Layers

Backend returns

```json
{
 "email":"abc@gmail.com"
}
```

Repository receives Map.

Model converts

```dart
UserModel.fromJson()
```

Provider receives

```text
UserModel
```

UI displays

```text
Samad
```

Notice...

UI never touches JSON.

Very important.

---

# Error Handling

Suppose internet disappears.

Dio throws

```text
SocketException
```

Provider catches it.

Updates

```dart
error
```

UI shows

```text
No Internet Connection
```

No crash.

Professional apps always handle errors.

---

# Networking Folder

Your project should eventually look like

```text
core/

    network/

        dio_client.dart

        interceptors/

            auth_interceptor.dart

            error_interceptor.dart

        constants/

            api_constants.dart
```

Every networking file stays together.

Easy to maintain.

---

# Why ApiConstants?

Instead of

```dart
"auth/login/"
```

everywhere...

You use

```dart
ApiConstants.login
```

If backend changes

```text
login/

↓

signin/
```

Only one file changes.

Entire app works.

---

# Complete Networking Architecture

```text
Screen

↓

Provider

↓

Repository

↓

DioClient

↓

AuthInterceptor

↓

Internet

↓

Backend

↓

JSON

↓

Repository

↓

Model

↓

Provider

↓

notifyListeners()

↓

UI
```

This is the path every request follows.

---

# Common Beginner Mistakes

### ❌ Creating Dio everywhere

```dart
Dio();

Dio();

Dio();

Dio();
```

Wrong.

---

### ✅ One shared Dio

```dart
DioClient

↓

Repositories
```

---

### ❌ Hardcoding URLs

```dart
"https://..."
```

everywhere.

---

### ✅ Use ApiConstants

Cleaner.

---

### ❌ Adding Authorization header manually

Inside every repository.

Very repetitive.

---

### ✅ Use AuthInterceptor

Automatic.

---

### ❌ Parsing JSON inside UI

```dart
response["email"]
```

Wrong.

---

### ✅ Convert JSON into Model

```dart
UserModel
```

UI only uses objects.

---

# Real-Life Analogy

Imagine DHL.

You send a package.

It passes through

Collection Center

↓

Sorting Center

↓

Airport

↓

Destination City

↓

Delivery Van

↓

Customer

Networking is identical.

Every request passes through many stages before reaching the server.

---

# Chapter Summary

After completing this chapter, you should understand:

✅ What HTTP is

✅ What requests and responses are

✅ The difference between GET, POST, PATCH, PUT, and DELETE

✅ Why Dio is preferred in professional Flutter apps

✅ Why one shared `DioClient` is essential

✅ What `BaseOptions` configure

✅ The purpose of `connectTimeout` and `receiveTimeout`

✅ How interceptors work

✅ Why `AuthInterceptor` automatically attaches the token

✅ Why repositories receive a `DioClient` instead of creating one

✅ The complete journey of an API request from the UI to the backend and back

---

# Up Next — Chapter 16: Understanding Models, JSON Parsing, and Data Serialization

In the next chapter, we'll focus on one of the most important topics in Flutter development:

* What JSON actually is
* Why APIs send JSON instead of Dart objects
* How `fromJson()` and `toJson()` work
* How to design robust models
* Nested JSON, lists, and optional fields
* Common parsing mistakes
* Best practices for organizing models in a growing codebase

By the end of Chapter 16, you'll be able to confidently turn any API response into clean, strongly typed Dart models and understand exactly why every model in your project is structured the way it is.
