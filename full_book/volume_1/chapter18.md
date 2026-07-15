# Volume 1 – Authentication Mastery

# Chapter 18: Automatic Token Refresh (Silent Authentication)

> *"The user should never know their access token expired."*

This chapter is where authentication starts to feel like **real production software**.

Most beginners think authentication works like this:

```text
Login

↓

Use App

↓

Token Expires

↓

Login Again
```

That is **not** how professional apps work.

Professional apps work like this:

```text
Login

↓

Use App

↓

Access Token Expires

↓

App Refreshes Token Automatically

↓

User Continues Working
```

The user never notices.

No popup.

No error.

No interruption.

Everything happens silently.

This is called **Silent Authentication**.

---

# Why Do We Even Have Two Tokens?

You already know we receive

```json
{
   "access": "...",
   "refresh": "..."
}
```

But why?

Because each token has a different job.

---

## Access Token

Think of the Access Token as

> A Visitor Pass

Imagine you're entering a company.

Security gives you

```text
Visitor Pass

Valid for 30 minutes
```

After 30 minutes

the pass expires.

You can't enter any more rooms.

---

## Refresh Token

Think of this as

> Your National ID Card

It lasts much longer.

Whenever your visitor pass expires,

you show your ID card,

and security prints a brand-new visitor pass.

Notice something.

You didn't register again.

You didn't fill another form.

You simply exchanged one pass for another.

That is exactly how refresh tokens work.

---

# Why Not Just Make Access Tokens Last Forever?

Imagine someone steals your phone.

If your access token never expires...

The hacker now has

```text
Unlimited access
```

Maybe for years.

Terrible security.

Instead,

Access Tokens are intentionally short-lived.

Examples

```text
5 minutes

15 minutes

30 minutes

1 hour
```

Even if stolen,

they become useless quickly.

---

# Then Why Have Refresh Tokens?

Without refresh tokens,

the user would login every

```text
30 minutes
```

Imagine Instagram asking

```text
Please login again.
```

every hour.

Nobody would use it.

Refresh Tokens solve this.

---

# The Entire Refresh Flow

```text
User Opens App

↓

Access Token Valid

↓

Request Works

↓

...

↓

Access Token Expires

↓

Request Returns 401

↓

Refresh Token Sent

↓

New Access Token Received

↓

Retry Original Request

↓

User Never Notices
```

This is one of the most important diagrams in authentication.

---

# Let's See It In Real Life

Suppose

your app calls

```http
GET /riders/
```

Request

```http
Authorization:
Bearer ACCESS_TOKEN
```

Server responds

```http
401 Unauthorized
```

Body

```json
{
    "detail":
    "Token is expired"
}
```

Should we logout?

Not yet.

---

# Why Not Logout Immediately?

Because

maybe the Refresh Token

is still valid.

Instead,

we first ask

the backend

for a new Access Token.

---

# Refresh Endpoint

Your backend already has

```http
POST

/auth/refresh_token/
```

Body

```json
{
   "refresh":
   "xxxxx"
}
```

Response

```json
{
   "access":
   "yyyyy"
}
```

Notice something.

Only

Access Token

comes back.

Refresh Token

stays the same.

---

# What Happens Inside Dio?

Imagine this request.

```http
GET /riders/
```

Server says

```http
401
```

Dio immediately calls

```dart
onError()
```

inside

```text
ErrorInterceptor
```

This interceptor becomes

the "brain"

of authentication.

---

# What is an Error Interceptor?

You already have

```text
AuthInterceptor
```

Its job is

```text
Before Request

↓

Attach Token
```

Now we'll create

```text
ErrorInterceptor
```

Its job is

```text
Request Failed

↓

Investigate Why
```

---

# ErrorInterceptor Workflow

```text
Request

↓

401

↓

Was Token Expired?

↓

Yes

↓

Refresh Token

↓

Success?

↓

Retry Request

↓

Return Response
```

Beautiful.

---

# Step 1

Receive Error

```dart
@override
Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
)
```

This runs every time

a request fails.

---

# Step 2

Check Status Code

```dart
if (err.response?.statusCode == 401)
```

Only authentication errors matter.

Ignore

```text
404

500

403

502
```

---

# Step 3

Read Refresh Token

```dart
final refresh =
await tokenStorage.getRefreshToken();
```

Possible

```text
refresh = null
```

or

```text
refresh =
eyJhbGc...
```

---

# Step 4

Call Refresh API

```http
POST

/auth/refresh_token/
```

Body

```json
{
   "refresh":
   "xxxxx"
}
```

Server replies

```json
{
   "access":
   "new_token"
}
```

---

# Step 5

Save New Token

```dart
await tokenStorage.saveAccessToken(
    newAccess
);
```

