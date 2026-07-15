# Volume 1 – Chapter 13

# State Management for Authentication (Provider)

> **Goal of this chapter:**
>
> By the end of this chapter, you'll understand:
>
> * Why Provider exists
> * Why repositories should never touch the UI
> * Why screens should never call APIs directly
> * How ChangeNotifier works
> * Why notifyListeners() rebuilds widgets
> * The exact job of AuthProvider
> * How login/logout/register flows through Provider

---

# Before this chapter...

Your authentication system currently looks like this:

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
Backend
```

This is exactly how professional Flutter applications are built.

Now let's understand WHY.

---

# Imagine You Own a Restaurant

Let's pretend you're opening a restaurant.

Customers sit at tables.

They don't walk into the kitchen.

Instead they talk to...

The waiter.

```
Customer
    │
    ▼
 Waiter
    │
    ▼
 Kitchen
```

The waiter carries information both ways.

Customer says:

> I want Fried Rice.

Waiter tells kitchen.

Kitchen cooks.

Waiter returns.

---

Flutter works exactly like that.

```
User
   │
   ▼
Screen
   │
   ▼
Provider
   │
   ▼
Repository
   │
   ▼
API
```

The Provider is the waiter.

---

# Why Not Let the Screen Call the API?

Beginners usually do this.

```
LoginScreen

↓

dio.post(...)

↓

Backend
```

Looks easy.

But now imagine...

You need login from

* Login Screen
* Splash Screen
* Settings Screen
* Auto Login
* Background refresh

Every screen now copies login code.

Disaster.

Instead...

Every screen talks to ONE provider.

```
Login Screen
Splash Screen
Profile Screen
Settings Screen

      │
      ▼

 AuthProvider

      │
      ▼

Repository
```

One place.

One logic.

No duplicated code.

---

# What Exactly Is Provider?

Provider is simply...

A shared object.

Instead of every page making its own data...

Everyone shares one object.

Imagine WhatsApp.

Home screen

```
Chats
```

Profile screen

```
Your name
```

Settings

```
Profile picture
```

Status page

```
Profile picture
```

All these screens use

ONE user.

Not four users.

That's Provider.

---

# Without Provider

Screen A

```
User = Samad
```

Screen B

```
User = null
```

Screen C

```
User = Samad
```

Everything becomes inconsistent.

---

With Provider

Everyone reads

```
AuthProvider.currentUser
```

One source of truth.

---

# What Is ChangeNotifier?

Provider has many types.

The simplest one is

```
ChangeNotifier
```

It allows widgets to rebuild whenever data changes.

Example.

Initially

```
Username

Loading...
```

Login finishes.

Provider changes

```
Loading...

↓

false
```

Provider says

```
notifyListeners();
```

Flutter immediately rebuilds every screen using that provider.

No manual refresh.

---

# Think of notifyListeners()

Imagine your mother shouting:

> Food is ready!

Everyone hears.

Everyone comes.

She doesn't go room by room.

notifyListeners() is exactly that.

It broadcasts

> Something changed!

Every Consumer widget listening immediately rebuilds.

---

# Without notifyListeners()

Suppose login succeeds.

```
_currentUser = user;
```

Nothing happens.

UI still shows

```
Login
```

Because Flutter doesn't know anything changed.

Now add

```
notifyListeners();
```

Flutter immediately rebuilds.

Now UI shows

```
Welcome Samad
```

---

# Anatomy of AuthProvider

Let's examine yours.

```
class AuthProvider
    with ChangeNotifier
```

This means

"I can notify widgets whenever my data changes."

---

Inside it you have

```
UserModel? _currentUser;
```

Stores logged in user.

---

```
bool _isLoading;
```

Controls loading spinner.

---

```
String? _error;
```

Stores errors.

---

```
AuthStatus _status;
```

Stores login status.

---

Together they describe the authentication state.

---

# Why Are They Private?

Notice

```
_currentUser
```

starts with underscore.

Meaning

Private.

Nobody outside can change it.

Instead

```
UserModel? get currentUser
```

lets everyone READ it.

Not modify it.

Professional encapsulation.

---

# Auth Status

Instead of

```
bool loggedIn
```

You used

```
checking

authenticated

