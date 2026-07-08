# Phase 1: Define the Customer App Scope

Do not start with login screens immediately.

First, we need to know what the customer can actually do.

A logistics customer app usually has this flow:

```
Open App
    |
    ↓
Splash Screen
    |
    ↓
Check Authentication
    |
    ├── New user → Register
    |
    └── Existing user → Login
              |
              ↓
          Customer Home
              |
              ↓
       Request Delivery
              |
              ↓
       Track Delivery
              |
              ↓
       Delivery History
              |
              ↓
       Profile
```

For MVP, we should avoid building unnecessary features.

---


swiss_logistics_customer/

lib/

├── core/
│   ├── constants/
│   ├── network/
│   ├── storage/
│   ├── theme/
│   └── router/

├── features/

│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/

│   ├── home/

│   ├── delivery/

│   ├── tracking/

│   └── profile/

└── main.dart