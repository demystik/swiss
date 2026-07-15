# **Volume 1 – Chapter 9**

# **The Complete Authentication Flow (Putting Everything Together)**

By now you know:

* How authentication works
* The files involved
* Provider
* Repository
* Secure Storage
* Dio
* Interceptors
* Router Guards

Now let's connect everything together from the moment a user opens the app until they log out.

This chapter is one of the most important in the whole course.

---

# Imagine This

Think of your app like a hotel.

The user wants a room.

Before getting one they must

* enter the hotel
* check in
* receive a room key
* show the key whenever they leave or return
* receive another key if theirs expires
* check out before leaving permanently

Authentication is exactly this.

---

# Complete Flow

```
App Opens

↓

Initialize Services

↓

Load Stored Token

↓

Check if Token Exists

↓

No Token?
    ↓
Go To Login

Yes
↓

Request Current User

↓

Token Valid?

Yes
↓

Dashboard

No
↓

Refresh Token

↓

Refresh Successful?

Yes
↓

Save New Access Token

↓

Dashboard

No

↓

Logout

↓

Login Screen
```

That is the complete authentication lifecycle.

---

# Step 1

## User Opens the App

Flutter starts here

```
main()
```

Inside main()

```
WidgetsFlutterBinding.ensureInitialized();

final dioClient = DioClient();

final authRepository = AuthRepository(
    dioClient: dioClient,
);

final authProvider = AuthProvider(
    authRepository,
);

await authProvider.loadUser();

runApp(...);
```

Notice something.

Before the app starts...

We already ask

> "Do we have a logged in user?"

NOT

after the UI builds.

---

# Why?

Imagine YouTube.

Would you like to see

Login Screen

for 1 second

then suddenly Dashboard?

No.

The app should already know.

That is why

```
await authProvider.loadUser();
```

comes before

```
runApp()
```

---

# Step 2

## loadUser()

Inside provider

```
Future<void> loadUser()
```

This function decides everything.

It asks

```
Do I have an access token?
```

```
final token =
await TokenStorage().getAccessToken();
```

---

If

```
token == null
```

then

```
status = unauthenticated
```

and routing sends user to Login.

---

If token exists

it tries

```
GET /auth/me/
```

---

Possible outcomes

Success

↓

User exists

↓

Authenticated

---

Failure

↓

Token expired

↓

Logout

---

# Step 3

## Router Checks Authentication

GoRouter listens to AuthProvider.

```
refreshListenable: authProvider
```

Whenever provider changes,

GoRouter checks

```
redirect()
```

---

It asks

```
Is user authenticated?
```

If NO

↓

Login

If YES

↓

Dashboard

---

This means

You NEVER manually navigate after startup.

The router decides.

---

# Step 4

## User Logs In

Login screen calls

```
authProvider.login()
```

Inside

```
Repository.login()
```

calls

```
POST

/auth/login/
```

Backend responds

```
{
   user

   access

   refresh
}
```

---

Provider now calls

```
saveAuthData()
```

---

# Step 5

## Save Tokens

Inside repository

```
TokenStorage.saveToken(
    access,
    refresh,
);
```

Secure Storage writes

```
access_token

refresh_token
```

inside encrypted storage.

After this

Even if app closes

tokens remain.

---

# Step 6

## Provider Updates State

After saving

Provider changes

```
status =
authenticated
```

and

```
notifyListeners();
```

Now

GoRouter immediately notices.

---

Router redirects

```
Login

↓

Dashboard
```

No manual navigation needed.

---

# Step 7

## Dashboard Opens

HomeScreen

```
initState()
```

calls

```
loadRiders()
```

---

Provider

↓

Repository

↓

Dio

↓

GET /riders/

---

Before request leaves

AuthInterceptor runs.

---

# Step 8

## AuthInterceptor Adds Token

Every request passes here.

```
Authorization:

Bearer access_token
```

gets added.

You don't manually attach tokens anymore.

It happens automatically.

---

# Step 9

## Server Checks Token

Server receives

