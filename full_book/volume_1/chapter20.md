# **Flutter Authentication Masterclass**

## **Volume 1: Building Production-Ready Authentication**

### **Chapter 20 – Handling Multiple Simultaneous 401 Errors (Request Queueing)**

> **Difficulty:** ⭐⭐⭐⭐⭐ (Advanced)
>
> This is the last chapter of Volume 1.

---

# The Problem

Imagine your app has these pages:

* Home
* Notifications
* Profile
* Wallet
* Orders

When the app opens, every page starts requesting data.

```
Home ---------- GET /home
Profile ------- GET /profile
Wallet -------- GET /wallet
Orders -------- GET /orders
Notifications - GET /notifications
```

Now imagine your access token has expired.

Every request returns

```
401 Unauthorized
```

Your interceptor says

> "Oh, token expired."

So every request tries to refresh the token.

That means

```
Request 1
→ refresh token

Request 2
→ refresh token

Request 3
→ refresh token

Request 4
→ refresh token

Request 5
→ refresh token
```

Five refresh requests.

This is BAD.

---

# Why is this bad?

Most backends rotate refresh tokens.

Meaning

```
Refresh Token A
```

is only valid once.

After using it

```
Refresh Token A
```

becomes

```
Refresh Token B
```

The other four refresh requests are still using

```
Refresh Token A
```

So backend replies

```
401
Invalid refresh token
```

Now your app randomly logs users out.

---

This problem happens in almost every beginner authentication system.

---

# The correct solution

Only ONE request should refresh the token.

Every other request should WAIT.

Like this.

```
Home
      \
Profile \
Wallet   > waiting...
Orders  /
Chat   /
```

Only

```
Refresh Token
```

runs once.

After it succeeds

```
new access token
```

is given to everyone.

Then every waiting request retries automatically.

User never notices.

---

# Real-world analogy

Imagine five people enter a hotel.

All their room keys expired.

Bad receptionist:

```
Everyone go to the manager.
```

Five people rush to the manager.

Chaos.

---

Smart receptionist:

```
Wait here.

I'll renew ONE master key.

Then I'll duplicate it for everybody.
```

Much better.

---

# This is called Request Queueing

The first failed request

```
starts refresh
```

Every other request

```
joins queue
```

When refresh succeeds

```
queue resumes
```

---

# The variables you need

Inside your interceptor

```dart
bool _isRefreshing = false;
```

This tells us

```
Is somebody already refreshing?
```

---

Then

```dart
List<RequestOptions> _pendingRequests = [];
```

This stores

```
waiting requests
```

Example

```
GET /home

GET /wallet

GET /profile

GET /orders
```

They all wait here.

---

# Flow Diagram

User opens app

↓

```
5 requests
```

↓

All return

```
401
```

↓

First request

```
_isRefreshing = false
```

↓

Starts refresh

```
_isRefreshing = true
```

↓

Other requests

See

```
_isRefreshing == true
```

↓

Instead of refreshing

they join queue

```
_pendingRequests.add(...)
```

↓

Refresh succeeds

↓

New access token saved

↓

Loop through queue

Retry every request

↓

Clear queue

↓

```
_isRefreshing = false
```

Done.

---

# Pseudocode

```
401

↓

Already refreshing?

YES
↓

Wait

NO

↓

Refresh token

↓

Save new access token

↓

Retry waiting requests
```

---

# Example code structure

```dart
class AuthInterceptor extends Interceptor {

    bool _isRefreshing = false;

    final List<RequestOptions> _pendingRequests = [];

}
```

Notice

We are NOT writing business logic here.

Only state.

---

Then

```dart
if (_isRefreshing) {

   _pendingRequests.add(request);

   return;

}
```

Meaning

```
Someone else is already refreshing.

I'll wait.
```

---

When refresh finishes

```dart
for(final request in _pendingRequests){

    retry(request);

}
```

Then

```dart
_pendingRequests.clear();
```

---

Finally

```dart
_isRefreshing = false;
```

Ready for the next expiration.

---

# What happens if refresh fails?

Very important.

Suppose refresh token expired too.

Backend says

```
401
```

Now you CANNOT retry.

Instead

```
Clear storage

↓

Logout

↓

Go Login
```

Every queued request also fails.

Never keep them waiting forever.

---

# Professional Architecture

```
AuthInterceptor

│

├── Request

├── Response

├── Error

│

├── Refresh Token

│

├── Queue Requests

│

├── Retry Requests

│

└── Logout if refresh fails
```

