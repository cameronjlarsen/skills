### Opening an ADO PR

**Replaces** poteto `playbooks/opening-a-pr.md` under cameron-mode.

Invoked at the end of shipping playbooks when a PR is needed. Follow `create-ado-pr` for org defaults and step detail.

**Defaults (TMO / absinc unless overridden):** org `https://absinc.visualstudio.com`, project `Net`, branch `WI{number}`, target `dev`, title `WI{number}: {System.Title}`, work item linked on create.

**Worktree.** Same as poteto: prefer a worktree off the right base; fresh worktree when the checkout is dirty with unrelated work.

**Commits.** Small, ordered, landable commits. Prefer `work-unit-commits` when reshaping. `/deslop` before commit when available. **humanizer** + **unslop** on PR body and commit messages meant for humans.

1. Draft the PR proposal through `create-ado-pr` pre-create gates. **Do not push. Do not create the PR.**
2. Show title, target, work item link, and body. Body: Summary + Test plan. Skip a Changes table when the diff already shows the files.
3. Wait for explicit approval. Then push (normal `-u` if remote absent; no force unless asked) and create the PR.
4. Stop again for post-create gates the skill defines (for example Story Points Actual). Propose, wait, then update.
5. After create, run babysit only if the human wants the PR watched. Skeptical bot posture from poteto applies after the propose-before-code gate on new findings.

**Reply:** proposal awaiting approval, or PR URL after create.
