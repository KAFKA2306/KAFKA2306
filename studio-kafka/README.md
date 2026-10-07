# Studio Kafka startup application pack

This directory is a dependency-free, portable preparation pack for Studio Kafka.

## Purpose

- provide a simple public landing page without paid hosting
- keep the wording used for startup-program applications in one reviewable place
- make later migration to a custom domain trivial
- avoid claiming incorporation, funding, or a company email before those facts exist

## Free-now setup

The landing page is plain `index.html`. It can be served by GitHub Pages, Vercel Hobby, Cloudflare Pages, or any static host without a build step.

## Remaining paid / external dependency

Anthropic currently requires a company website and a business email that matches the website domain for the Claude Startups application. A custom domain is therefore the one part that cannot be guaranteed at zero cost forever.

When a domain is purchased later:

1. point the domain at the chosen static host
2. create a domain-matched mailbox or forwarding address
3. replace the temporary contact path on the site
4. submit the application using the reviewed wording in `claude-startups.md`

No application should state that Studio Kafka is incorporated, funded, or has employees unless that is separately verified.
