# **Volume 2 – Building a Production-Ready Flutter Authentication System**

## **Chapter 3: Authentication State Management (The Brain of Your App)**

> **Goal of this chapter**
>
> By the end of this chapter, you'll understand:
>
> * Why AuthProvider exists
> * What "authentication state" means
> * How your entire app knows whether a user is logged in
> * Why GoRouter can redirect automatically
> * Why notifyListeners() is so important
> * How Facebook, Uber, Paystack, Opay and most Flutter apps manage login state

---

# Before we start...

Think about Instagram.

When you open Instagram...

Does every screen check your login status?

No.

The Home page doesn't.

The Profile page doesn't.

The Search page doesn't.

The Reels page doesn't.

Instead...

Instagram has **ONE place** that knows

> "This user is logged in."

Every other page simply asks that one place.

That one place is called the **Authentication State**.

In Flutter...

That's usually your **AuthProvider**.

---

# Imagine this situation

You have 25 screens.

```
Login

Register

Home

Profile

Wallet

Orders

Notifications

Settings

Help

Delivery

Payment

History

Favorites

Chat

Support

...

25 screens
```

Now imagine every screen does this:

```
if(token exists){

show page

}else{

go to login

}
```

Every screen.

Again.

Again.

Again.

Again.

Again.

What happens?

Lots of duplicated code.

Lots of bugs.

Very difficult maintenance.

---

Instead...

Flutter apps do this

```
App

↓

AuthProvider

↓

Every screen asks AuthProvider
```

Much cleaner.

---

# What is Authentication State?

Authentication State is simply

> "Who is currently logged in?"

That's all.

Usually there are only three possibilities.

```
Checking

Authenticated

Unauthenticated
```

Exactly what you already wrote.

```
enum AuthStatus{

checking,

authenticated,

unauthenticated

}
```

Congratulations.

Without realizing it...

You already built the foundation used in professional apps.

---

# Why do we need "checking"?

Many beginners only create

```
LoggedIn

LoggedOut
```

That's not enough.

Imagine opening the app.

Flutter starts.

Can Flutter instantly know whether you're logged in?

No.

It needs to

Read Secure Storage

↓

Get token

↓

Verify token

↓

Load current user

That takes time.

Maybe

300ms

Maybe

2 seconds

Maybe

5 seconds

During that time...

Flutter doesn't know yet.

So we need

```
Checking
```

Your app becomes

```
App opens

↓

Checking...

↓

Load token

↓

Success?

↓

Yes

↓

Authenticated

or

No

↓

Unauthenticated
```

---

# Your AuthProvider is basically a tiny computer

It stores information.

```
class AuthProvider{

UserModel?

bool loading

String? error

AuthStatus status

}
```

Notice something.

This class contains...

The user

The loading state

The error

The login status

Everything related to authentication.

That's why it's called

AuthProvider.

---

# Why not store only the token?

Many beginners think

"I already have the token."

"So why store the user?"

Because every screen needs user information.

Imagine your Home page.

```
Hello Samad
```

Where does "Samad" come from?

The token?

No.

The user object.

Example

```
User

↓

Name

Email

Phone

Photo

Tier

Referral code
```

Much easier.

---

# Life of an AuthProvider

Let's follow it.

App starts.

```
AuthProvider

status

=

checking
```

Then

```
loadUser()
```

runs.

It reads Secure Storage.

If token exists...

```
GET /auth/me
```

If successful

```
currentUser = user

status = authenticated

notifyListeners()
```

Done.

---

If token doesn't exist

```
status = unauthenticated

notifyListeners()
```

Done.

---

# Why notifyListeners()?

Imagine your Provider is a TV station.

Your screens are TVs.

When something changes...

The TV station broadcasts

"Breaking News!"

Every TV updates immediately.

Without notifyListeners()

Nothing changes.

---

Example

```
Login succeeds

↓

Save token

↓

status = authenticated

↓

notifyListeners()

↓

GoRouter hears it

↓

Redirect

↓

Dashboard opens
```

Everything happens automatically.

---

# Without notifyListeners()

