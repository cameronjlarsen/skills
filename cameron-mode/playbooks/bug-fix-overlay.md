### Bug fix overlay (after poteto Bug fix)

Run poteto `playbooks/bug-fix.md` first. Then apply:

1. Verification is legacy-aware. If there is no cheap automated test path, live/manual repro on the real surface is enough to prove fixed. Do not block done on creating a new test harness unless asked.
2. On a WI branch, only fix branch-caused issues by default. Pre-existing bugs: report and leave unless the human expands scope.
3. If the human asked to stay in the loop (review/babysit context), propose the fix before coding (**Review findings**).
4. Opening a PR means `playbooks/opening-ado-pr.md`.

**Reply:** same as poteto Bug fix. Include the proof surface you used (test command vs live repro).
