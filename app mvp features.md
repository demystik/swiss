# Phase 2: Define Customer App MVP Features

Based on your backend and the Swiss Logistics idea, I would start with:

## 1. Authentication

Screens:

```
Splash Screen

Onboarding (optional)

Login

Register

Forgot Password (if backend supports it)

Email/Phone verification (if backend supports it)
```

Backend:

```
POST /api/v1/auth/register/

POST /api/v1/auth/login/

GET /api/v1/auth/me/
```

---

## 2. Customer Home Dashboard

After login:

The customer should see:

```
Welcome, Ahmed

What do you want to deliver?

[ Request Delivery ]

Recent Deliveries

Upcoming Delivery

Quick Actions
```

---

## 3. Create Delivery Request

This is the core feature.

The customer needs to provide:

Example:

```
Pickup Location

Drop-off Location

Package Description

Package Size

Recipient Name

Recipient Phone

Delivery Notes

Confirm Request
```

But before designing this screen, we need to confirm the backend.

We need Swagger endpoints for:

* Creating delivery
* Getting delivery details
* Listing deliveries

---

## 4. Track Delivery

Customer should see:

```
Delivery #1024

Status:

✓ Request Created

✓ Rider Assigned

✓ Rider Picked Package

✓ In Transit

✓ Delivered


Rider:
John Doe

Vehicle:
Toyota Corolla

Location:
Map
```

Again, backend determines what is possible.

---

## 5. Profile

Basic:

```
Profile Picture

Name

Phone

Email

Account Settings

Logout
```

Backend:

Probably:

```
GET /auth/me/
```

---

