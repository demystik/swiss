# Volume 1 – Authentication Mastery

# Chapter 17: Building Automatic Login (Splash Screen Authentication Check)

> *"The best login experience is the one the user never notices."*

Think about apps like:

* WhatsApp
* Facebook
* Instagram
* Gmail
* X (Twitter)
* Spotify

When you open them, do you enter your email and password every single time?

No.

They simply open.

Sometimes you see a splash screen for one or two seconds.

Then...

You're already inside the app.

How?

Because the app already knows whether you're logged in.

That is exactly what we're building in this chapter.

---

# What is Automatic Login?

Automatic login means

> "When the app starts, check whether the user is already authenticated."

If yes...

Go directly to Home.

If no...

Go to Login.

No button.

No typing.

No loading screen forever.

Everything happens automatically.

---

# The Complete Flow

```text
User opens App
        │
        ▼
Splash Screen
        │
        ▼
Check Access Token
        │
        ├──────────────┐
        │              │
        ▼              ▼
Token Exists?        No Token
        │              │
       Yes             ▼
        │          Login Screen
        ▼
Load Current User
        │
        ├──────────────┐
        │              │
        ▼              ▼
Success          Token Invalid
        │              │
        ▼              ▼
Dashboard       Login Screen
```

This is how almost every modern app works.

---

# Why Don't We Go Straight to Home?

Imagine this.

Yesterday

You logged in.

Today

Someone manually deleted your account.

Your phone still has

```text
Access Token
```

Should your app assume you're still logged in?

No.

It must verify with the server.

That's why we call

```http
GET /auth/me/
```

or any endpoint that returns the current user.

---

# The Splash Screen's Job

Many beginners think

> Splash Screen = Pretty Logo

Wrong.

Professional Splash Screens have ONE responsibility.

```text
Check Authentication
```

Everything else is secondary.

---

# What Happens When App Starts?

Your app begins here.

```dart
void main() async {
    WidgetsFlutterBinding.ensureInitialized();

    ...
}
```

Then

```dart
await authProvider.loadUser();
```

This line is extremely important.

Before Flutter even shows the first page...

It already asks

> "Is someone logged in?"

---

# Why Use await?

Imagine removing it.

```dart
authProvider.loadUser();

runApp(...);
```

Now two things happen together.

```text
App starts

AND

Authentication starts
```

Who wins?

Nobody knows.

Sometimes

Home appears.

Sometimes

Login appears.

Sometimes

The router changes twice.

Sometimes

Widgets rebuild multiple times.

This creates flickering.

---

Using

```dart
await authProvider.loadUser();
```

means

```text
Wait...

Finish authentication...

Then build the app.
```

Much smoother.

---

# Inside loadUser()

Let's study your own code.

```dart
Future<void> loadUser() async {
    try {

        final token =
            await TokenStorage().getAccessToken();

        if (token == null) {

            _status =
            AuthStatus.unauthenticated;

            notifyListeners();

            return;
        }

        _currentUser =
            await _repository.getCurrentUser();

        _status =
            AuthStatus.authenticated;

        notifyListeners();

    } catch (e) {

        await logout();

    }
}
```

This method is the heart of automatic login.

---

# Step 1

Read Access Token

```dart
final token =
await TokenStorage().getAccessToken();
```

Possible result

```text
eyJhbGc....
```

or

```text
null
```

---

# Why Check the Token First?

Without this

the app would immediately call

```http
GET /auth/me/
```

even if

there is no logged-in user.

Waste of internet.

Waste of server resources.

Always check local storage first.

---

# Step 2

No Token Found

```dart
if (token == null)
```

means

Nobody has logged in before.

So

```dart
_status =
AuthStatus.unauthenticated;
```

GoRouter later sends user here

```text
Login Screen
```

---

# Step 3

Token Exists

Now we verify it.

```dart
_currentUser =
await _repository.getCurrentUser();
```

This calls

```http
GET /auth/me/
```

Possible results

### Success

```http
200 OK
```

meaning

```text
Token Valid
```

or

### Failure

```http
401 Unauthorized
```

meaning

```text
Token Expired

or

Token Invalid
```

---

# Why Not Trust the Token?

Anyone can manually edit local storage.

Someone could insert

```text
FakeToken123
```

Your app should never believe local storage.

Only the backend decides.

---

# Step 4

Server Confirms User

```dart
_currentUser =
response;
```

Now

your Provider has

```text
Name

Email

Phone

Role

Profile

etc
```

Everything the UI needs.

---

# Step 5

Update Status

```dart
_status =
AuthStatus.authenticated;
```

Now the app officially knows

```text
User Logged In
```

---

# Step 6

Tell Everyone

```dart
notifyListeners();
```

GoRouter

Consumers

Widgets

Navigation

Everything updates.

---

# What If Something Goes Wrong?

Imagine

```http
401 Unauthorized
```

or

```text
Network Error
```

Your code catches it.

```dart
catch (e) {
    await logout();
}
```