unauthenticated
```

Much better.

Why?

Because startup has a third state.

Imagine app opens.

Token still loading.

Are we logged in?

Not yet.

Logged out?

Not yet.

Need another state.

```
checking
```

Perfect.

---

# Login Flow

User taps

```
LOGIN
```

Screen calls

```
provider.login()
```

Inside

```
_setLoading(true);
```

Spinner appears.

Then

```
repository.login()
```

Repository calls backend.

Backend returns

```
Access Token

Refresh Token

User
```

Repository saves tokens.

Provider stores

```
_currentUser
```

Updates

```
_status
```

Finally

```
notifyListeners();
```

Entire app refreshes.

---

Flow becomes

```
Button

↓

Provider

↓

Repository

↓

Backend

↓

Repository

↓

Provider

↓

notifyListeners()

↓

UI updates
```

---

# Logout Flow

User presses

```
Logout
```

Provider

```
clearTokens()

_currentUser = null;

_status = unauthenticated;

notifyListeners();
```

Router immediately redirects.

No manual navigation required.

---

# Register Flow

Almost identical.

```
Register

↓

Backend

↓

Tokens

↓

Save Tokens

↓

Current User

↓

notifyListeners()
```

Only endpoint changes.

Architecture stays identical.

---

# Why Doesn't Provider Talk to Dio?

Because Provider shouldn't know networking.

Provider only knows

"I need login."

Repository decides

POST

Headers

Endpoints

Parsing

Errors

If tomorrow backend changes...

Only repository changes.

Provider stays untouched.

---

# Why Doesn't Repository Store Loading?

Repository shouldn't know UI.

Repository only returns data.

Provider manages

Loading

Errors

Success

This separation keeps code clean.

---

# Common Mistake Beginners Make

```
Future login(){

loading = true;

dio.post(...);

loading = false;
}
```

inside Repository.

Wrong.

Because repository doesn't own UI.

Provider owns UI state.

---

Correct

Repository

```
return loginResponse;
```

Provider

```
loading=true

await repository.login()

loading=false

notifyListeners()
```

Much cleaner.

---

# Consumer

Now imagine

```
Consumer<AuthProvider>
```

Whenever provider changes...

Only this widget rebuilds.

Not the whole app.

Efficient.

---

Example

```
Consumer<AuthProvider>(
 builder: ...
)
```

Login changes.

Only that section rebuilds.

---

# context.read()

```
context.read<AuthProvider>()
```

Means

"I want the provider once."

No rebuild.

Used for

```
login()

logout()

register()

loadUser()
```

Actions.

---

# context.watch()

Means

"I want this widget to rebuild whenever provider changes."

Useful for

```
Loading

Username

Profile picture

Balance
```

---

# Consumer vs Watch

Both rebuild.

Difference is scope.

Watch

```
Whole widget rebuilds
```

Consumer

```
Only Consumer rebuilds
```

Consumer is usually more efficient.

---

# Your Authentication Architecture

Congratulations.

You now have this professional structure:

```
UI

↓

AuthProvider

↓

AuthRepository

↓

DioClient

↓

Backend
```

Provider owns

* loading
* user
* status
* errors

Repository owns

* API
* JSON
* Tokens

Dio owns

* HTTP
* Headers
* Interceptors

Beautiful separation.

---

# Professional Folder Structure

```
auth/

    models/

        user_model.dart

    providers/

        auth_provider.dart

    repository/

        auth_repository.dart

    screens/

        login_screen.dart

        register_screen.dart

    widgets/

        login_button.dart

        register_form.dart
```

Very scalable.

---

# Real-Life Summary

Think of a bank.

Customer

↓

Teller

↓

Vault

Customer never enters the vault.

Similarly

Screen

↓

Provider

↓

Repository

↓

Backend

Each layer has exactly one responsibility.

That is the essence of clean architecture.

---

# Chapter Summary

After completing this chapter, you should understand:

✅ Why Provider exists

✅ What ChangeNotifier does

✅ Why notifyListeners() is necessary

✅ Why repositories never update the UI

✅ Why providers manage loading and errors

✅ Why screens should never call APIs directly

✅ Difference between `read()`, `watch()`, and `Consumer`

✅ The complete login flow from button press to UI update

---

## Up Next — Chapter 14: Route Protection with GoRouter

In the next chapter, we'll dive deep into one of the most important parts of authentication:

* Why users shouldn't access protected pages without logging in
* How `GoRouter` redirects work
* How `refreshListenable` works
* Why you used `AuthStatus.checking`
* How splash screens decide where to navigate
* Building a production-ready authentication guard that automatically protects every screen in your app.
