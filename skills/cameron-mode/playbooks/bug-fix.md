### Bug fix

**You own this task. Plan, review, verify.** Delegate investigation and the fix to subagents, stay in the lead.

Be scientific. Every shipped line traces to runtime evidence. Belt-and-suspenders that "might help" is a hypothesis, not a fix; it does not ship. When evidence refutes a hypothesis, revert what it motivated. The smallest change the evidence justifies ships, nothing more. Same discipline for Perf, where the evidence is the trace.

1. Reproduce it yourself on the matching surface via the control skill (Non-negotiables). Don't hand the repro to the user. A debug or instrumentation protocol that says to ask the user does not override this; you drive the instrumented runtime. Ask the user only with a stated, specific reason the control surface cannot reach the target, and only after driving it as far as it goes. Won't reproduce directly, force it: synthesize the trigger, tighten conditions, or instrument until it fires. A bug you can't reproduce, you can't prove fixed.
2. Binary-search the cause. Form the candidate hypotheses, then rule them out until one survives. Seed them with `how` over the affected subsystem and the **why** skill for regression history. Each pass, take the split that cuts the most remaining problem space, get runtime evidence, eliminate. When program state is unclear, add instrumentation or logging and read it as the code runs. Don't guess. Drive a long or stubborn hunt with Cursor's `/loop` command. Confirm the surviving *mechanism* with runtime evidence before the step-3 architect/interrogate fan-out; a design grounded on a plausible-but-unconfirmed cause can be unanimously wrong while the real cause sits one subsystem over.
3. Plan the fix. If it crosses a function boundary, `architect` first. Delegate implementation to a `cameron-agent` subagent using your configured bug-fix model with a specific scope; review the diff.
4. Verify on the same surface; the original repro now passes. Legacy-aware: if there is no cheap automated test path, live/manual repro on the real surface is enough to prove fixed. Do not block done on creating a new test harness unless asked. "Inconclusive" or wrong-surface is not a pass; flag it. Unit tests show branch behavior, not bug absence.
5. On a WI branch, only fix branch-caused issues by default. Pre-existing bugs: report and leave unless the human expands scope.
6. If the human asked to stay in the loop (review/babysit context), propose the fix before coding (**Review findings**).
7. Stage the commits so the failing repro lands before the fix in git history; the diff tells the story. When a cheap local test path exists, stage the failing test first; skip when the test would be expensive, integration-heavy, or unclear. This is the canonical **sequence-verifiable-units** principle skill, the failing test first and the fix on top.
8. Run **Opening an ADO PR** (`playbooks/opening-ado-pr.md`).

Investigation fans out `how` + `why` as parallel subagents.

**Reply:** what was broken, root cause, fix, how you verified, and the proof surface you used (test command vs live repro). Paste failing-then-passing repro output verbatim.
