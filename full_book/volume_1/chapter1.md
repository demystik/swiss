# Flutter Architecture Masterclass

## Volume 1 – Building Authentication Systems

### Chapter 1: Understanding the Big Picture Before Writing Any Code

> **Goal of this chapter**
>
> By the end of this chapter, you should understand **how a Flutter authentication system works from start to finish** before writing a single line of code.

Most beginners learn Flutter backwards.

They learn syntax first.

Then widgets.

Then Provider.

Then APIs.

Then authentication.

The result?

They know *how* to type code, but they don't know **why** they are typing it.

This book is different.

Before we create any files, we need to understand the complete journey of authentication.

---

# Imagine You're Building an Airport

Forget Flutter for five minutes.

Imagine you own an airport.

Thousands of passengers arrive every day.

Some are allowed to enter.

Some are not.

Some already have boarding passes.

Some need to check in.

Some passports have expired.

Some people lost their tickets.

Your airport needs a system.

Flutter authentication works exactly like this.

---

# Meet the Characters

Our authentication system has six important characters.

```
User
 ↓
UI (Screens)
 ↓
Provider
 ↓
Repository
 ↓
Dio Client
 ↓
Backend Server
```

Every login.

Every registration.

Every logout.

Every authenticated request.

Everything always follows this road.

---

# Character 1 — The User

The user knows nothing.

The user simply presses buttons.

Examples:

* Login
* Register
* Logout
* Forgot Password

The user never knows about APIs.

Never knows about tokens.

Never knows about JSON.

The user only interacts with screens.

Example:

```
Email:
Password:

[ Login ]
```

That's all.

---

# Character 2 — The UI

The UI is the messenger.

Its job is NOT to think.

Its job is NOT to call APIs directly.

Its job is simply:

* collect user input
* display loading
* display errors
* display success

Example:

```
Email:
Password:

Login button pressed
```

The UI says:

> "Provider, the user wants to login."

Nothing more.

---

# Character 3 — Provider

Think of Provider as your project manager.

It receives requests from the UI.

```
UI

↓

Provider
```

The Provider asks:

"Should I login?"

"Should I register?"

"Should I logout?"

The Provider does not know HTTP.

The Provider does not know URLs.

The Provider does not know JSON parsing.

Instead it tells the Repository:

> "Please login this user."

---

Example

```
Login Screen

↓

AuthProvider.login()

↓

AuthRepository.login()
```

---

# Character 4 — Repository

This is the department that talks to the internet.

If the Provider is the manager,

The Repository is the employee.

Repository knows:

* API URLs
* POST
* GET
* DELETE
* PATCH
* JSON

Example

```
POST

/api/v1/auth/login/
```

Repository sends

```
Email

Password
```

to the backend.

Backend replies

```
Access Token

Refresh Token

User
```

Repository returns everything back to Provider.

---

# Character 5 — Dio Client

Repository still doesn't know HOW to communicate.

It needs a vehicle.

That vehicle is Dio.

Imagine DHL.

Repository gives Dio a package.

```
Login request
```

Dio delivers it.

Server replies.

Dio returns.

That's all.

---

# Character 6 — Backend

The backend is the security officer.

Flutter never decides who can login.

Backend decides.

Flutter asks:

```
Can this user login?
```

Backend says

```
Yes
```

or

```
No
```

Flutter obeys.

Always.

---

# The Complete Login Journey

Now let's put everyone together.

```
User
```

presses Login

↓

```
Login Screen
```

collects email/password

↓

```
AuthProvider.login()
```

↓

```
AuthRepository.login()
```

↓

```
DioClient
```

↓

```
POST

/auth/login/
```

↓

Backend checks credentials

↓

Backend returns

```
User

Access Token

Refresh Token
```

↓

Repository saves tokens

↓

Provider updates state

↓

UI rebuilds

↓

Dashboard opens

Entire login completed.

---

# Why We Don't Call Dio Inside the Screen

Many beginners do this.

```
Button

↓

Dio.post()
```

inside the screen.

Looks simple.

But six months later...

Everything becomes impossible to manage.

Imagine 50 screens.

Every screen has:

```
Dio

JSON

URLs

Error handling

Loading

Token logic
```

Nightmare.

Instead we separate responsibilities.

---

Correct architecture

```
Screen

↓

Provider

↓

Repository

↓

Dio

↓

Server
```

Every layer has one job.

---

# The Golden Rule

Every file in Flutter should have **one responsibility only**.

Example

Login Screen

Job:

```
Display UI
```

Nothing else.

---

Auth Provider

Job:

```
Manage login state
```

Nothing else.

---

Repository

Job:

```
Call APIs
```

Nothing else.

---

Token Storage

Job:

```
Save tokens
```

Nothing else.

---

Interceptor

Job:

```
Attach Authorization header
```

