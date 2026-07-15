# Volume 1 – Authentication Masterclass

# Chapter 10: The Complete Authentication Flow (How Everything Works Together)

Congratulations.

You've now learned every individual piece of authentication.

Now it's time to connect everything.

This chapter is the chapter that separates beginners from professional Flutter developers.

After this chapter, you'll stop memorizing code and start understanding exactly why every file exists.

---

# The Big Picture

Imagine authentication as a company building.

To enter the building you must

```
Walk to the gate
↓

Show your ID

↓

Security verifies you

↓

They give you a visitor pass

↓

You enter

↓

Whenever you enter another room,
security checks your pass.

↓

If the pass expires,
they issue another one.

↓

If you leave,
your pass is destroyed.
```

That...

is literally how JWT Authentication works.

---

# The Entire Authentication Lifecycle

Let's start from the very beginning.

```
App Opens
      │
      ▼
main.dart
      │
      ▼
loadUser()
      │
      ▼
Do tokens exist?
      │
 ┌────┴────┐
 │         │
No        Yes
 │         │
 ▼         ▼
Login    Call /auth/me
Screen      │
            ▼
      Token Valid?
        │
   ┌────┴────┐
   │         │
  No        Yes
   │         │
   ▼         ▼
Logout   Dashboard
```

That's the entire startup process.

---

# STEP 1

## User Opens App

Flutter starts here

```
void main() async {
   WidgetsFlutterBinding.ensureInitialized();

   final dio = DioClient();

   final authRepo = AuthRepository(dio);

   final authProvider = AuthProvider(authRepo);

   await authProvider.loadUser();

   runApp(...);
}
```

Notice something important.

The app DOES NOT immediately display Login Screen.

Instead...

It asks

> "Do we already know this user?"

That's why

```
await authProvider.loadUser();
```

comes before

```
runApp()
```

---

# What loadUser() Actually Does

```
Future<void> loadUser()
```

This function answers ONE question.

```
Is the user already logged in?
```

That's all.

---

Internally it does

```
Read token

↓

No token?

↓

Go Login

```

or

```
Read token

↓

Token exists

↓

Call /auth/me

↓

Token valid?

↓

Dashboard
```

---

# Why We Call /auth/me

Many beginners ask

"I already have the token.

Why call another API?"

Good question.

Because...

A token inside storage means absolutely nothing.

Maybe

```
expired

deleted

revoked

fake

blacklisted
```

Only the server knows.

So we ask

```
GET /auth/me
```

If server replies

```
200
```

User is authenticated.

If server replies

```
401
```

Token is invalid.

Logout.

---

# STEP 2

Router Makes Decision

GoRouter asks

```
Should this person enter Dashboard?
```

It checks

```
AuthStatus
```

```
checking

authenticated

unauthenticated
```

If

```
checking
```

wait.

If

```
authenticated
```

Dashboard.

If

```
unauthenticated
```

Login Screen.

---

# That's why we wrote

```
refreshListenable: authProvider
```

Every time

```
notifyListeners()
```

runs,

GoRouter automatically asks again

```
Can this user enter Dashboard?
```

Amazing.

No manual navigation.

---

# STEP 3

User Logs In

User presses

```
LOGIN
```

UI calls

```
provider.login()
```

NOT

```
repository.login()
```

Remember

UI only speaks Provider.

Never Repository.

---

Provider now calls

```
repository.login()
```

Repository sends

```
POST

/auth/login
```

Server replies

```
{
   access,
   refresh,
   user
}
```

---

# STEP 4

Repository Saves Tokens

Immediately after login

```
saveAuthData()
```

stores

```
Access Token

Refresh Token
```

inside

```
FlutterSecureStorage
```

Nothing else.

No navigation.

No UI.

Only storage.

---

# STEP 5

Provider Updates State

Repository finishes.

Provider now says

```
_currentUser = ...

_status = authenticated

notifyListeners()
```

Immediately

GoRouter hears

```
notifyListeners()
```

and redirects

```
Login

↓

Dashboard
```

Automatically.

No

```
Navigator.push()
```

needed.

---

# STEP 6

User Opens Dashboard

Dashboard opens.

Example

```
HomeScreen
```

Inside

```
initState()
```

you call

```
loadRiders()
```

Provider says

```
Repository,

go fetch riders.
```

Repository says

```
GET /riders
```

---

# STEP 7

Before Request Leaves App

This is where Interceptors become heroes.

Before Dio sends

```
GET /riders
```

AuthInterceptor stops it.

```
WAIT.

Do we have token?
```

Reads storage

```
access_token
```

