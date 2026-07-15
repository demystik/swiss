# Flutter Architecture Masterclass

## Volume 1 – Building Authentication Systems

# Chapter 2 — Designing the Project Before Writing Code

> **Goal of this chapter**
>
> By the end of this chapter, you'll know **exactly which files to create, in what order, why they are created in that order, and what should be working after each step.**

---

# Stop Coding Immediately

Most Flutter developers do this:

```text
Create Login Screen

↓

Write UI

↓

Write API

↓

Fix errors

↓

Write Provider

↓

Fix more errors

↓

Create Models

↓

Fix imports

↓

Rewrite everything
```

That's called **building without a blueprint.**

Professional developers don't start with code.

They start with **architecture.**

Think of building a house.

Would you install the roof before building the walls?

No.

Authentication works exactly the same way.

---

# The House Analogy

Imagine you're building a house.

The order matters.

```text
Foundation

↓

Walls

↓

Roof

↓

Doors

↓

Furniture
```

If you skip the foundation...

Everything collapses.

Flutter authentication has its own foundation.

---

# The Correct Build Order

Here is the order professional Flutter developers follow.

```text
1. Project Structure

↓

2. Constants

↓

3. Networking

↓

4. Storage

↓

5. Models

↓

6. Repository

↓

7. Provider

↓

8. Router

↓

9. UI Screens

↓

10. Testing
```

Notice something?

**The UI is almost last.**

Most beginners build it first.

---

# Why We Start With Project Structure

Imagine opening a project with 300 files.

Everything is inside one folder.

```text
lib/

login.dart

user.dart

api.dart

provider.dart

home.dart

storage.dart

dio.dart

register.dart

profile.dart

logout.dart
```

Can you find anything?

No.

Now compare that to this.

```text
lib/

core/

features/

shared/

main.dart
```

Much better.

Everything has a home.

---

# The Folder Structure We'll Build

Our authentication system will look like this.

```text
lib/

core/
│
├── constants/
│
├── network/
│
├── storage/
│
└── router/

features/
│
└── auth/
    │
    ├── models/
    │
    ├── repository/
    │
    ├── provider/
    │
    ├── screens/
    │
    └── widgets/

main.dart
```

Let's understand why every folder exists.

---

# Step 1 — Core Folder

This folder contains things used by the **entire application**.

Not just authentication.

Not just riders.

Everything.

Example:

```text
core/

constants/

network/

storage/

router/
```

Think of this as your toolbox.

Every feature uses it.

---

## What Should Exist After Step 1?

Nothing works yet.

That's okay.

You're only creating the foundation.

Expected result:

```text
✔ Clean project structure
```

Nothing else.

---

# Step 2 — Constants Folder

This contains values that rarely change.

Example

```dart
class ApiConstants {

  static const baseUrl = "...";

  static const login = "...";

  static const register = "...";

}
```

Why?

Imagine typing this URL everywhere.

```text
https://swiss-logistics.onrender.com/api/v1/
```

Twenty-five times.

Now the backend changes it.

You now edit 25 files.

Instead,

change one constant.

Done.

---

## What Should Exist After Step 2?

```text
✔ API endpoints

✔ Colors

✔ Strings

✔ Shared constants
```

Still no login.

That's okay.

---

# Step 3 — Network Folder

This is where Dio lives.

Files:

```text
network/

dio_client.dart

interceptors/

auth_interceptor.dart

error_interceptor.dart
```

Notice something.

There are no login APIs here.

No user models.

No provider.

Network only knows how to send requests.

It doesn't know WHY.

---

Think of it like DHL.

DHL doesn't know what's inside your package.

It simply delivers it.

---

## What Should Exist After Step 3?

You should now have

```text
✔ Dio configured

✔ Base URL

✔ Timeouts

✔ Logger

✔ Authorization interceptor
```

No login screen yet.

---

# Step 4 — Storage

Now ask yourself...

Where will the tokens go?

Memory?

Bad idea.

When the app closes...

Everything disappears.

Instead

```text
Flutter Secure Storage
```

stores

```text
Access Token

Refresh Token
```

Files

```text
storage/

token_storage.dart
```

Notice

Storage knows NOTHING about login.

Its only job is

```text
Save

Read

Delete
```

That's all.

---

## What Should Exist After Step 4?

You should now be able to write

```dart
saveToken()

getAccessToken()

getRefreshToken()

clearTokens()
```

Nothing more.

---

# Step 5 — Models

Backend sends JSON.

Flutter doesn't understand JSON directly.

Example

Backend returns

```json
{
  "email":"john@gmail.com",
  "first_name":"John"
}
```

Flutter wants

```dart
UserModel
```

Therefore we create

```text
models/

user_model.dart
```

Sometimes

```text
login_response.dart

register_response.dart
```

or combine them if appropriate.

---

Think of Models as translators.

JSON

↓

Model

↓

Flutter

---

## What Should Exist After Step 5?

You should be able to do

```dart
UserModel.fromJson()
```

and

```dart
user.toJson()
```

---

# Step 6 — Repository

Now we're finally ready to talk to the backend.

Files

```text
repository/

auth_repository.dart
```

Repository knows

```text
POST

GET

PATCH

DELETE
```

Repository knows URLs.

Repository knows JSON.

Provider doesn't.

---

Repository handles

```dart
login()

register()

logout()

getCurrentUser()

refreshToken()
```

Notice

