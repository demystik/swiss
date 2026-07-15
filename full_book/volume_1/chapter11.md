# Volume 1 – Authentication Masterclass

# Chapter 11: Building a Production-Ready Error Interceptor (Automatic Token Refresh)

This chapter is one of the most important chapters in this entire book.

If you master this chapter, you'll understand how apps like:

* Instagram
* Facebook
* WhatsApp
* Uber
* Bolt
* Banking Apps

keep users logged in for days, weeks, or even months without asking them to log in again.

It isn't magic.

It's a well-designed **Error Interceptor**.

---

# What Problem Are We Solving?

Imagine this timeline.

```
9:00 AM

User logs in.

↓

Access Token expires at 9:15.

↓

User opens Dashboard at 9:16.
```

The app sends

```
GET /riders
```

Server replies

```
401 Unauthorized

Token Expired
```

Without an ErrorInterceptor...

Your app immediately logs the user out.

That is a terrible user experience.

---

Professional apps do something smarter.

Instead they say

```
Oops...

The access token expired.

No problem.

I still have the Refresh Token.

Let me get another Access Token.

Done.

Retry the request.
```

The user never notices.

---

# The Difference

### Beginner App

```
Access Token Expired

↓

401

↓

Logout
```

---

### Professional App

```
Access Token Expired

↓

401

↓

Refresh Token

↓

New Access Token

↓

Retry Original Request

↓

Success
```

Exactly the same login session.

No interruption.

---

# What Is an Error Interceptor?

Remember our AuthInterceptor.

It runs

**before**

every request.

```
Request

↓

AuthInterceptor

↓

Server
```

The ErrorInterceptor is different.

It runs

**after**

the server responds with an error.

```
Request

↓

Server

↓

401 Error

↓

ErrorInterceptor
```

So...

AuthInterceptor handles

```
Outgoing Requests
```

ErrorInterceptor handles

```
Incoming Errors
```

Huge difference.

---

# Think of It Like Airport Security

Imagine boarding a plane.

At the gate

Security checks your boarding pass.

That's

```
AuthInterceptor
```

---

Now imagine...

Halfway to the plane...

Someone notices your boarding pass expired.

Instead of sending you home...

They say

```
Wait.

Let's print a new pass.
```

Then you continue walking.

That's

```
ErrorInterceptor
```

---

# When Does It Run?

Only when something goes wrong.

For example

```
401

403

404

500
```

Most importantly...

```
401 Unauthorized
```

---

# The Complete Flow

```
User

↓

GET /riders

↓

Server

↓

401

↓

ErrorInterceptor

↓

Refresh Token

↓

POST /refresh

↓

New Access Token

↓

Save Token

↓

Retry GET /riders

↓

200 OK
```

That is the entire refresh process.

---

# Let's Build It Step by Step

The ErrorInterceptor must answer four questions.

Question One

```
Was the error a 401?
```

If not...

Ignore it.

```
404

↓

Pass Error
```

```
500

↓

Pass Error
```

Only

```
401
```

matters.

---

Question Two

```
Do we have a Refresh Token?
```

Read

```
FlutterSecureStorage
```

If no refresh token exists

```
Logout
```

because we cannot recover.

---

Question Three

```
Can the server issue another Access Token?
```

Call

```
POST

/auth/refresh_token/
```

Body

```json
{
   "refresh":"xxxxx"
}
```

---

Server replies

```json
{
   "access":"new_token"
}
```

Perfect.

Save it.

---

Question Four

```
Can we retry the original request?
```

Absolutely.

Remember

Dio already knows

```
Method

URL

Headers

Body

Query Parameters
```

We simply send it again.

```
Original Request

↓

Retry

↓

Success
```

---

# Why Retry?

Imagine ordering food.

Restaurant says

```
Sorry.

Your membership card expired.
```

You renew it.

Would you place the order again manually?

No.

The restaurant should simply continue preparing your food.

Same thing here.

The request was already correct.

Only the token expired.

---

# The Entire Refresh Flow

```
GET /riders

↓

401

↓

Read Refresh Token

↓

POST /refresh

↓

Receive New Access Token

↓

Save Token

↓

Retry GET /riders

↓

Return Success
```

Simple.

---

# Why Only Save Access Token?

Notice

Refresh endpoint returns

```json
{
   "access":"new"
}
```

NOT

```json
{
   "refresh":"..."
}
```

That means

```
Refresh Token

stays the same.
```

Only

```
Access Token

changes.
```

---

# Where Should Refresh Logic Live?

Many beginners put refresh code inside

```
Repository
```

Wrong.

Others put it inside

```
Provider
```

Also wrong.

Refreshing tokens has nothing to do with business logic.

It belongs inside

```
ErrorInterceptor
```

because

the interceptor is already handling the error.

---

