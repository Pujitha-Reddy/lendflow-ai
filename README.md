**Live demo:** https://lendflow-ai.onrender.com  
*(Free-tier hosting — the first request after a period of inactivity may take 10–30 seconds to wake up.)*

# LendFlow AI

A backend-first loan processing platform built with Ruby on Rails. It models a real consumer lending workflow — from customer onboarding through automated underwriting decisions — with an AI-powered assistant that explains lending policy using retrieval-augmented generation.

## Why this project

This project demonstrates backend engineering fundamentals that matter in production systems: relational data modeling with real constraints, business-rule encapsulation, RESTful API design, and automated testing — rather than a toy CRUD app.

## Architecture

Built as a modular monolith rather than microservices — a deliberate choice for this stage. Each domain concern (users, loan applications, credit profiles, decisions) is cleanly separated into its own model and, where business logic lives, its own service object. This keeps the codebase simple to run and reason about now, while leaving a clear path to split into independent services (User Service, Loan Service, Decision Service) if the system needed to scale that way later.

```
Client (curl / Postman / future frontend)
        │
        ▼
Rails API (this app)
├── Users
├── Loan Applications
├── Credit Profiles
├── Loan Decisions
└── LoanDecisionEngine (service object — business rules)
        │
        ▼
PostgreSQL
```

## Database schema

- **users** — applicant identity and income data
- **credit_profiles** — one per user; credit score, debt-to-income ratio, bankruptcy history
- **loan_applications** — belongs to a user; amount, purpose, term, status
- **loan_decisions** — one per loan application; decision, interest rate, and a human-readable reason

Key design choices:
- Money fields use `decimal` with explicit precision/scale rather than floats, to avoid rounding errors
- Uniqueness and foreign-key constraints are enforced at the database level, not just in application code
- `loan_decisions.reason` is always populated, mirroring the real regulatory requirement that lenders must state why a loan was denied

## Decision engine

`LoanDecisionEngine` is a plain Ruby service object (not tied to a model or controller) that evaluates a loan application against four underwriting rules:

- Credit score ≥ 720
- Debt-to-income ≤ 35%
- Annual income ≥ $60,000
- Loan amount ≤ 5× monthly income

All four pass → **approved**. One failure → **manual review**. Multiple failures → **rejected**. Every decision includes a plain-language explanation.

This is intentionally a hard-cutoff rules engine rather than a scored/weighted model — the natural next evolution would be a weighted risk score, but hard cutoffs are simpler to build correctly and easier to audit, which matters more for a first version of a lending system.

## API

| Method | Endpoint | Description |
|---|---|---|
| POST | `/users` | Create a user |
| GET | `/users/:id` | Fetch a user |
| POST | `/users/:user_id/credit_profile` | Attach a credit profile to a user |
| GET | `/users/:user_id/credit_profile` | Fetch a user's credit profile |
| POST | `/loan_applications` | Create a loan application |
| GET | `/loan_applications/:id` | Fetch a loan application (includes user + decision) |
| POST | `/loan_applications/:id/decision` | Run the decision engine |
| GET | `/loan_applications/:id/decision` | Fetch the existing decision |

## Setup

```bash
git clone https://github.com/Pujitha-Reddy/lendflow-ai.git
cd lendflow-ai
bundle install
bin/rails db:create db:migrate
bin/rails server
```

Requires Ruby 3.3.6+ and PostgreSQL 14+.

## Testing

```bash
bin/rails test
```

## Future roadmap

- Split into independent services (User, Loan, Decision, AI) connected via async messaging, once/if scale justified it
- Move the rules engine to a weighted scoring model
- Background jobs (Sidekiq) for async notifications
- Document upload and verification
- Admin dashboard for manual review queue