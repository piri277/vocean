
---
name: debugging
description: Investigate reproducible bugs, Flutter errors, failed tests, crashes, dependency problems, and unexpected application behavior. Use when diagnosing or fixing a defect.
---

# Debugging

## Investigation
- Reproduce the issue or identify a reliable failing test.
- Read the full relevant error message and stack trace.
- Locate the affected code and trace the execution path.
- Inspect recent changes and relevant dependencies.
- Form a hypothesis before editing.
- Distinguish the root cause from secondary symptoms.

## Fix
- Make the smallest change that correctly addresses the root cause.
- Preserve existing behavior outside the affected area.
- Do not suppress exceptions or weaken validation just to hide errors.
- Do not replace major components without evidence that it is necessary.
- Explain any unavoidable workaround and its limitations.

## Verification
- Run the smallest relevant test first.
- Run flutter analyze when applicable.
- Add a regression test when practical.
- Check related edge cases.
- Report the root cause, files changed, checks run, and remaining risks.
- Never claim a bug is fixed unless the available evidence supports it.