Imagine

```
status = authenticated
```

But

No notifyListeners().

Flutter never knows.

GoRouter never knows.

Consumer never rebuilds.

UI never changes.

The user stays on Login.

Even though login succeeded.

That's why notifyListeners() is one of the most important methods in Provider.

---

# What exactly does loadUser() do?

Your version

```
Future<void> loadUser()
```

is doing something like

```
Read access token

↓

Token found?

↓

No

↓

status = unauthenticated

↓

Stop
```

Otherwise

```
Call

GET /auth/me
```

If server returns user

```
currentUser = user

status = authenticated
```

Otherwise

```
logout()
```

Perfect.

That's exactly how many real apps work.

---

# Why call /auth/me?

Some beginners ask

"I already saved the user after login."

Why fetch again?

Because the user data might have changed.

Example

Yesterday

```
Name

Samad
```

Today

User changes it

```
Samuel
```

Your stored data is now outdated.

Calling

```
GET /auth/me
```

always gives the newest version.

---

# Why not trust Secure Storage forever?

Imagine

Yesterday

User logs in.

Today

Admin disables the account.

Your phone still has the token.

If you never ask the server...

The app thinks everything is okay.

But actually...

The account is disabled.

That's why

```
GET /auth/me
```

is important.

---

# The authentication timeline

```
App starts

↓

AuthProvider created

↓

status = checking

↓

loadUser()

↓

Read Secure Storage

↓

Token exists?

↓

No

↓

Unauthenticated

↓

Login page
```

or

```
Token exists

↓

GET /auth/me

↓

Success

↓

Authenticated

↓

Dashboard
```

Simple.

Reliable.

Professional.

---

# How GoRouter uses AuthProvider

Remember

```
refreshListenable: authProvider
```

That means

Whenever

```
notifyListeners()
```

is called...

GoRouter immediately checks

```
redirect()
```

again.

That is why after login

You automatically leave Login.

No extra code.

---

# Why Provider instead of global variables?

Some beginners write

```
User currentUser;
```

Globally.

Very dangerous.

Because

No rebuilds.

No notifications.

No dependency tracking.

Provider solves all of that.

---

# Common beginner mistake

Wrong

```
status = authenticated;

Navigator.push(...)
```

Now your app has two different systems controlling navigation.

Bad idea.

Instead

```
status = authenticated;

notifyListeners();
```

Let GoRouter decide where to go.

Cleaner.

---

# Real-life analogy

Imagine an airport.

There is one central control room.

Every airplane asks the control room.

Not each other.

Your AuthProvider is that control room.

Every page asks it.

```
Am I logged in?

↓

Yes

↓

Continue
```

or

```
No

↓

Go Login
```

---

# Professional Tip

Notice your `AuthProvider` never makes HTTP requests directly.

Instead, it calls:

```
AuthProvider

↓

AuthRepository

↓

DioClient

↓

Server
```

This separation is what makes your app scalable and testable. The provider manages **state**, while the repository manages **data fetching**.

---

# Chapter Summary

By now, you should understand that:

* Authentication state is the single source of truth for login status.
* `AuthProvider` stores the current user, loading state, errors, and authentication status.
* `notifyListeners()` tells the UI and `GoRouter` that something has changed.
* `loadUser()` restores a previous login by reading the saved token and validating it with the server.
* `GET /auth/me` ensures the app always has the latest user information.
* Navigation should react to authentication state instead of manually pushing pages after login.
* Keeping authentication logic centralized makes the app much easier to maintain.

---

## What's Next?

### **Volume 2 – Chapter 4**

# **Dependency Injection & Object Lifetime**

### *Why We Created Only One DioClient, One AuthProvider, and One Repository (and why creating them twice causes mysterious bugs)*

In the next chapter, we'll dive into one of the concepts that separates beginner Flutter developers from intermediate and senior developers: **dependency injection**. We'll explore object creation, shared instances, singleton patterns, and why your earlier issue of accidentally creating multiple `DioClient` instances caused authentication problems. This chapter will make your app architecture much clearer.
