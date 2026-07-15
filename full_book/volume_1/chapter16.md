# Volume 1 – Authentication Mastery

# Chapter 16: Logout Like a Professional

> *"Logging in gets a user into your app. Logging out removes every trace that proves who they are."*

Many beginners think logout is just a button that sends users back to the login screen.

It isn't.

A professional logout process must:

* remove every authentication token
* remove cached user information
* update the application state
* prevent access to protected screens
* optionally tell the server the user logged out

Let's learn how.

---

# What Actually Happens During Logout?

When a user presses **Logout**, this is what should happen.

```
User taps Logout
        │
        ▼
Clear Access Token
        │
        ▼
Clear Refresh Token
        │
        ▼
Clear User Data
        │
        ▼
Update Provider
        │
        ▼
GoRouter notices auth changed
        │
        ▼
Redirect to Login
```

Notice something?

**We never trust the UI.**

The UI is the LAST thing that changes.

The authentication state changes first.

---

# Step 1 — User Presses Logout

Example

```
ElevatedButton(
  onPressed: () {
    context.read<AuthProvider>().logout();
  },
  child: Text("Logout"),
)
```

Nothing complicated.

The UI simply says

> "AuthProvider, please log the user out."

---

# Step 2 — AuthProvider Starts Logout

Example

```dart
Future<void> logout() async {
    await _repository.logout();

    _currentUser = null;

    _status = AuthStatus.unauthenticated;

    notifyListeners();
}
```

Notice the order.

Repository first.

Memory second.

Status third.

Notify last.

---

# Why This Order?

Imagine this

```
User presses Logout
```

If you update the UI first...

```
_status = unauthenticated
notifyListeners()
```

...before deleting tokens...

another request may still use the old token.

Always clear authentication first.

---

# Step 3 — Repository Handles Storage

Repository is responsible for talking to:

* Secure Storage
* API
* Database

Example

```dart
Future<void> logout() async {
    await tokenStorage.clearTokens();
}
```

This removes

```
access_token

refresh_token
```

from secure storage.

Now...

There is nothing left to authenticate future requests.

---

# Why Not Delete Tokens Inside Provider?

Bad

```
Provider

↓

Secure Storage
```

Good

```
Provider

↓

Repository

↓

Storage
```

Provider shouldn't know

* Hive

* SharedPreferences

* SecureStorage

* SQLite

Only Repository knows.

---

# Step 4 — Remove User Data

Many apps keep

```
Current User

Name

Profile Picture

Email

Wallet Balance

Role
```

inside memory.

Example

```dart
_currentUser = null;
```

Now...

No user exists inside memory.

---

# Step 5 — Update Authentication Status

Example

```dart
_status = AuthStatus.unauthenticated;
```

Now your app knows

```
Nobody is logged in.
```

---

# Step 6 — Notify Everyone

Example

```dart
notifyListeners();
```

Every widget using

```
Consumer<AuthProvider>
```

updates automatically.

Examples

Old

```
Welcome Samad
```

becomes

```
Login
```

Profile disappears.

Dashboard disappears.

Protected screens disappear.

---

# Step 7 — GoRouter Reacts

Remember

```
refreshListenable: authProvider
```

When

```
notifyListeners()
```

runs...

GoRouter immediately runs

```
redirect()
```

again.

Now

```
isAuthenticated == false
```

Therefore

```
return "/login";
```

The navigation happens automatically.

You never write

```
context.go("/login");
```

inside logout.

GoRouter handles it.

---

# What Happens If User Presses Back?

Suppose user was here

```
Dashboard
```

Then

```
Logout
```

Then

```
Login Screen
```

If they press

```
Back
```

they should NEVER return here

```
Dashboard
```

Why?

Because

```
redirect()
```

runs again.

```
Not authenticated

↓

Redirect Login
```

Professional apps never allow returning to protected screens.

---

# Should We Call the Backend?

Some APIs provide

```
POST /logout/
```

Sometimes they

