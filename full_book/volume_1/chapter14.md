# Volume 1 – Chapter 14

# Route Protection with GoRouter (Authentication Guards)

> **Goal of this chapter**
>
> By the end of this chapter, you'll understand:
>
> * Why route protection exists
> * What happens when an app starts
> * How GoRouter decides where to send users
> * Why `AuthStatus.checking` is important
> * How `redirect()` works
> * What `refreshListenable` does
> * Why `loadUser()` runs before `runApp()`
> * How professional apps protect private pages
> * How to build this yourself from scratch

---

# What Is Route Protection?

Imagine you own a bank.

The bank has many rooms.

```
Reception

Customer Service

Manager's Office

Vault
```

Anyone can enter Reception.

Only staff can enter the Vault.

Why?

Because some places are protected.

Apps work exactly the same way.

---

Imagine your app.

```
Splash Screen

↓

Login Screen

↓

Dashboard

↓

Profile

↓

Orders

↓

Wallet
```

Should everyone be able to open Dashboard?

No.

Only logged-in users.

That is called **Route Protection**.

---

# What Is a Route?

A route is simply a screen.

Example

```
/login

/dashboard

/profile

/settings
```

Whenever Flutter moves between screens...

It moves between routes.

---

# Without Route Protection

Imagine someone installs your app.

Instead of logging in...

They manually type

```
/dashboard
```

Or

```
Navigator.pushNamed("/dashboard");
```

If your app doesn't protect routes...

Boom.

They're inside.

Even though they never logged in.

Very dangerous.

---

# Professional Apps Do This

Before opening any page...

The app asks

```
"Is this user authenticated?"
```

If YES

```
Dashboard
```

If NO

```
Login
```

Every single time.

---

# Your App Already Does This

Let's look at your router.

```dart
redirect: (context, state) {
```

This is the security guard.

Imagine a security officer standing at every door.

Whenever someone wants to enter...

The guard checks their ID.

---

# How redirect() Works

Every navigation request passes here.

```
User taps Dashboard

↓

GoRouter

↓

redirect()

↓

Allowed?

↓

Yes

↓

Dashboard
```

or

```
User taps Dashboard

↓

redirect()

↓

Not logged in

↓

Login
```

Everything goes through redirect.

---

# Understanding Your Code

You wrote

```dart
final auth = context.read<AuthProvider>();
```

Meaning

"Let me check authentication."

Then

```dart
final isLoggedIn = auth.isAuthenticated;
```

Now router knows

```
true

or

false
```

---

Then

```dart
final aboutToLogin =
state.matchedLocation ==
"/login_and_registration_screen";
```

This checks

"Is the user already trying to open Login?"

Why?

We'll soon see.

---

# First Scenario

User is NOT logged in.

They try opening

```
Dashboard
```

redirect()

checks

```
isLoggedIn

↓

false
```

Immediately

```dart
return "/login";
```

Flutter never opens Dashboard.

Instead

```
Dashboard

↓

Login
```

Automatically.

---

# Second Scenario

User IS logged in.

They try opening Login again.

```
Login

↓

redirect()

↓

Already authenticated

↓

Dashboard
```

Exactly your code.

```dart
if (isLoggedIn && aboutToLogin) {
    return "/dashboard";
}
```

Very professional.

---

# Third Scenario

User already logged in.

Opens Dashboard.

Everything is fine.

redirect()

returns

```dart
return null;
```

Meaning

"No redirection needed."

GoRouter continues normally.

---

# Why Return null?

Many beginners ask this.

Why not

```dart
return "/dashboard";
```

Because the user is already going there.

Returning

```
null
```

means

"Continue."

Think of traffic lights.

Green light.

Just drive.

---

# What Happens When App Starts?

This is the most confusing part for beginners.

Let's slow down.

User taps your app.

Flutter starts.

Now...

Does Flutter know whether the user is logged in?

No.

It hasn't checked yet.

---

# The Three Authentication States

Your app uses

```dart
enum AuthStatus {
 checking,
 authenticated,
 unauthenticated
}
```

This is brilliant.

Let's understand why.

---

# Why Not Just Use bool?

Beginners write

```dart
bool loggedIn;
```

Problem.

App starts.

Hasn't checked storage yet.

What should loggedIn be?

```
true?

false?
```

Neither.

It doesn't know yet.

So we need another state.

```
checking
```

Perfect.

---

Think of airport security.

Before checking passport

```
Unknown
```

After checking

```
Approved

or

Rejected
```

Exactly the same.

---

# App Startup Timeline

Step 1

User opens app.

Status

```
checking
```

---

Step 2

Flutter reads Secure Storage.

```
Access Token?
```

---

Step 3

If token exists

```
GET /auth/me
```

Backend verifies token.

---

Step 4

Provider updates

```
authenticated
```

or

```
unauthenticated
```

---

Now router knows what to do.

---

# Why loadUser() Runs Before runApp()

Your main()

```dart
await authProvider.loadUser();
```

before

```dart
runApp()
```

This is very important.

Imagine if you didn't.

Flutter would build the UI first.

Router immediately checks

```
isAuthenticated
```

Provider still hasn't loaded token.

It thinks

```
false
```

So router sends user

```
Login
```

Then one second later

Provider finishes loading.

Actually...

User WAS logged in.

Now router jumps again.

```
Login

↓

Dashboard
```

User sees screen flickering.