```
Authorization

Bearer eyJ...
```

Server asks

```
Is token valid?
```

---

If yes

```
200 OK
```

---

If expired

```
401
```

---

# Step 10

## Refresh Token Happens

ErrorInterceptor sees

```
401
```

It immediately requests

```
POST

/auth/refresh_token/
```

Body

```
{
   refresh
}
```

Backend returns

```
{
   access
}
```

---

Store new access token

```
saveAccessToken()
```

Retry original request.

User never notices.

---

# Step 11

## Refresh Also Expired

Suppose

Refresh token expired.

Backend replies

```
401
```

Now there is nothing left.

App does

```
clearTokens()

status =
unauthenticated
```

Router redirects

```
Dashboard

↓

Login
```

---

# Step 12

## User Logs Out

Logout button

↓

Provider.logout()

Inside

```
TokenStorage.clearTokens();
```

Then

```
status =
unauthenticated
```

Notify listeners.

Router

↓

Login screen.

Done.

---

# The Entire Flow (One Picture)

```
User Opens App

↓

main()

↓

Create Dio

↓

Create Repository

↓

Create Provider

↓

loadUser()

↓

Access Token Exists?

        NO
         │
         ▼
    Login Screen

YES

↓

GET /auth/me/

↓

Success?

NO

↓

Logout

↓

Login

YES

↓

Dashboard

↓

loadRiders()

↓

Repository

↓

Dio

↓

AuthInterceptor

↓

Authorization Header

↓

Backend

↓

200

↓

Display Data
```

---

# What Every Layer Is Responsible For

## UI

Responsible for

* buttons
* forms
* showing loading
* showing errors

Never handles APIs.

---

## Provider

Responsible for

* business logic
* loading
* authentication state
* notifying UI

Never writes HTTP.

---

## Repository

Responsible for

Talking to backend.

Nothing else.

---

## Dio

Responsible for

Sending requests.

---

## Interceptor

Responsible for

Automatically

* adding tokens
* refreshing tokens
* retrying requests
* handling authentication failures

---

## Token Storage

Responsible for

Saving

Reading

Deleting

Tokens.

Nothing more.

---

## Router

Responsible for

Protecting pages.

---

# One Thing Beginners Always Do Wrong

Many beginners write

```
Button

↓

Call Dio directly

↓

Update UI

↓

Save Token
```

Everything inside one screen.

That becomes impossible to maintain.

Instead

Always follow this structure:

```
UI

↓

Provider

↓

Repository

↓

Dio

↓

Backend

↓

Repository

↓

Provider

↓

UI
```

This keeps every file focused on one responsibility.

---

# How to Know Your Authentication System Is Complete

You should be able to answer **YES** to all of these:

* ✅ User can register.
* ✅ User can log in.
* ✅ Tokens are stored securely.
* ✅ App remembers the user after restart.
* ✅ Every request automatically includes the access token.
* ✅ Expired access tokens refresh automatically.
* ✅ Failed refresh logs the user out.
* ✅ Protected pages cannot be opened without authentication.
* ✅ Logout clears all stored credentials.
* ✅ UI reacts automatically to authentication state changes.

If every box is checked, you have a production-grade authentication foundation.

---

# Real-World Note

What you've built is not just for the Swiss Logistics app. This architecture is used—sometimes with additional layers—in many professional Flutter applications. Once you understand this flow deeply, you can adapt it to APIs using JWT, OAuth, Firebase Authentication, social logins (Google, Apple), and enterprise backends.

---

## End of Chapter 9

**What you have learned**

* The complete end-to-end authentication lifecycle.
* How every file communicates with the next.
* The exact execution order from app launch to logout.
* How access tokens and refresh tokens work together.
* How the router, provider, repository, Dio, interceptors, and secure storage fit into one coherent system.

**Next Chapter (Chapter 10):**

# **Building Authentication Like a Senior Flutter Developer**

We'll cover project organization, clean architecture principles, dependency injection, scaling authentication to large apps, common mistakes, debugging strategies, and best practices used in production codebases.
