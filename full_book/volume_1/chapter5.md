# Flutter Authentication Masterclass

# Volume 1 – Foundation

# Chapter 5: Authentication Interceptors (The Magic Behind Automatic Login)

> **Goal of this chapter**
>
> By the end of this chapter, you'll understand:
>
> * What an interceptor really is.
> * Why almost every professional Flutter app uses interceptors.
> * How your `AuthInterceptor` works.
> * How your `ErrorInterceptor` works.
> * What happens when a token expires.
> * How automatic token refresh works.
> * Why users don't have to log in every hour.
> * How to retry failed requests.
> * How to avoid infinite refresh loops.
> * The complete request lifecycle.

---

# Before We Start...

Imagine every office building has security.

Every time someone enters,

the security officer checks their ID.

The employee doesn't walk to security and say,

> "Please check my ID."

Security does it automatically.

That's exactly what an interceptor is.

---

# What is an Interceptor?

An interceptor is a piece of code that runs

**before**

or

**after**

every network request.

Think of it as a security guard standing between your app and the internet.

Instead of

```text
Flutter
     ↓
Backend
```

It becomes

```text
Flutter
     ↓
Interceptor
     ↓
Backend
```

Every request passes through it.

---

# Why do we need one?

Imagine your app has

* Profile
* Riders
* Orders
* Wallet
* Notifications
* Chat
* Settings

That's

50 API requests.

Without an interceptor,

you would manually write

```dart
headers: {
  "Authorization": "Bearer token"
}
```

Fifty times.

That is terrible.

---

Instead,

write it once.

The interceptor automatically adds it everywhere.

---

# There are Different Types of Interceptors

Dio has three major ones.

## 1. Request Interceptor

Runs

BEFORE

the request leaves your phone.

Example

```text
Flutter

↓

Interceptor

↓

Add Authorization Header

↓

Backend
```

---

## 2. Response Interceptor

Runs after a successful response.

Example

```text
Backend

↓

200 OK

↓

Interceptor

↓

Flutter
```

---

## 3. Error Interceptor

Runs only when something goes wrong.

Example

```text
401

404

500

Timeout

Network Error
```

This is where automatic token refresh happens.

---

# Your AuthInterceptor

Let's look at what you've already built.

```dart
class AuthInterceptor extends Interceptor
```

This tells Dio,

> "Run this code before every request."

---

Inside

```dart
onRequest(...)
```

you wrote

```dart
final token =
await tokenStorage.getAccessToken();
```

Simple English

↓

Ask secure storage

> "Do we have an access token?"

---

If

```dart
token != null
```

Then

```dart
options.headers["Authorization"]
=
"Bearer $token";
```

Meaning

Attach the token automatically.

---

Now every request becomes

Instead of

```http
GET /riders
```

It becomes

```http
GET /riders

Authorization:
Bearer eyJhbGc...
```

Without touching any screen.

---

# Where does this happen?

Not inside the UI.

Not inside Provider.

Not inside Repository.

Only here

```text
AuthInterceptor
```

Exactly where it belongs.

---

# What happens when Dio sends a request?

Let's follow the journey.

User presses

```text
Load Riders
```

↓

Provider

↓

Repository

↓

Dio

↓

AuthInterceptor

↓

Read Token

↓

Attach Header

↓

Backend

↓

Response

↓

UI

Notice

Nobody manually adds the token.

---

# Why is this so powerful?

Imagine tomorrow

you create

20 new APIs.

You don't touch

Authorization

again.

Interceptor already does it.

---

# The Problem

Everything works.

Until...

One day

Access Token expires.

Backend replies

```http
401 Unauthorized
```

Now what?

---

Without ErrorInterceptor

App crashes.

User sees

```
Unauthorized
```

Not professional.

---

Instead

We intercept the error.

---

# Meet ErrorInterceptor

Its job

is to catch errors

BEFORE

Flutter sees them.

Think of it as

Customer Service.

Instead of showing an ugly error,

it tries to fix the problem.

---

# Example

Backend replies

```text
401
```

ErrorInterceptor asks

Why?

If

```text
Access Token expired
```

↓

Refresh it.

↓

Retry request.

↓

Return data.

The user never notices.

---

# The Complete Flow

```text
User presses Riders

↓

GET /riders

↓

Access Token attached

↓

Backend

↓

401

↓

ErrorInterceptor

↓

Read Refresh Token

↓

POST /refresh_token

↓

Receive New Access Token

↓

Save New Access Token

↓

Retry Original Request

↓

200 OK

↓

UI updates
```

That entire process usually takes

less than

500 milliseconds.

---

# What is Retrying?

Suppose this failed

```http
GET /riders
```

Don't ask the user to press

Refresh

again.

Instead

Run

the exact same request

again.

That's called

Retrying.

---

Original request

↓

401

↓

Refresh

↓

Retry

↓

Success

---

# How do we retry?

Dio gives us

```dart
RequestOptions
```

Think of this as

a copy

of the original request.

Inside it

everything is stored.

```text
URL

Method

Headers

Body

Query Parameters
```

So instead of rebuilding the request,

we simply resend it.

---

Example

Original

```http
GET

/riders?page=1
```

Dio remembers

```text
GET

/riders

page=1
```

After refreshing

We send

the same request again.

---

# Updating the Header

Remember

The old request contains

Old Token.

Before retrying

Replace

```text
Authorization

Bearer OLD_TOKEN
```

with

```text
Authorization

Bearer NEW_TOKEN
```