Very ugly.

---

Instead

You wait first.

```
loadUser()

↓

Finished

↓

runApp()
```

Now router already knows the answer.

No flicker.

Professional apps work like this.

---

# What Does loadUser() Actually Do?

Your Provider

```dart
loadUser()
```

First checks

```dart
TokenStorage
```

If no token

```
Unauthenticated
```

Done.

If token exists

It asks backend

```http
GET /auth/me
```

Backend replies

```
Valid
```

or

```
Expired
```

If valid

```
Current User
```

is loaded.

Status becomes

```
authenticated
```

Done.

---

# Why Not Trust Local Storage?

Imagine hacker manually writes

```
Fake Token
```

into storage.

If app trusts storage...

Hacker enters.

Instead

Professional apps always ask backend

```
Is this token valid?
```

Backend decides.

Much safer.

---

# refreshListenable

One of the coolest GoRouter features.

Your code

```dart
refreshListenable:
authProvider
```

What does it mean?

It means

> "Whenever AuthProvider changes...
> run redirect() again."

That's it.

---

Imagine this.

User logs in.

Provider changes

```dart
_status =
authenticated;
```

Provider calls

```dart
notifyListeners();
```

GoRouter hears it.

```
refreshListenable

↓

redirect()

↓

Dashboard
```

No manual navigation required.

---

Without refreshListenable

Login succeeds.

Provider changes.

Router never notices.

User stays on Login page.

Bad experience.

---

# Complete Login Flow

```
User taps Login

↓

Provider.login()

↓

Repository.login()

↓

Backend

↓

Returns Tokens

↓

Save Tokens

↓

Provider Status

authenticated

↓

notifyListeners()

↓

GoRouter refreshes

↓

redirect()

↓

Dashboard
```

Completely automatic.

---

# Logout Flow

User taps

```
Logout
```

Provider

```dart
clearTokens();

_status =
unauthenticated;

notifyListeners();
```

GoRouter refreshes.

redirect()

detects

```
Not Logged In
```

Automatically

```
Dashboard

↓

Login
```

No manual navigation.

---

# Splash Screen Logic

Many apps have this.

```
Splash

↓

Checking...

↓

Logged In?

↓

YES

↓

Dashboard

NO

↓

Login
```

Exactly the same architecture.

Only prettier.

---

# Common Beginner Mistake

They write

```dart
if(login){

Navigator.push(...);
}
```

inside login().

Problem.

Now every login screen must manually navigate.

Very repetitive.

Professional apps let router decide.

Provider only changes state.

Router handles navigation.

Cleaner.

---

# Another Beginner Mistake

Putting

```dart
Navigator.push()
```

inside Repository.

Never.

Repository should never know screens exist.

Repository talks only to APIs.

---

# Responsibilities

Screen

```
Button presses
```

Provider

```
Authentication state
```

Repository

```
HTTP
```

GoRouter

```
Navigation
```

Each has one responsibility.

---

# Professional Flow Diagram

```
App Starts

↓

loadUser()

↓

Token?

↓

No

↓

Unauthenticated

↓

Login


OR


Token Exists

↓

GET /auth/me

↓

Token Valid?

↓

YES

↓

Authenticated

↓

Dashboard

↓

notifyListeners()

↓

GoRouter

↓

redirect()
```

---

# Why This Architecture Scales

Imagine tomorrow you add

```
Admin

Driver

Customer

Dispatcher

Warehouse Manager
```

redirect()

can easily become

```dart
if(admin)

↓

Admin Dashboard

if(driver)

↓

Driver Dashboard

if(customer)

↓

Customer Home
```

No screen changes.

No repository changes.

Only router logic.

That's scalability.

---

# Real-World Analogy

Think about an office building.

Reception checks your ID.

If you're a visitor

```
Visitor Room
```

If you're staff

```
Office Floor
```

If you're the CEO

```
Executive Floor
```

The receptionist doesn't do your job.

She only decides where you may go.

GoRouter works exactly like that.

---

# Complete Authentication Lifecycle

```
App Opens

↓

loadUser()

↓

Token?

↓

Backend Verification

↓

AuthProvider

↓

notifyListeners()

↓

GoRouter

↓

redirect()

↓

Correct Screen
```

Everything flows in one direction.

Simple.

Predictable.

Professional.

---

# Chapter Summary

After completing this chapter, you should understand:

✅ What route protection is

✅ Why every app needs protected routes

✅ How `redirect()` works

✅ Why `return null` is important

✅ Why `AuthStatus.checking` exists

✅ Why `loadUser()` runs before `runApp()`

✅ Why `refreshListenable` automatically updates navigation

✅ How login and logout trigger automatic redirects

✅ Why repositories should never navigate

✅ Why providers should never push screens

---

# What's Next?

## **Volume 1 – Chapter 15: Dio, HTTP Requests, and Networking Architecture**

This is where we'll dissect the networking layer from the ground up. You'll learn:

* What an HTTP client actually is
* Why Dio is more powerful than the `http` package
* How `BaseOptions` work
* How interceptors fit into the request lifecycle
* How requests travel from your app to the backend and back
* How to structure a networking layer that can support dozens of APIs
* Why a single `DioClient` instance is one of the most important design decisions in a Flutter app

By the end of Chapter 15, you'll understand the entire journey of an API request—from a button tap all the way to the server response—and why your `DioClient` is the foundation of every authenticated request.
