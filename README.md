<div align="center">

# LendFlow AI

**A backend-first loan processing platform.**
Real underwriting rules, a tested decision engine, and an AI assistant.

[![Ruby](https://img.shields.io/badge/Ruby-3.3.6-CC342D?style=flat-square&logo=ruby&logoColor=white)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1-D30001?style=flat-square&logo=rubyonrails&logoColor=white)](https://rubyonrails.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14-4169E1?style=flat-square&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Groq](https://img.shields.io/badge/Groq-Llama_3.3_70B-F55036?style=flat-square&logo=data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCAyNCAyNCI+PHBhdGggZmlsbD0id2hpdGUiIGQ9Ik0xMiAyTDIgN2wxMCA1IDEwLTV6Ii8+PC9zdmc+&logoColor=white)](https://groq.com/)
[![CI](https://img.shields.io/badge/CI-passing-3FB950?style=flat-square&logo=githubactions&logoColor=white)](#)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=flat-square)](#license)

**[Live demo →](https://lendflow-ai.onrender.com)**
*Free-tier hosting - the first request after a period of inactivity may take 10-30 seconds to wake up.*

</div>

---

## Table of contents

- [Why this project](#why-this-project)
- [Architecture](#architecture)
- [Database schema](#database-schema)
- [The decision engine](#the-decision-engine)
- [The AI assistant](#the-ai-assistant)
- [API reference](#api-reference)
- [Getting started](#getting-started)
- [Testing](#testing)
- [Roadmap](#roadmap)

---

## Why this project

Loan underwriting is a good stress-test for backend fundamentals: it needs data you can trust, rules you can audit, and answers that hold up when someone asks *"why?"*

LendFlow AI models that whole loop onboarding, credit data, an automated decision, and a policy assistant that explains the outcome using patterns that would hold up in a real production system:

- 🗃️ Relational modeling with **real constraints**, not just app level validation
- ⚖️ Business rules as a **standalone, tested service object** not scattered across controllers
- 🔌 Clean **RESTful API design**, nested where the domain is nested
- 🧠 A genuine **retrieval-augmented generation** pipeline, grounded against hallucination
- ✅ **Automated tests + CI** (lint, security scan, test suite) on every push

## Architecture

A **modular monolith**, deliberately not microservices. Each domain concern is cleanly separated into its own model and service object, which keeps the codebase simple to run today while leaving an obvious seam to split into independent services later, if scale ever demanded it.

```
                Client
        (curl · Postman · demo console)
                   │
                   ▼
┌──────────────────────────────────────┐
│           Rails API  (this app)       │
│                                        │
│   Users ──┬── Loan Applications       │
│           │         │                 │
│           │         ▼                 │
│   Credit Profiles   Loan Decisions    │
│           │         ▲                 │
│           └─────────┘                 │
│         LoanDecisionEngine            │
│        (service object — rules)       │
│                                        │
│           AiAssistantService          │
│      (RAG: retrieval + Groq LLM)      │
└──────────────────────────────────────┘
                   │
                   ▼
              PostgreSQL
```

| Layer | Choice | Why |
|---|---|---|
| Framework | Rails 8, `--api` mode | No view layer needed, this is a backend service, consumable by any frontend |
| Database | PostgreSQL | Real constraints, foreign keys, and precision safe money types |
| Business logic | Plain Ruby service objects | Testable in isolation, no framework coupling |
| AI inference | Groq (Llama 3.3 70B) | Free tier, fast inference, OpenAI compatible API |
| CI | GitHub Actions | Rubocop lint + Brakeman security scan + full test suite, on every push |
| Hosting | Render | Free tier, zero downtime deploys from `main` |

## Database schema

| Table | Purpose |
|---|---|
| `users` | Applicant identity and income data |
| `credit_profiles` | One per user - credit score, debt-to-income ratio, bankruptcy history |
| `loan_applications` | Belongs to a user - amount, purpose, term, status |
| `loan_decisions` | One per application - decision, interest rate, and a human readable reason |

**Design choices worth noting:**

- 💰 Money fields use `decimal` with explicit precision/scale, never floats, floats silently round in ways that matter for currency
- 🔒 Uniqueness and foreign-key constraints are enforced **at the database level**, not just in application code, the database is the real source of truth
- 📋 `loan_decisions.reason` is never blank, this mirrors a real regulatory requirement (adverse action notices): lenders must state *why* a loan was denied

## The decision engine

`LoanDecisionEngine` is a plain Ruby service object, not a model, not a controller, that evaluates an application against four underwriting rules:

| Rule | Threshold |
|---|---|
| Credit score | ≥ 720 |
| Debt-to-income | ≤ 35% |
| Annual income | ≥ $60,000 |
| Loan amount | ≤ 5× monthly income |

```
   all 4 pass  →  ✅ approved
   1 fails     →  🟡 manual_review
   2+ fail     →  🔴 rejected
```

Every decision returns a plain-language reason. This is a deliberate **hard-cutoff** model rather than a weighted score, simpler to build correctly and easier to audit, which matters more for a v1 lending system than nuance does. See [Roadmap](#roadmap) for where a scored model would fit later.

## The AI assistant

A real, if right-sized, RAG pipeline:

1. **Retrieve** — `PolicyRetriever` keyword matches the question against a small set of policy documents (`loan_policy`, `faq`, `underwriting_guidelines`)
2. **Ground** — the matched policy text is injected into the prompt, with explicit instructions not to invent applicant-specific facts it wasn't given
3. **Generate** — `AiAssistantService` sends the grounded prompt to Groq (Llama 3.3 70B) and returns the answer alongside its sources

```ruby
AiAssistantService.answer("Why was my loan rejected?")
# => { answer: "...", sources: ["faq", "loan_policy"] }
```


## API reference

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/users` | Create a user |
| `GET` | `/users/:id` | Fetch a user |
| `POST` | `/users/:user_id/credit_profile` | Attach a credit profile |
| `GET` | `/users/:user_id/credit_profile` | Fetch a credit profile |
| `POST` | `/loan_applications` | Create a loan application |
| `GET` | `/loan_applications/:id` | Fetch an application (includes user + decision) |
| `POST` | `/loan_applications/:id/decision` | Run the decision engine |
| `GET` | `/loan_applications/:id/decision` | Fetch the existing decision |
| `POST` | `/ai/chat` | Ask the policy assistant a question |

<details>
<summary><b>Example: full flow via curl</b></summary>

```bash
# Create an applicant
curl -X POST https://lendflow-ai.onrender.com/users \
  -H "Content-Type: application/json" \
  -d '{"user": {"first_name": "Jane", "last_name": "Doe", "email": "jane@example.com", "income": 85000, "employment_status": "employed"}}'

# Attach a credit profile
curl -X POST https://lendflow-ai.onrender.com/users/1/credit_profile \
  -H "Content-Type: application/json" \
  -d '{"credit_profile": {"credit_score": 760, "debt_to_income": 0.22, "bankruptcies": 0}}'

# Submit a loan application
curl -X POST https://lendflow-ai.onrender.com/loan_applications \
  -H "Content-Type: application/json" \
  -d '{"loan_application": {"user_id": 1, "amount": 12000, "purpose": "home_improvement", "term_months": 24}}'

# Run the decision engine
curl -X POST https://lendflow-ai.onrender.com/loan_applications/1/decision

# Ask the assistant
curl -X POST https://lendflow-ai.onrender.com/ai/chat \
  -H "Content-Type: application/json" \
  -d '{"question": "What documents are required to apply?"}'
```

</details>

## Getting started

```bash
git clone https://github.com/Pujitha-Reddy/lendflow-ai.git
cd lendflow-ai
bundle install
bin/rails db:create db:migrate
bin/rails server
```

Requires **Ruby 3.3.6+** and **PostgreSQL 14+**. Visit `http://localhost:3000` for the demo console, or hit the API directly.

To use the AI assistant locally, add a Groq API key (free, no credit card - [console.groq.com](https://console.groq.com)) to your Rails credentials:
```bash
EDITOR="code --wait" bin/rails credentials:edit
```
```yaml
groq_api_key: your_key_here
```

## Testing

```bash
bin/rails test
```

Covers model validations, the decision engine's rule logic across all outcome paths, and the AI assistant endpoint. CI runs this suite, Rubocop, and Brakeman on every push.

## Roadmap

- [ ] Split into independent services (User · Loan · Decision · AI) behind async messaging, if scale ever justified it
- [ ] Move the decision engine to a weighted risk-scoring model
- [ ] Background jobs (Sidekiq) for async notifications
- [ ] Document upload and verification
- [ ] Admin dashboard for the manual-review queue
- [ ] Swap keyword retrieval for embeddings + `pgvector`, once the policy doc set grows

---

<div align="center">

Built by [Pujitha Reddy](https://github.com/Pujitha-Reddy)

</div>
