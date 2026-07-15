# Flutter Authentication Masterclass

# Volume 1 – Foundation

# Chapter 4: Secure Token Storage (Flutter Secure Storage)

> **Goal of this chapter**
>
> By the end of this chapter, you will understand:
>
> * What authentication tokens really are.
> * Why we use Access Tokens and Refresh Tokens.
> * Why tokens expire.
> * Why `flutter_secure_storage` exists.
> * Why you should never use SharedPreferences for tokens.
> * How to build `TokenStorage`.
> * How tokens move around your application.
> * When to save, read, update, and delete tokens.
> * What should happen after login, app restart, logout, and token expiration.

---

# Before We Start...

Imagine you live in a secured estate.

Every morning, the security guard asks:

> "Who are you?"

If you have no ID card...

❌ You cannot enter.

If you have a valid ID card...

✅ You enter immediately.

Your backend works exactly like this.

---

# What happens after Login?

When you send

```text
Email
Password
```

to the backend,

the backend checks if they are correct.

If they are correct...

the backend DOES NOT remember you.

Instead...

it gives you two digital ID cards.

Example:

```json
{
   "access": "eyJhbGc...",
   "refresh": "eyJhbGc..."
}
```

These are called

* Access Token
* Refresh Token

---

# Think of them like this

Access Token

↓

Your visitor's pass.

Refresh Token

↓

Your permanent ID card.

---

## Access Token

Used for almost every request.

Example

```text
Get Profile

Get Riders

Create Delivery

Update Profile

Upload Image
```

Every request carries

```text
Authorization

Bearer ACCESS_TOKEN
```

The backend checks it.

If valid

↓

Returns data.

---

## Refresh Token

The refresh token is special.

You NEVER send it with every request.

You only use it when

the Access Token expires.

Think of it like this:

---

Security Guard

> "Your visitor pass has expired."

You reply

> "Here's my permanent ID."

The guard checks it.

If valid...

He gives you

a NEW visitor pass.

Exactly how refresh tokens work.

---

# Why not make Access Token last forever?

Imagine someone steals your phone.

If your token never expires,

the thief can access your account forever.

Bad.

Instead

Backend says

```text
Access Token

15 minutes

30 minutes

1 hour
```

After that

Expired.

Even if stolen

It becomes useless.

---

# Why not use Refresh Token for everything?

Because

Refresh Tokens usually last

```text
7 days

30 days

90 days
```

Much longer.

They are more powerful.

That's why

they are only used to request

new Access Tokens.

---

# Life Cycle of Tokens

```text
User logs in

↓

Backend returns

Access Token

+

Refresh Token

↓

Flutter saves both securely

↓

User uses app

↓

Access Token expires

↓

Flutter sends Refresh Token

↓

Backend returns NEW Access Token

↓

Flutter replaces old Access Token

↓

User continues using app
```

The user never notices anything.

---

# Where should Flutter save them?

This is one of the most important decisions in your app.

Many beginners do this

```dart
SharedPreferences
```

Don't.

---

# Why not SharedPreferences?

Imagine your phone stores

```text
Username

Theme

Language

Dark Mode
```

These are harmless.

If someone reads them,

nothing serious happens.

Now imagine

```text
Access Token

Refresh Token
```

If someone steals them,

they can log into your account.

That's dangerous.

---

# Flutter Secure Storage

Flutter provides

```text
flutter_secure_storage
```

This uses

Android

↓

Encrypted Shared Preferences / Keystore

iPhone

↓

Keychain

Meaning

Your tokens are encrypted.

Even if someone opens your phone's storage,

they cannot easily read them.

---

# Installing

```yaml
dependencies:
  flutter_secure_storage: ^9.2.2
```

Then

```bash
flutter pub get
```

Done.

---

# Folder Structure

Create

```text
lib/

core/

storage/

token_storage.dart
```

Notice

Storage belongs inside

Core.

Why?

Because

every feature

Auth

Orders

Profile

Payments

may need tokens.

---

# Building TokenStorage

Inside

```text
token_storage.dart
```

Create

```dart
class TokenStorage {

}
```

This class has ONE responsibility.

Manage tokens.

Nothing else.

---

# Inside TokenStorage

First

create

```dart
FlutterSecureStorage
```

```dart
static const _storage =
FlutterSecureStorage();
```

This becomes your secure locker.

---

# Create Keys

```dart
static const _keyAccessToken =
'access_token';

static const _keyRefreshToken =
'refresh_token';
```

Think of keys as labels.

Without labels,

Flutter won't know

where each token is stored.

---

# Saving Tokens

When should this happen?

Immediately after

Login

or

Registration.

Remember this.

Backend

↓

returns

```json
{
"access":"...",
"refresh":"..."
}
```

Immediately save both.

Example

```dart
saveToken(
accessToken,
refreshToken,
)
```

Your app should NEVER delay this.

If the app crashes before saving,

the user must login again.

---

# Reading Access Token

Soon,

your AuthInterceptor

will need the token.

So

we create

```dart
getAccessToken()
```

Every time

Dio makes a request

↓

Interceptor asks

```text
TokenStorage

↓

Do we have an Access Token?
```

If yes

↓

Attach it.

---

# Reading Refresh Token

Only used when

Access Token expires.

Example

```dart
getRefreshToken()
```

Notice

This function is rarely called.

Most requests don't need it.

---

# Updating Access Token

Imagine

Access Token expires.