Very smart.

This means

```text
Invalid User

↓

Delete Tokens

↓

Login Screen
```

Instead of crashing.

---

# Why Does logout() Solve Everything?

Your logout

```dart
await TokenStorage()
.clearTokens();
```

removes

Access Token

Refresh Token

Current User

Status

Everything becomes clean again.

---

# What Happens After notifyListeners()?

Remember your router.

```dart
refreshListenable:
authProvider
```

This tells GoRouter

> "Whenever authentication changes..."

run redirect again.

---

Inside redirect

```dart
if (!isLoggedIn)
```

↓

```dart
return "/login";
```

Otherwise

```dart
return "/dashboard";
```

No navigation code is needed.

GoRouter handles everything.

---

# Why Not Save User Data Only?

Some beginners do this

```text
SharedPreferences

↓

Save Name

↓

Save Email

↓

Save Phone
```

Then next launch

they simply read

those values.

Problem?

Those values may belong to

someone who

* changed password

* got banned

* was deleted

Always verify with backend.

---

# The Complete Startup Sequence

```text
main()

↓

Initialize Flutter

↓

Create Dio

↓

Create Repository

↓

Create Provider

↓

loadUser()

↓

Check Token

↓

Token Exists?

↓

Yes

↓

GET /auth/me/

↓

200 ?

↓

Yes

↓

Authenticated

↓

runApp()

↓

Dashboard
```

---

If

```text
No Token
```

then

```text
runApp()

↓

Login Screen
```

---

# Your Swiss App

This line

```dart
await authProvider.loadUser();
```

is exactly what professional apps do.

Most beginners skip this.

Because of this one line,

your app already behaves like many production apps.

---

# Common Mistakes

### Mistake 1

Checking only if token exists.

Wrong.

Token may already be expired.

---

### Mistake 2

Going directly to Dashboard.

Wrong.

Always verify.

---

### Mistake 3

Calling API without checking storage.

Unnecessary internet requests.

---

### Mistake 4

Not awaiting loadUser()

Results

* flashing screens

* router loops

* double navigation

---

### Mistake 5

Saving only user info

instead of validating with backend.

---

# Visual Summary

```text
Open App
     │
     ▼
Splash Screen
     │
     ▼
Read Token
     │
     ├──────────────┐
     │              │
     ▼              ▼
No Token       Token Found
     │              │
     ▼              ▼
 Login        GET /auth/me
                     │
          ┌──────────┴─────────┐
          │                    │
          ▼                    ▼
       Success              Failure
          │                    │
          ▼                    ▼
   Dashboard              Logout()
                               │
                               ▼
                          Login Screen
```

---

# How This Connects to Previous Chapters

By now, you have built almost the complete authentication lifecycle:

* ✅ **Chapter 1–4:** Authentication architecture and folder structure.
* ✅ **Chapter 5:** Registering a new user.
* ✅ **Chapter 6:** Logging in.
* ✅ **Chapter 7:** Saving access and refresh tokens securely.
* ✅ **Chapter 8:** Reading tokens from secure storage.
* ✅ **Chapter 9:** Automatically attaching tokens with a Dio interceptor.
* ✅ **Chapter 10:** Handling expired tokens with refresh tokens.
* ✅ **Chapter 11:** Calling protected endpoints like `/auth/me/`.
* ✅ **Chapter 12:** Managing authentication state using `AuthProvider`.
* ✅ **Chapter 13:** Protecting routes with GoRouter.
* ✅ **Chapter 14:** Understanding the complete authentication lifecycle.
* ✅ **Chapter 15:** Managing session persistence.
* ✅ **Chapter 16:** Logging out professionally.
* ✅ **Chapter 17:** Automatically restoring a user's session when the app launches.

You now understand how a user can close the app, reopen it hours later, and continue using it without logging in again—as long as their session is still valid.

---

# Chapter Summary

After this chapter, you should understand:

* ✅ Why splash screens do more than show a logo.
* ✅ Why `await authProvider.loadUser()` belongs in `main()`.
* ✅ Why you check local storage before making network requests.
* ✅ Why the backend must always validate stored tokens.
* ✅ How `/auth/me/` confirms the logged-in user.
* ✅ How GoRouter automatically decides between Login and Dashboard.
* ✅ Why automatic login improves the user experience.
* ✅ Common startup mistakes and how to avoid them.

---

# Next Chapter

## **Chapter 18 – Automatic Token Refresh (Silent Authentication)**

This is one of the most advanced and impressive features in authentication.

You'll learn how apps like **Instagram, Gmail, WhatsApp, Facebook, and Spotify** keep users logged in for weeks or months without asking them to log in again.

We'll build a complete refresh-token system that:

* Detects when an access token has expired.
* Automatically requests a new access token using the refresh token.
* Retries the failed request without the user noticing.
* Logs the user out only if the refresh token has also expired.

By the end of that chapter, you'll understand one of the core authentication patterns used in production applications.