One interceptor.

Everything centralized.

---

# Common Beginner Mistake #1

Refreshing every request.

```
401

↓

Refresh

↓

401

↓

Refresh

↓

401

↓

Refresh
```

This creates dozens of refresh requests.

---

# Common Beginner Mistake #2

Calling

```
login()
```

instead of

```
refresh()
```

Refresh should NEVER ask the user for password again.

---

# Common Beginner Mistake #3

Not retrying the original request.

Flow becomes

```
401

↓

Refresh success

↓

Nothing happens
```

User still sees

```
No Data
```

because the request wasn't repeated.

---

# Common Beginner Mistake #4

Forgetting to update Authorization header.

Wrong

```
Bearer old_token
```

Right

```
Bearer new_token
```

---

# Common Beginner Mistake #5

Infinite refresh loop.

Example

```
Refresh request

↓

401

↓

Interceptor catches it

↓

Refresh again

↓

401

↓

Refresh again
```

Forever.

Avoid this by skipping the refresh endpoint:

```dart
if (request.path.contains("refresh_token")) {
    return handler.next(error);
}
```

If the refresh endpoint itself returns `401`, stop immediately, clear tokens, and log the user out.

---

# Production Flow

```
App Starts

↓

Access Token

↓

Valid?

↓

YES

↓

API Request

↓

Success

──────────────

NO

↓

401

↓

Refreshing?

↓

YES

↓

Wait

──────────────

NO

↓

Refresh Token

↓

Success?

↓

YES

↓

Save Token

↓

Retry Waiting Requests

↓

Continue App

──────────────

NO

↓

Clear Tokens

↓

Logout

↓

Login Screen
```

---

# Where does this fit in our architecture?

By the end of Volume 1, your authentication flow looks like this:

```
UI
│
▼
AuthProvider
│
▼
AuthRepository
│
▼
DioClient
│
▼
AuthInterceptor
│
├── Add Access Token
├── Detect 401
├── Refresh Access Token
├── Queue Pending Requests
├── Retry Requests
└── Logout on Failure
│
▼
Backend API
```

Notice how the UI (`LoginScreen`, `HomeScreen`, etc.) knows nothing about token refreshing or queueing. That complexity is hidden inside the networking layer, making the rest of your app much simpler.

---

# Chapter Summary

After this chapter, you should understand:

* ✅ Why multiple simultaneous `401 Unauthorized` responses are a problem.
* ✅ Why only one refresh request should be sent at a time.
* ✅ How request queueing prevents race conditions.
* ✅ How to retry queued requests after a successful refresh.
* ✅ Why refresh failures should immediately log the user out.
* ✅ How production apps keep authentication logic centralized inside an interceptor.

---

# 🎉 End of Volume 1

Congratulations! You have completed the first volume of the Flutter Authentication Masterclass.

In Volume 1, you built and understood a complete JWT authentication system—from project architecture and login all the way to secure token refreshing and advanced interceptor behavior. This foundation is strong enough for real production applications.

---

# 📘 Coming in Volume 2 – Advanced Authentication & Security

Volume 2 shifts from **building authentication** to **engineering authentication**. You'll learn patterns used by experienced Flutter developers and large-scale applications.

Topics include:

* Chapter 1 – Clean Architecture for Authentication
* Chapter 2 – Dependency Injection (GetIt / Injectable)
* Chapter 3 – Repository Pattern Deep Dive
* Chapter 4 – DTOs vs Models vs Entities
* Chapter 5 – Error Handling Strategy
* Chapter 6 – Functional Error Handling (Either/Result)
* Chapter 7 – Offline Authentication
* Chapter 8 – Biometric Login (Fingerprint & Face ID)
* Chapter 9 – Social Login (Google, Apple, Facebook)
* Chapter 10 – Two-Factor Authentication (2FA)
* Chapter 11 – Email Verification
* Chapter 12 – Password Reset Flow
* Chapter 13 – Secure Session Management
* Chapter 14 – Multi-device Login Management
* Chapter 15 – Authentication Testing
* Chapter 16 – Security Best Practices
* Chapter 17 – Production Deployment Checklist
* Chapter 18 – Authentication Code Review
* Chapter 19 – Building a Reusable Authentication Package
* Chapter 20 – Building Authentication Like a Senior Flutter Engineer

Volume 2 is where you'll move beyond "making it work" and learn how to design authentication systems that are scalable, maintainable, and secure.
