### Merge review

**Cameron-only.** Report branch-caused risk against the merge base (usually `origin/dev` for TMO WI branches).

1. Confirm source branch and merge base. Diff `merge-base...HEAD`.
2. Fan to a Composer subagent for large diffs or when `pr-merge-review` is requested. Parent owns the final report.
3. Separate **caused by this branch** from **pre-existing**. Only the former are in-scope by default.
4. Rank findings. Propose resolutions. Do not implement unless the human switches into **Review findings** with approval to code.
5. Plannotator only if the human asks or accepts an offer. Do not auto-launch.

**Reply:** scope summary, in-scope findings with evidence, out-of-scope notes, recommended next step.