Backend returns

```json
{
"access":"NEW_TOKEN"
}
```

We do NOT overwrite everything.

Only replace

the Access Token.

That's why

we created

```dart
saveAccessToken()
```

Instead of

saving both again.

---

# Logging Out

When user presses

Logout

Delete everything.

```dart
clearTokens()
```

After logout

Phone should contain

No tokens.

Nothing.

---

# What happens after Login?

Let's follow the complete journey.

User presses

Login

↓

Provider calls Repository

↓

Repository calls API

↓

Backend responds

↓

```json
{
"user":{},
"access":"...",
"refresh":"..."
}
```

↓

Repository calls

```dart
saveToken()
```

↓

TokenStorage saves both.

↓

Provider updates state.

↓

Navigate Home.

---

# What happens after App Restart?

Imagine

User closes app.

Everything in RAM disappears.

But

Flutter Secure Storage

still contains

```text
Access Token

Refresh Token
```

Next time

App opens.

AuthProvider asks

```text
TokenStorage

↓

Do we have an Access Token?
```

If yes

↓

Call

```text
GET /auth/me
```

If successful

↓

User is still logged in.

Beautiful.

---

# What happens when Access Token expires?

Example

```text
User opens app

↓

Clicks Riders

↓

Backend says

401 Unauthorized

↓

Access Token expired
```

Now

Your app does NOT

throw user out.

Instead

It silently does this

```text
Read Refresh Token

↓

POST

/auth/refresh_token/

↓

Receive New Access Token

↓

Save New Access Token

↓

Retry original request

↓

User receives Riders
```

The user never notices.

---

# What happens if Refresh Token also expires?

Now

Backend says

```text
Refresh Token expired.
```

No more recovery.

App must

```text
Delete tokens

↓

Logout

↓

Navigate Login
```

Exactly how Gmail works.

---

# Token Flow

```text
Login

↓

Save Access

↓

Save Refresh

↓

Every request

↓

Read Access

↓

Attach Bearer Token

↓

Access expired

↓

Read Refresh

↓

Get New Access

↓

Save New Access

↓

Continue
```

This is the heartbeat of every authenticated app.

---

# Common Beginner Mistakes

## Mistake 1

Saving tokens in

SharedPreferences

❌ Wrong.

Use

Flutter Secure Storage.

---

## Mistake 2

Saving only Access Token

Wrong.

If you lose Refresh Token,

the user must login every hour.

---

## Mistake 3

Using Refresh Token for API requests

Wrong.

Always send

Access Token.

---

## Mistake 4

Deleting only Access Token

Wrong.

Logout means

Delete EVERYTHING.

---

## Mistake 5

Saving tokens inside Provider

Wrong.

Provider manages UI state.

Storage manages persistence.

Different responsibilities.

---

# Real-Life Analogy

Imagine your wallet.

Inside it

You have

* ATM Card
* National ID

When buying food,

you use

ATM Card.

You don't show

your National ID

everywhere.

Only when the bank asks

to verify you.

Exactly how

Access

and

Refresh Tokens work.

---

# Your Current Swiss Logistics Project

You have already implemented most of this correctly.

Your `TokenStorage` includes:

* ✅ `saveToken()`
* ✅ `saveAccessToken()`
* ✅ `getAccessToken()`
* ✅ `getRefreshToken()`
* ✅ `clearTokens()`

That means your storage layer is already at a professional standard.

The next step is teaching your networking layer how to **automatically use those tokens**, which is where interceptors become powerful.

---

# What You Should Have After This Chapter

Your project structure should now include:

```text
lib/
│
├── core/
│   ├── constants/
│   ├── network/
│   └── storage/
│       └── token_storage.dart
│
├── features/
│   └── auth/
│       ├── repository/
│       └── providers/
```

Your app should be able to:

* ✅ Save tokens after login.
* ✅ Read tokens whenever needed.
* ✅ Update only the Access Token after a refresh.
* ✅ Delete all tokens on logout.
* ✅ Keep users logged in after they reopen the app.

---

# Chapter Summary

In this chapter, you learned:

* **Access Tokens** identify the user for everyday API requests.
* **Refresh Tokens** are used only to obtain a new Access Token after it expires.
* Tokens expire to improve security.
* `flutter_secure_storage` encrypts sensitive information and is the correct place to store tokens.
* `TokenStorage` should be responsible only for storing and retrieving tokens.
* The authentication lifecycle is:

```text
Login
 ↓
Save Tokens
 ↓
Use Access Token
 ↓
Access Expires
 ↓
Use Refresh Token
 ↓
Get New Access Token
 ↓
Continue Working
```

By separating storage from UI and networking, your authentication system remains secure, maintainable, and scalable.

---

# Up Next — Chapter 5

**Authentication Interceptors (The Magic Behind Automatic Login)**

This is where everything starts coming together.

In Chapter 5 you'll learn:

* What an interceptor really is.
* Why every professional Flutter app uses interceptors.
* How your `AuthInterceptor` automatically attaches the Bearer token.
* How `ErrorInterceptor` catches `401 Unauthorized` responses.
* How automatic token refresh works without the user noticing.
* How to retry the original request after refreshing the token.
* How to prevent refresh loops and race conditions.
* Why your Swiss Logistics app needed both `AuthInterceptor` and `ErrorInterceptor`.

This chapter is where your authentication system begins to feel like a production-ready app instead of a simple login screen.