Adds

```
Authorization:

Bearer XXXXX
```

Only then

request leaves.

Without interceptor

every repository would need

```
headers:

Authorization...
```

everywhere.

Nightmare.

---

# STEP 8

Server Checks Token

Server receives

```
Authorization

Bearer xxxxxxxxx
```

Checks

```
Is token real?

Expired?

Tampered?

Blacklisted?
```

If okay

```
200
```

If not

```
401
```

---

# STEP 9

What Happens if Access Token Expires?

This is what happened in your project.

You saw

```
401

Token expired
```

Correct.

Instead of logging user out immediately

professional apps do

```
Access expired?

↓

Use Refresh Token

↓

Request new Access Token

↓

Save it

↓

Retry request
```

User never notices.

Magic.

---

Flow

```
GET /riders

↓

401

↓

POST /refresh

↓

New Access Token

↓

Retry GET /riders

↓

200
```

This is called

Automatic Token Refresh.

---

# STEP 10

User Logs Out

Logout is surprisingly simple.

```
Delete access token

↓

Delete refresh token

↓

currentUser = null

↓

status = unauthenticated

↓

notifyListeners()
```

GoRouter instantly redirects

```
Dashboard

↓

Login
```

Done.

---

# Complete Timeline

```
App Opens

↓

main()

↓

loadUser()

↓

Read Secure Storage

↓

No token?

───────────────
Yes → Login
───────────────

↓

Token Found

↓

GET /auth/me

↓

401?

───────────────
Yes → Logout
───────────────

↓

200

↓

Dashboard

↓

loadRiders()

↓

Repository

↓

Interceptor

↓

Authorization Header

↓

Server

↓

200

↓

Display Riders
```

---

# Every File's Responsibility (One-Line Rule)

When you're unsure where code belongs, remember these rules:

| File             | Responsibility                                    |
| ---------------- | ------------------------------------------------- |
| UI Screen        | Collect user input and display data               |
| Provider         | Manage app state and business logic               |
| Repository       | Communicate with the backend API                  |
| DioClient        | Configure Dio and register interceptors           |
| AuthInterceptor  | Attach access token to outgoing requests          |
| ErrorInterceptor | Handle 401 errors, refresh tokens, retry requests |
| TokenStorage     | Save, read, update, and delete tokens             |
| Router           | Decide which screen the user can access           |
| Models           | Convert JSON into Dart objects                    |
| API Constants    | Store endpoint URLs only                          |

If you ever find yourself writing API code inside a screen, or UI code inside a repository, you're probably putting it in the wrong place.

---

# The Golden Rule of Authentication

Memorize this sequence:

```
Screen
    ↓
Provider
    ↓
Repository
    ↓
Dio
    ↓
Interceptor
    ↓
Server
    ↓
Repository
    ↓
Provider
    ↓
UI
```

Everything in your authentication system follows this exact path.

If you understand this flow, you can build authentication for virtually any Flutter app, regardless of whether it uses JWT, Firebase Auth, OAuth, or another backend.

---

# Common Beginner Mistakes

❌ Calling repositories directly from UI.

✔ UI should only talk to Providers.

---

❌ Storing tokens inside Providers.

✔ Tokens belong in secure storage.

---

❌ Using `Navigator.push()` after login.

✔ Let your router react to authentication state changes.

---

❌ Putting business logic inside widgets.

✔ Keep widgets focused on displaying the UI.

---

❌ Manually adding the Authorization header in every request.

✔ Let an interceptor do it automatically.

---

❌ Logging users out immediately when an access token expires.

✔ Refresh the access token first, then retry the request.

---

# Chapter Summary

By the end of this chapter, you should understand:

* How the authentication lifecycle works from app launch to logout.
* Why `loadUser()` runs before the app is displayed.
* Why `/auth/me` is used even when a token exists.
* How `GoRouter` responds automatically to authentication changes.
* The complete request path from UI to server and back.
* The purpose of access tokens and refresh tokens.
* Why interceptors are essential.
* How automatic token refresh improves the user experience.
* The single responsibility of every authentication-related file.

---

## Up Next: Chapter 11 — Building a Production-Ready Error Interceptor

In the next chapter, we'll build one of the most valuable pieces of a professional authentication system:

* Detecting expired access tokens automatically.
* Refreshing tokens in the background.
* Retrying failed requests without user intervention.
* Preventing multiple simultaneous refresh requests.
* Handling refresh failures by logging the user out safely.
* Writing an `ErrorInterceptor` that can be reused across any Flutter project.

This is one of the biggest differences between a beginner authentication system and one used in production apps.