Otherwise

you'll receive another

401.

---

# Saving the New Token

Backend returns

```json
{
"access":"NEW_ACCESS_TOKEN"
}
```

Immediately call

```dart
saveAccessToken()
```

Don't wait.

Future requests should already use the new token.

---

# Why only save Access Token?

Because

Refresh Token

didn't change.

No need to overwrite it.

---

# What if Refresh Token has also expired?

Now backend replies

```text
Refresh Token expired
```

No recovery.

Immediately

```text
Delete Tokens

↓

Logout

↓

Navigate Login
```

Exactly how banking apps work.

---

# Infinite Loop Problem

Imagine

Refresh request

also returns

401.

Your ErrorInterceptor says

Refresh again.

↓

401.

↓

Refresh again.

↓

401.

↓

Forever.

Boom.

Infinite loop.

---

How do professionals solve this?

Never intercept

the refresh request itself.

Example

If request URL is

```text
/auth/refresh_token/
```

and it fails

Don't retry.

Logout immediately.

---

# Another Problem

Imagine

Five API calls happen together.

All five

receive

401.

Without protection

All five call

```text
Refresh Token
```

at the same time.

Backend receives

```text
Refresh

Refresh

Refresh

Refresh

Refresh
```

Bad.

---

Professional apps

refresh

only once.

Other requests

wait.

Then continue.

This is called

**Preventing Concurrent Refreshes**.

It's an advanced topic,

but you'll eventually learn it.

---

# Where do we register interceptors?

Inside

```text
dio_client.dart
```

Remember

This file builds Dio.

Perfect place.

Example

```dart
dio.interceptors.add(
AuthInterceptor(...)
);
```

Later

```dart
dio.interceptors.add(
ErrorInterceptor(...)
);
```

Every request

automatically uses them.

---

# Complete Request Lifecycle

```text
Flutter

↓

Repository

↓

Dio

↓

AuthInterceptor

↓

Access Token Added

↓

Backend

↓

200?

↓

Yes

↓

Return Data

OR

↓

401

↓

ErrorInterceptor

↓

Refresh Token

↓

New Access Token

↓

Retry Request

↓

Return Data
```

Beautiful.

---

# Your Swiss Logistics App

You already built

```text
AuthInterceptor
```

which automatically attaches

```text
Bearer ACCESS_TOKEN
```

Earlier,

you saw

```
401 Token expired
```

That happened because

your app knew how to

attach tokens,

but it didn't yet know

how to

refresh them automatically.

After adding the refresh logic,

that problem disappears for users.

---

# Common Beginner Mistakes

## Mistake 1

Adding Authorization header manually.

Wrong.

Use AuthInterceptor.

---

## Mistake 2

Refreshing token inside every Repository.

Wrong.

Repositories shouldn't know anything about authentication.

---

## Mistake 3

Refreshing token inside UI.

Wrong.

The UI should never know tokens expired.

---

## Mistake 4

Retrying forever.

Wrong.

Only retry once.

---

## Mistake 5

Forgetting to replace the Authorization header before retrying.

Old token

↓

401 again.

---

## Mistake 6

Creating multiple Dio instances.

Wrong.

One shared Dio instance means one shared set of interceptors.

---

# Mental Model

Imagine your office building.

```
Employee

↓

Security

↓

Office
```

If ID is valid

↓

Enter.

If ID expired

↓

Visit HR

↓

Get new ID

↓

Return to Security

↓

Enter.

Employee never worries about security procedures.

Exactly how your users should experience authentication.

---

# What You Should Have After This Chapter

By now your networking layer should look like this:

```
core/
│
├── network/
│   ├── dio_client.dart
│   └── interceptors/
│       ├── auth_interceptor.dart
│       └── error_interceptor.dart
```

Responsibilities:

* **DioClient** → Creates and configures Dio.
* **AuthInterceptor** → Attaches the access token to every request.
* **ErrorInterceptor** → Handles expired tokens, refreshes them, retries requests, or logs the user out.

---

# Chapter Summary

In this chapter, you learned:

* An **Interceptor** is middleware that runs before or after network requests.
* **AuthInterceptor** automatically attaches the Access Token.
* **ErrorInterceptor** catches `401 Unauthorized` responses.
* Expired Access Tokens can be refreshed using the Refresh Token.
* The original request should be retried after receiving a new Access Token.
* Refresh requests must never refresh themselves, or you'll create an infinite loop.
* Authentication logic belongs in interceptors—not in the UI, Providers, or Repositories.

The full request lifecycle now looks like this:

```
UI
 ↓
Provider
 ↓
Repository
 ↓
Dio
 ↓
AuthInterceptor
 ↓
Backend
 ↓
401?
 ├── No → Return Data
 └── Yes
      ↓
ErrorInterceptor
      ↓
Refresh Token
      ↓
New Access Token
      ↓
Retry Original Request
      ↓
Return Data
```

---

# Up Next — Chapter 6

**Building the Auth Repository**

This is where everything starts connecting.

You'll learn:

* Why repositories are the "brains" between your app and the backend.
* How to design a clean `AuthRepository`.
* How to implement `login()`, `register()`, `logout()`, `getCurrentUser()`, `refreshToken()`, and `saveAuthData()`.
* What each method should return and why.
* Why repositories should never know about widgets or UI.
* How repositories interact with Dio, TokenStorage, and Providers.

Chapter 6 is where you'll begin building a complete, reusable authentication engine that you can copy into almost any Flutter project.
