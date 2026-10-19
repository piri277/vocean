
---
name: code-review
description: Review code changes for correctness, regressions, security, resource leaks, maintainability, and missing tests. Use before completing significant tasks, reviewing a diff, or preparing a commit.
---

# Code Review

## Review process
- Inspect the diff and understand the intended behavior.
- Prioritize actionable defects over stylistic preferences.
- Check logic errors, edge cases, null handling, and error paths.
- Check asynchronous operations and lifecycle management.
- In Flutter, inspect widget lifecycle, controller disposal, and state updates.
- For camera features, check permission handling and resource cleanup.
- Check for secrets, unsafe data handling, and unnecessary logging.
- Identify missing tests for important behavior.
- Verify that changes do not modify unrelated functionality.

## Findings
- Report findings from highest to lowest severity.
- For each finding, provide the file and relevant line, explain the impact, and suggest a fix.
- Distinguish confirmed defects from potential risks.
- Avoid reporting purely subjective style preferences as bugs.
- If no actionable defects are found, say so without claiming the code is perfect.

## Scope
- Review the actual changes first.
- Expand to surrounding code when needed.
- Do not modify files during a review unless explicitly asked to fix the findings.
- Do not claim tests passed unless they were executed.
