---
name: browser-adapter
description: Browser automation integration for web testing, scraping, and screenshot capture. Use when the user asks about browser-based tools or web automation.
user-invocable: true
version: {{BOOTSTRAP_VERSION}}
---

# Browser Adapter

When the user needs browser automation (web testing, scraping, screenshots):

1. Browser artifacts — screenshots, traces, recordings — go in `artifacts/browser/`.
2. Each browser session or test run gets a timestamped subdirectory.

## Directory structure

```
artifacts/browser/
  <run-id>/   # screenshots, traces, HAR files per run
```

## Considerations

- Prefer headless mode for automated runs.
- Clean up old artifacts periodically to avoid disk bloat.