* blacklist refresh token

* invalidate sessions

* revoke access

Example

```
POST

/auth/logout/
```

Body

```
{
    "refresh":
    "xxxxx"
}
```

Server responds

```
200 OK
```

Now the refresh token is dead forever.

---

# What If Logout API Fails?

Imagine

```
No internet
```

Should user stay logged in?

No.

Local logout should still happen.

Example

```dart
Future<void> logout() async {

    try {
        await api.logout();
    } catch (_) {}

    await tokenStorage.clearTokens();
}
```

Even if server fails...

User is logged out locally.

Professional apps do this.

---

# Why?

Imagine

```
Flight Mode
```

User wants to logout.

Should they be trapped?

No.

Always allow local logout.

---

# Logging Out From Multiple Devices

Suppose

```
Phone

Laptop

Tablet
```

are logged in.

Logout from phone

Should laptop logout too?

Depends on backend.

Backend decides whether

```
One session

or

Multiple sessions
```

are allowed.

Frontend simply follows instructions.

---

# Clear Cached Data Too

Many apps cache

```
Orders

Notifications

Addresses

Wallet

History
```

When user logs out

clear everything.

Example

```dart
orders.clear();

notifications.clear();

wallet = null;
```

Otherwise...

User B logs in

and sees

User A's data.

Very common beginner mistake.

---

# Complete Logout Flow

```
Tap Logout
      │
      ▼
Repository.logout()
      │
      ▼
Call Logout API (optional)
      │
      ▼
Delete Tokens
      │
      ▼
Delete User Data
      │
      ▼
Set Status
      │
      ▼
notifyListeners()
      │
      ▼
GoRouter Redirect
      │
      ▼
Login Screen
```

---

# Your Swiss App

Your implementation is already close.

Provider

```dart
Future<void> logout() async {

    await TokenStorage().clearTokens();

    _currentUser = null;

    _status = AuthStatus.unauthenticated;

    notifyListeners();
}
```

This works.

An even cleaner architecture would move the storage logic into the repository:

```dart
Future<void> logout() async {
    await _repository.logout();

    _currentUser = null;
    _status = AuthStatus.unauthenticated;

    notifyListeners();
}
```

Then in `AuthRepository`:

```dart
Future<void> logout() async {
    try {
        // Optional:
        // await dioClient.dio.post(ApiConstants.logout);
    } catch (_) {
      // Ignore network errors during logout
    }

    await _tokenStorage.clearTokens();
}
```

This keeps responsibilities separated:

* **Provider** manages application state.
* **Repository** handles API and storage.
* **TokenStorage** only reads and writes tokens.

---

# Beginner Mistakes

❌ Forgetting to clear refresh token

❌ Clearing only access token

❌ Calling `context.go("/login")` instead of letting GoRouter redirect

❌ Forgetting `notifyListeners()`

❌ Leaving `_currentUser` in memory

❌ Leaving cached data from the previous user

❌ Blocking logout when there is no internet

❌ Accessing protected screens after logout

---

# Chapter Summary

By the end of this chapter, you should understand:

* ✅ What a professional logout process looks like
* ✅ Why logout is more than just navigating to the login page
* ✅ The correct order of operations during logout
* ✅ Why repositories should handle storage and API calls
* ✅ How GoRouter automatically redirects after logout
* ✅ How to support offline logout gracefully
* ✅ Why cached user data must be cleared
* ✅ Common logout mistakes and how to avoid them

---

## What's Next?

**Chapter 17: Building an Automatic Login (Splash Screen Authentication Check)**

In the next chapter, we'll build the startup experience used by apps like WhatsApp, Instagram, Facebook, and Uber:

* The splash screen checks if tokens exist.
* It validates whether the user is still authenticated.
* It silently refreshes expired tokens if possible.
* It loads the current user's profile.
* It navigates to either the Home screen or Login screen without the user pressing anything.

This chapter ties together everything you've learned so far into a seamless app startup flow.