Nothing else.

---

Because every file has one responsibility...

Projects become easy to maintain.

---

# What Happens After Login?

Many beginners think login ends here.

```
POST login
```

Wrong.

Login is only the beginning.

Backend returns

```
Access Token

Refresh Token
```

Flutter immediately stores both.

Why?

Because every future request needs them.

Example

User opens Riders screen.

Flutter requests

```
GET /riders/
```

Backend asks

```
Who are you?
```

Flutter sends

```
Authorization:

Bearer xxxxxxxxx
```

Backend says

```
Okay.

You're logged in.
```

Then returns riders.

Without token?

Backend replies

```
401 Unauthorized
```

Exactly what happened in your project earlier.

---

# Why We Needed an Auth Interceptor

Imagine making 200 API requests.

Without interceptor you'd write

```
Authorization:

Bearer token
```

200 times.

Instead,

the interceptor automatically adds it.

Every request becomes

```
GET riders

↓

Interceptor

↓

Adds token

↓

Server
```

You never think about it again.

---

# Why We Save the Refresh Token

Access Tokens expire.

Yours expired earlier.

Remember this error?

```
Token is expired
```

That's normal.

Backend expects it.

Instead of forcing users to login every 15 minutes,

Flutter uses

```
Refresh Token
```

to request a new access token.

User never notices.

Magic.

---

# Why We Built TokenStorage

Imagine closing the app.

Without storage,

the token disappears.

User logs in again.

Annoying.

Instead,

FlutterSecureStorage saves

```
Access Token

Refresh Token
```

on the device.

Next time app opens,

Flutter loads them automatically.

---

# What Happens When the App Starts?

Every app startup follows this sequence.

```
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

Read saved token

↓

Token exists?

Yes

↓

GET /auth/me/

↓

Authenticated

↓

Dashboard

```

Otherwise

```
No token

↓

Login Screen
```

---

# The Complete Architecture Diagram

```
               USER
                 │
                 ▼
          Login Screen
                 │
                 ▼
         AuthProvider
                 │
                 ▼
        AuthRepository
                 │
                 ▼
            Dio Client
                 │
                 ▼
        AuthInterceptor
                 │
                 ▼
         Backend Server
                 │
        ┌────────┴────────┐
        │                 │
     Success           Failure
        │                 │
        ▼                 ▼
 Save Tokens        Show Error
        │
        ▼
Dashboard
```

This single diagram explains nearly every authentication system you'll build in Flutter.

---

# Common Beginner Mistakes

### Mistake 1

Calling APIs inside Widgets.

❌ Wrong.

---

### Mistake 2

Saving tokens inside Provider.

❌ Wrong.

TokenStorage should do that.

---

### Mistake 3

Parsing JSON inside Widgets.

❌ Wrong.

Repository or Model should do it.

---

### Mistake 4

Putting business logic inside UI.

❌ Wrong.

UI should only display information and collect input.

---

### Mistake 5

Creating multiple Dio instances.

❌ Wrong.

Use **one shared `DioClient`** throughout the app, just as you corrected in your Swiss Logistics project.

---

# What You Should Understand Before Moving On

If you can confidently answer these questions, you're ready for Chapter 2:

1. Why should a screen never call Dio directly?
2. What is the responsibility of a Provider?
3. Why do we need a Repository?
4. Why do we save tokens?
5. Why is an Interceptor useful?
6. What happens when an access token expires?
7. What happens when the app starts?
8. What is the purpose of `loadUser()`?
9. Why is FlutterSecureStorage better than storing tokens in memory?
10. Can you explain the complete login flow without looking at any code?

If you can't answer all ten yet, reread this chapter. Everything that follows builds on these ideas.

---

# Chapter Summary

By the end of Chapter 1, you should have a mental model of the authentication system:

* **The UI** displays screens and collects user input.
* **The Provider** manages state and coordinates actions.
* **The Repository** communicates with the backend API.
* **The DioClient** handles HTTP requests.
* **The AuthInterceptor** automatically attaches authentication tokens.
* **The TokenStorage** securely stores tokens on the device.
* **The Backend** authenticates users and protects resources.
* **The Access Token** proves who the user is.
* **The Refresh Token** obtains a new access token when the old one expires.
* **Each layer has exactly one responsibility**, making the project easier to understand, test, and maintain.

---

## Coming Next

**Volume 1 – Chapter 2**

> **Designing the Authentication Folder Structure**

In the next chapter, we'll move from concepts to implementation. You'll learn:

* why we create certain folders before writing code,
* the exact order in which files should be created,
* what each file is responsible for,
* what you should expect after completing each step,
* and how all the files connect into one working authentication system.

From Chapter 2 onward, we'll begin constructing the system piece by piece, following the same architecture you used in the Swiss Logistics project.
