# Volume 1 – Authentication Mastery

# Chapter 19: Building a Production-Grade ErrorInterceptor (Complete Code Walkthrough)

> *"Knowing what should happen is only half the battle. A senior engineer knows exactly where to write every line of code."*

In the previous chapter, we learned the theory of silent authentication.

Now...

We're going to build it.

Not just "some code."

We're going to understand:

* where every file belongs
* why it belongs there
* why the order matters
* how Dio thinks internally
* how professional Flutter apps implement authentication

By the end of this chapter, you'll be able to build this feature from scratch without memorizing code.

---

# What We Already Have

Let's look at our current architecture.

```text
UI

↓

Provider

↓

Repository

↓

DioClient

↓

AuthInterceptor

↓

Backend
```

When a request fails...

Nothing catches it.

So we need another interceptor.

---

# Updated Architecture

```text
UI

↓

Provider

↓

Repository

↓

DioClient

↓

AuthInterceptor
      │
      ▼
ErrorInterceptor

↓

Backend
```

Notice

Both interceptors live inside Dio.

Neither Provider nor Repository knows they exist.

That is intentional.

---

# Why Doesn't AuthInterceptor Refresh Tokens?

Remember...

AuthInterceptor only runs

**before**

every request.

```text
Request

↓

AuthInterceptor

↓

Server
```

At that moment...

It has no idea whether

the token is valid.

It simply attaches it.

Only after the server responds

can we know

whether it expired.

That is why

ErrorInterceptor exists.

---

# The Responsibility of Each Interceptor

## AuthInterceptor

Job

```text
Before Request

↓

Attach Access Token
```

---

## ErrorInterceptor

Job

```text
After Failure

↓

Fix Authentication

↓

Retry Request
```

Very different responsibilities.

---

# Step 1 — Create the File

Inside

```text
lib/

core/

network/

interceptors/
```

Create

```text
error_interceptor.dart
```

Your project now becomes

```text
interceptors/

├── auth_interceptor.dart

└── error_interceptor.dart
```

Nice and clean.

---

# Step 2 — What Does It Need?

Think first.

To refresh a token,

what information do we need?

Let's list it.

We need

* Dio
* TokenStorage
* Refresh Endpoint

Therefore

the constructor becomes

```dart
class ErrorInterceptor
extends Interceptor {

    final Dio dio;

    final TokenStorage tokenStorage;

    ErrorInterceptor(

        this.dio,

        this.tokenStorage,

    );
}
```

Notice

We inject dependencies.

We never create them inside.

---

# Why Dependency Injection?

Bad

```dart
final dio = Dio();
```

inside the interceptor.

Now you have

two Dio objects.

One sends requests.

One refreshes tokens.

Chaos.

Instead

use the existing Dio.

---

# Step 3 — Override onError()

Every interceptor can override

```dart
onRequest()

onResponse()

onError()
```

We need

```dart
@override
Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
)
```

This method runs

every time

any request fails.

---

# Step 4 — Ignore Non-Authentication Errors

Imagine

```http
404
```

Should we refresh?

No.

---

Imagine

```http
500
```

Refresh?

No.

---

Imagine

```http
401
```

Now we're interested.

So the first thing we do

is

```dart
if (
err.response?.statusCode != 401
) {

    return handler.next(err);

}
```

Everything else

continues normally.

---

# Step 5 — Read Refresh Token

Next

```dart
final refreshToken =
await tokenStorage
.getRefreshToken();
```

Possible values

```text
null
```

or

```text
eyJhbGc...
```

---

# What If Refresh Token Doesn't Exist?

Maybe user manually deleted storage.

Maybe logout happened.

Maybe first app launch.

Then

```dart
if (refreshToken == null) {

    return handler.next(err);

}
```

Nothing to refresh.

---

# Step 6 — Call Refresh Endpoint

Now we ask

the backend

for a new token.

```http
POST

/auth/refresh_token/
```

Body

```json
{
   "refresh":
   refreshToken
}
```

Inside Dio

this becomes

```dart
final response =
await dio.post(

ApiConstants.refresh,

data: {

"refresh": refreshToken

},

);
```

---

# What Do We Expect Back?

Your backend returns

```json
{
    "access":
    "new_access_token"
}
```

Nothing else.

---

# Step 7 — Save the New Access Token

Extract it.

```dart
final newAccess =
response.data["access"];
```

Now overwrite

the old one.

```dart
await tokenStorage
.saveAccessToken(
newAccess,
);
```

Congratulations.

Your app now has

a fresh token.

---

# Step 8 — Update the Failed Request

Remember

the original request?

```http
GET /riders/
```

It failed because

its Authorization header

contains

the old token.

We simply replace it.