Old

```text
Access Token
```

is replaced.

Refresh Token remains unchanged.

---

# Step 6

Retry The Original Request

This is the coolest part.

Dio remembers

the original request.

Example

```http
GET /riders/
```

Instead of failing,

we simply send it again.

Now

Authorization header

contains

```text
New Access Token
```

Server responds

```http
200 OK
```

User never knows

anything happened.

---

# Visual Flow

```text
GET /riders/

↓

401

↓

Refresh Token

↓

New Access Token

↓

Retry GET /riders/

↓

200 OK
```

Notice

The screen

never changed.

---

# What If Refresh Token Is Expired?

Server replies

```http
401
```

again.

Now

both tokens

are useless.

Only one option remains.

```text
Logout User
```

Delete everything.

Go to Login.

---

# Why Not Keep Trying Forever?

Imagine this.

```text
Access Expired

↓

Refresh Expired

↓

Retry Again

↓

401

↓

Retry Again

↓

401

↓

Retry Again
```

Infinite loop.

Never do this.

Professional apps

refresh only once.

---

# Prevent Refresh Loops

Most apps keep

```dart
bool isRefreshing = false;
```

If another request

fails during refresh,

it waits.

Only one refresh request

should exist

at any moment.

---

# Real Timeline

Imagine

Access Token

expires at

```text
2:00 PM
```

User

presses

```text
Load Riders
```

at

```text
2:05 PM
```

App does

```text
GET /riders

↓

401

↓

Refresh

↓

New Token

↓

Retry

↓

200
```

Time taken

```text
300 milliseconds
```

The user

never notices.

---

# Where Does This Code Live?

Many beginners try

```text
Provider
```

Wrong.

Others use

```text
Repository
```

Still wrong.

Refresh belongs inside

```text
ErrorInterceptor
```

Because

every request

passes through Dio.

One place.

One implementation.

---

# Architecture

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

Retry

↓

Response

↓

UI
```

Notice

Providers don't know

refresh happened.

Repositories don't know

refresh happened.

Only Dio knows.

That is perfect architecture.

---

# How This Connects to Your Swiss Project

Your backend already supports

```http
POST

/auth/refresh_token/
```

You already have

* ✅ Access Token
* ✅ Refresh Token
* ✅ TokenStorage
* ✅ AuthInterceptor
* ✅ DioClient

The only missing piece is

```text
ErrorInterceptor
```

Once you build it,

your authentication becomes production-grade.

---

# Common Beginner Mistakes

### ❌ Mistake 1

Refreshing before every request.

Wrong.

Refresh only after

401 Token Expired.

---

### ❌ Mistake 2

Requesting a new Refresh Token.

Your backend only returns

```json
{
   "access":"..."
}
```

So don't overwrite

the refresh token.

---

### ❌ Mistake 3

Refreshing inside every repository.

Wrong.

One ErrorInterceptor

handles the entire app.

---

### ❌ Mistake 4

Logging out immediately after

Access Token expires.

Always try Refresh first.

---

### ❌ Mistake 5

Retrying forever.

Refresh once.

If it fails,

logout.

---

# Mental Model

Think of authentication like airport security.

```text
Access Token

↓

Boarding Pass
```

Short-lived.

Can expire.

---

```text
Refresh Token

↓

Passport
```

Long-lived.

Used to obtain

a new boarding pass.

---

```text
Logout

↓

Passport Destroyed
```

Now

you must check in

again.

---

# Chapter Summary

After this chapter, you should understand:

* ✅ Why access tokens expire.
* ✅ Why refresh tokens exist.
* ✅ Why professional apps rarely ask users to log in again.
* ✅ How the refresh endpoint works.
* ✅ Why `ErrorInterceptor` is the correct place for refresh logic.
* ✅ How to retry failed requests automatically.
* ✅ How to avoid infinite refresh loops.
* ✅ Why refresh should happen only once per failure.
* ✅ How silent authentication creates a seamless user experience.

---

# 🚀 Next Chapter

## **Chapter 19 – Building a Production-Grade ErrorInterceptor (Complete Code Walkthrough)**

So far, you've learned **the theory** behind silent authentication.

In the next chapter, we'll implement the entire system step by step.

You'll build a real `ErrorInterceptor` that:

* Detects expired access tokens (`401 Unauthorized`).
* Calls `/auth/refresh_token/`.
* Saves the new access token securely.
* Rebuilds the failed request with the new token.
* Retries the request automatically.
* Queues multiple requests while a refresh is already in progress.
* Logs the user out cleanly if the refresh token has expired.

By the end of Chapter 19, you'll have written the same kind of authentication flow used in production Flutter apps at companies of all sizes.
