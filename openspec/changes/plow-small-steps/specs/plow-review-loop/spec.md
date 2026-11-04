## Purpose

Defines how the plow skill breaks a change into reviewable steps, routes and seals them, limits autonomy to mechanical work, and keeps the plan and its own output honest and short.

## ADDED Requirements

### Requirement: One commit per step is the review unit

In gated mode, plow SHALL work a `## N.` section one task-sized step at a time. Each step SHALL be its own commit, started with `jj new`, and the human SHALL review that commit before plow starts the next step. A section SHALL count as sealed only when every commit in it has been reviewed with no open feedback. Plow SHALL NOT build a whole section and then split it into commits afterward.

#### Scenario: A section with three tasks

- **WHEN** plow works a section whose tasks are 2.1, 2.2, and 2.3
- **THEN** it produces at least three commits, one or more per task, and stops for review after each one

#### Scenario: Feedback on one step

- **WHEN** the human leaves feedback on a step's commit
- **THEN** plow applies the feedback to that same commit and presents it again, and does not start the next step until that commit is reviewed clean

#### Scenario: Human fixes something by hand

- **WHEN** the human edits a file during a step
- **THEN** plow rereads the changed files before continuing, keeps the edit as part of that step's commit, and does not revert or rewrite it unless asked

#### Scenario: Sealing a section

- **WHEN** the last step in a section is reviewed clean
- **THEN** plow marks the section sealed without a later split, squash, or reorder of its commits

### Requirement: Oversized steps are unreviewable

Plow SHALL give a step the `unreviewable` verdict when its diff exceeds the size limit. The default limit SHALL be about 300 changed lines (added plus removed) and SHALL be configurable. When the repo supplies its own size check, plow SHALL use that check's verdict instead of its own count. An `unreviewable` step SHALL go back to the agent to be split or redone and SHALL NOT be routed to a human or sealed.

#### Scenario: Step over the limit

- **WHEN** a step's diff is 450 changed lines and the limit is the default
- **THEN** plow reports `unreviewable` with the line count, and splits or redoes the step instead of asking for review

#### Scenario: Repo supplies its own check

- **WHEN** the repo provides a size check and that check passes a step plow's own count would reject
- **THEN** plow follows the repo's check and says which check it used

#### Scenario: Configured limit

- **WHEN** the limit is configured to 150 lines and a step changes 200 lines
- **THEN** plow reports `unreviewable`

### Requirement: Autonomous mode is for mechanical work only

Plow SHALL offer autonomous mode only for work on an explicit mechanical list: dependency bumps, the nth copy of a repeated form, bug hunts, and backfills. Plow SHALL run all other work, including all feature work, in gated mode. Plow SHALL NOT choose autonomous mode itself; the user SHALL pick it, and SHALL name which mechanical category the work falls in.

#### Scenario: User asks for autonomous on feature work

- **WHEN** the user picks autonomous mode for a change that adds a feature
- **THEN** plow declines, says the work is not on the mechanical list, and offers gated mode

#### Scenario: User asks for autonomous on a dependency bump

- **WHEN** the user picks autonomous mode for a change that only bumps dependencies
- **THEN** plow runs it autonomously

#### Scenario: User says nothing about mode

- **WHEN** the user gives no run mode and the work is on the mechanical list
- **THEN** plow asks, with gated mode as the default, and does not start autonomous mode

### Requirement: AI review judges bugs only

Plow's AI review step SHALL look for bugs and edge cases only. Its output SHALL NOT approve or sign off on clarity, readability, naming, or design. Plow SHALL NOT treat a clean AI review as the human's approval in gated mode. The AI review SHALL be the `/review` command in both gated and autonomous modes.

#### Scenario: Which reviewer runs

- **WHEN** plow reaches the AI review step in either mode
- **THEN** it runs `/review` on the step's diff, not `/code-review`

#### Scenario: AI review finds nothing

- **WHEN** the AI review of a step reports no bugs
- **THEN** plow still presents the step to the human in gated mode, and the report says only that no bugs were found

#### Scenario: AI review comments on design

- **WHEN** the AI reviewer produces a design or clarity opinion
- **THEN** plow does not count it as a finding to apply or as an approval, and leaves that call to the human

### Requirement: The plan updates mid-build

When a finished step shows that the change's `design.md` or `tasks.md` is wrong or incomplete, plow SHALL prompt the user to update it before the next step starts. Plow SHALL allow a step's commit to include that update. Plow SHALL NOT keep building against a plan it knows is out of date.

#### Scenario: A task turns out to be two tasks

- **WHEN** a step reveals that the next task is really two separate pieces of work
- **THEN** plow says so and prompts to split that task in `tasks.md` before continuing

#### Scenario: Nothing new learned

- **WHEN** a step matches the plan as written
- **THEN** plow does not prompt for a plan update

### Requirement: Output is short and plain

Plow's prompts, step reports, and end-of-run report SHALL default to short, plain English: no jargon the user has not used, no restating what the user already said, and the decision or result first.

#### Scenario: Step report

- **WHEN** plow presents a step for review
- **THEN** the report leads with what changed in plain words and the line count, and fits on one screen before the diff

#### Scenario: Mode question

- **WHEN** plow asks how to run a change
- **THEN** each option is one short line saying what happens if it is picked