```dart
err.requestOptions.headers[
"Authorization"
]
=
"Bearer $newAccess";
```

---

# Step 9 — Retry the Request

This is where

Dio becomes magical.

The failed request

already exists.

Instead of rebuilding it,

we simply reuse it.

```dart
final clonedResponse =
await dio.fetch(
err.requestOptions,
);
```

Notice

No new code.

No duplicate repository.

No duplicate API method.

Just

retry.

---

# Step 10 — Return The New Response

Instead of returning

the old error

we return

the new response.

```dart
return handler.resolve(
clonedResponse,
);
```

The repository

never knows

anything happened.

From its perspective

the request simply succeeded.

---

# What Happens If Refresh Fails?

Imagine

```http
POST

/auth/refresh_token/
```

returns

```http
401
```

Now

both tokens

are invalid.

There is only one option.

```text
Delete Tokens

↓

Login Screen
```

Inside catch

you should

```dart
await tokenStorage.clearTokens();
```

Then

```dart
return handler.next(err);
```

Later

your app redirects

to Login.

---

# The Entire ErrorInterceptor Flow

```text
Request

↓

401

↓

Refresh Token Exists?

↓

No

↓

Return Error

↓

Logout

──────────────

Yes

↓

POST /refresh

↓

Success?

↓

No

↓

Clear Tokens

↓

Logout

──────────────

Yes

↓

Save New Token

↓

Replace Header

↓

Retry Request

↓

Return Success
```

This is exactly how professional apps behave.

---

# Why Use `handler.resolve()` Instead of `handler.next()`?

This is one of the most confusing parts for beginners.

Think of it this way.

If refresh succeeds...

The request is no longer an error.

It has become

```http
200 OK
```

So we don't continue the error.

We replace it

with success.

That's exactly what

```dart
handler.resolve(response);
```

does.

---

# How Does the Repository See This?

Repository writes

```dart
final response =
await dio.get(...);
```

It never knows

that

* token expired
* refresh happened
* request retried

Everything is hidden

inside Dio.

That is beautiful architecture.

---

# Where Do We Register the ErrorInterceptor?

Inside

```text
DioClient
```

After

AuthInterceptor

Add

```dart
dio.interceptors.add(
ErrorInterceptor(
dio,
tokenStorage,
),
);
```

Now

every request

automatically supports

silent authentication.

---

# The Final Flow

```text
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

Server

↓

401

↓

ErrorInterceptor

↓

Refresh

↓

Save Token

↓

Retry

↓

200

↓

Repository

↓

Provider

↓

UI
```

Nobody outside Dio

knows refresh occurred.

Exactly how it should be.

---

# Common Beginner Mistakes

### ❌ Creating a second Dio instance

Always reuse the existing one.

---

### ❌ Refreshing every request

Refresh only after

401 Unauthorized.

---

### ❌ Forgetting to replace Authorization header

Retry would still use

the expired token.

---

### ❌ Returning `handler.next()`

after successful refresh.

Wrong.

Use

```dart
handler.resolve()
```

---

### ❌ Writing refresh logic inside every repository

One ErrorInterceptor

handles

the entire app.

---

# Real-World Note

The implementation you've learned is the **foundation** used in production. Large apps often add a few more features:

* Prevent multiple refresh requests from running at the same time.
* Queue failed requests while one refresh is already in progress.
* Refresh tokens shortly before they expire.
* Handle revoked sessions gracefully across multiple devices.

We'll build those improvements in later chapters.

---

# Chapter Summary

After this chapter, you should understand:

* ✅ Why `ErrorInterceptor` exists.
* ✅ How it differs from `AuthInterceptor`.
* ✅ Why refresh logic belongs in Dio instead of Providers or Repositories.
* ✅ How to call the refresh endpoint.
* ✅ How to save a new access token.
* ✅ How to retry the original request.
* ✅ Why `handler.resolve()` is used after a successful retry.
* ✅ How to register `ErrorInterceptor` inside `DioClient`.

---

# Next Chapter

## **Chapter 20 – Handling Multiple Simultaneous 401 Errors (Request Queueing)**

Imagine your app opens the Dashboard and immediately makes five API requests:

* `/me`
* `/notifications`
* `/wallet`
* `/orders`
* `/riders`

If the access token has expired, all five requests return **401 Unauthorized** at nearly the same time.

Without proper handling, your app will try to refresh the token **five separate times**, causing race conditions, unnecessary network traffic, and possible authentication failures.

In Chapter 20, you'll learn how professional apps ensure that:

* Only **one** refresh request is sent.
* All other failed requests wait patiently.
* Once the new access token arrives, every waiting request is retried automatically.

This is the technique that makes authentication reliable under real-world conditions.