Repository still knows NOTHING about Widgets.

---

## What Should Exist After Step 6?

You should now be able to call

```dart
repository.login()
```

and receive

```dart
User

Access Token

Refresh Token
```

without writing UI.

---

# Step 7 — Provider

Now comes business logic.

Provider answers questions like

```text
Should we login?

Should we logout?

Should we show loading?

Should we show error?

Is user authenticated?
```

Provider communicates with Repository.

Not with Dio.

Not with JSON.

---

Provider exposes

```dart
login()

logout()

register()

loadUser()
```

plus

```dart
isLoading

currentUser

error

status
```

This is exactly what you implemented in the Swiss Logistics project.

---

## What Should Exist After Step 7?

You should be able to write

```dart
context.read<AuthProvider>().login(...)
```

The login process should complete without the UI knowing anything about HTTP.

---

# Step 8 — Router

Now we teach Flutter

where users should go.

Example

If

```text
Logged In
```

↓

Dashboard

Else

↓

Login Screen

This logic belongs inside

```text
app_router.dart
```

Not inside Widgets.

---

Router becomes the traffic police.

It asks

```text
Authenticated?
```

Yes

↓

Dashboard

No

↓

Login

---

## What Should Exist After Step 8?

When the app starts

```text
Token exists

↓

loadUser()

↓

Authenticated

↓

Dashboard
```

Otherwise

```text
Login Screen
```

---

# Step 9 — UI Screens

Only NOW

after everything works...

do we create

```text
Login Screen

Register Screen

Forgot Password

OTP

Reset Password

Profile
```

Notice

The screen only does

```dart
provider.login()
```

Nothing else.

---

Example

Button

↓

```dart
AuthProvider.login()
```

Everything else happens automatically.

---

## What Should Exist After Step 9?

A user should now be able to:

* Register
* Login
* Stay logged in after restarting the app
* Logout
* Navigate automatically based on authentication state

At this point, your authentication flow is functionally complete.

---

# Step 10 — Testing

Only now do we test everything.

Checklist:

✅ Register works

✅ Login works

✅ Wrong password shows error

✅ Internet off shows error

✅ Token saved

✅ Token restored

✅ Logout clears storage

✅ App restart keeps user logged in

✅ Expired token refreshes automatically

This is where many bugs are found—not during coding.

---

# How Everything Connects

Here's the complete relationship between the files.

```text
Login Screen
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
      ▼
Backend API
      │
      ▼
Response
      │
      ▼
UserModel
      │
      ▼
Provider updates UI
```

Notice that every layer talks only to the layer immediately below it.

This keeps your architecture clean and easy to reason about.

---

# Why This Order Matters

Suppose you create the Login Screen first.

It immediately asks:

> "Where is my provider?"

The provider doesn't exist.

Then you create the provider.

The provider asks:

> "Where is my repository?"

The repository doesn't exist.

Then the repository asks:

> "Where is Dio?"

Dio doesn't exist.

You end up constantly jumping between files, fixing missing dependencies.

Now compare that to the architecture-first approach.

When you finally create the Login Screen, every dependency is already in place.

The screen only has to display the UI and call the provider.

That's why professionals delay building the UI until the core architecture is ready.

---

# Mini Project Timeline

If you were starting a brand-new app tomorrow, your workflow would look like this:

| Step | What You Build           | Expected Outcome                    |
| ---- | ------------------------ | ----------------------------------- |
| 1    | Project folders          | Clean structure                     |
| 2    | Constants                | API endpoints ready                 |
| 3    | DioClient & Interceptors | Networking configured               |
| 4    | TokenStorage             | Secure token persistence            |
| 5    | Models                   | JSON ↔ Dart conversion              |
| 6    | Repository               | API communication works             |
| 7    | Provider                 | Business logic and state management |
| 8    | Router                   | Authentication-based navigation     |
| 9    | UI Screens               | Users can interact with the app     |
| 10   | Testing                  | Stable authentication flow          |

---

# Common Mistakes to Avoid

❌ Creating widgets before deciding on your architecture.

❌ Mixing HTTP requests into your UI.

❌ Storing tokens in widgets or providers instead of a dedicated storage class.

❌ Creating multiple `Dio` instances across the project.

❌ Putting navigation decisions inside every screen instead of centralizing them in the router.

❌ Letting one class have multiple responsibilities.

---

# Chapter Summary

By now you should understand:

* **Why project structure comes before coding.**
* **Why every folder exists.**
* **Why files are created in a specific order.**
* **What should be working after each step.**
* **How every layer depends on the previous one.**
* **Why professionals build the architecture before the UI.**

At this point, you have the blueprint. The next chapter is where we begin constructing the foundation one file at a time.

---

# Coming Next

## **Volume 1 – Chapter 3: Building the Foundation**

This chapter will be the first "hands-on" chapter.

Instead of just learning concepts, you'll build the first part of a production-ready authentication system from scratch.

We'll cover:

* Choosing the right project architecture (Feature-first vs Layer-first)
* Creating the folder structure from an empty Flutter project
* Building the `core` module
* Creating `ApiConstants`
* Setting up `DioClient`
* Configuring `PrettyDioLogger`
* Adding request timeouts
* Writing your first `AuthInterceptor`
* Understanding why each file is created before moving to the next

By the end of Chapter 3, you'll have a professional-grade networking foundation that can be reused not only for authentication, but for every feature in your Flutter application.