# Why Not Refresh Inside Every Repository?

Imagine having

```
Users Repository

Orders Repository

Payment Repository

Profile Repository

Settings Repository

Messages Repository

Notifications Repository
```

Every repository would need

```
if (401)

refresh()

retry()
```

Seven times.

Or...

One ErrorInterceptor.

One place.

Professional code always avoids duplication.

---

# Understanding the Retry

This confuses almost everyone.

Suppose you sent

```http
GET

/riders?page=1
```

Server says

```
401
```

Inside ErrorInterceptor

you already have

```
RequestOptions
```

which contains

```
URL

Method

Headers

Body

Parameters
```

You don't recreate anything.

You simply resend it.

Think of it as pressing

```
Retry
```

instead of writing a brand-new request.

---

# A Visual Example

Original request

```
GET

/riders?page=1
```

fails.

ErrorInterceptor changes only one thing

```
Authorization Header
```

Old

```
Bearer OLD_TOKEN
```

New

```
Bearer NEW_TOKEN
```

Everything else stays exactly the same.

---

# What Happens If Refresh Also Fails?

Suppose

```
Refresh Token

has expired.
```

Server replies

```
401
```

again.

Now what?

Logout.

Because both tokens are invalid.

Flow

```
Access Expired

↓

Refresh Expired

↓

Clear Storage

↓

Logout

↓

Login Screen
```

Nothing else can be done.

---

# One Very Important Problem

Imagine this.

Ten API requests leave the app at the same time.

```
GET Riders

GET Profile

GET Orders

GET Wallet

GET Messages
```

Access token expired.

All five receive

```
401
```

Should all five refresh the token?

No.

That would send

```
POST /refresh

POST /refresh

POST /refresh

POST /refresh

POST /refresh
```

Five times.

Wasteful.

Professional apps refresh

only once.

---

# The Refresh Lock

Professional apps do this.

```
Request 1

↓

Refreshing...

```

Requests

2

3

4

5

simply wait.

```
Waiting...

Waiting...

Waiting...
```

When refresh finishes

everyone continues.

One refresh.

Many requests.

Very efficient.

---

# This Is Called Synchronization

Instead of

```
Refresh

Refresh

Refresh
```

we get

```
Refresh Once

↓

Everybody Continues
```

This is why production authentication feels instant.

---

# Responsibilities of the ErrorInterceptor

Its job is surprisingly small.

Only these tasks:

✔ Detect 401 responses.

✔ Read the Refresh Token.

✔ Request a new Access Token.

✔ Save the new Access Token.

✔ Retry the original request.

✔ Logout if refresh fails.

Nothing more.

---

# What the ErrorInterceptor Should NOT Do

It should never:

❌ Show dialogs.

❌ Display SnackBars.

❌ Navigate to screens directly.

❌ Fetch business data.

❌ Update Providers.

Its only responsibility is networking.

---

# Complete Error Recovery Flow

```
User

↓

Repository

↓

Dio

↓

AuthInterceptor

↓

Server

↓

401

↓

ErrorInterceptor

↓

Refresh Token

↓

Server

↓

New Access Token

↓

Save Token

↓

Retry Request

↓

Repository

↓

Provider

↓

UI
```

Notice something amazing.

The UI never knew anything happened.

---

# Beginner Mistakes

❌ Logging users out immediately after a 401.

✔ Refresh first.

---

❌ Refreshing inside every repository.

✔ Refresh inside the ErrorInterceptor.

---

❌ Refreshing multiple times for multiple requests.

✔ Refresh once and let other requests wait.

---

❌ Forgetting to save the new Access Token.

✔ Always overwrite the old one.

---

❌ Retrying the request with the old Authorization header.

✔ Replace it with the new token before retrying.

---

❌ Assuming refresh will always succeed.

✔ If refresh fails, clear storage and log the user out.

---

# Chapter Summary

By the end of this chapter, you should understand:

* Why access tokens expire.
* Why refresh tokens exist.
* The purpose of an ErrorInterceptor.
* How automatic token refresh works.
* Why repositories should never handle token refresh.
* How to retry failed requests safely.
* Why refresh should happen only once, even when many requests fail simultaneously.
* When to log the user out.

---

# Up Next: Chapter 12 — Authentication Architecture for Large Flutter Apps

Now that you understand the mechanics of authentication, we'll zoom out and study how professional Flutter teams organize their projects.

You'll learn:

* How to structure authentication folders.
* Where every file belongs.
* How to scale from 10 files to 500+ files without creating chaos.
* Dependency Injection and why sharing a single `DioClient` matters.
* Common architectural mistakes that make projects difficult to maintain.
* The exact folder structure used in production Flutter applications.

This chapter is where you'll move from writing working code to designing clean, scalable applications that other developers can easily understand and maintain.
