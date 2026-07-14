### Review findings

**Cameron-only.** Propose first. Code second.

Applies to PR threads, CI failures, babysit, Bugbot, and similar flagged issues.

1. Fetch the findings. Group by theme.
2. For each: propose **fix**, **by design** (reason), **wontfix** (reason), or **ask**.
3. Flag pre-existing / not caused by this branch. Default: leave unless scope expands.
4. Present the proposal. Do not change code until approved (whole set or per item).
5. On approval, implement only approved items. Prefer "implement but don't commit" when they want to review the patch first.
6. Verify with the Cameron Verification delta (tests and/or live repro).
7. Commit when they approve committing. Push/PR only via **Opening an ADO PR**.

**Reply:** finding → proposal. After implement: what changed, deferred items, proof surface.
