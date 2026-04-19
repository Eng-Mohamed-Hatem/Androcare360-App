# State Machine Checklist: Agora Call Workflow Alignment

**Purpose**: Thorough pre-implementation gate validating the completeness, clarity, consistency, and measurability of all appointment/call state machine and lifecycle transition requirements before planning begins.
**Created**: 2026-03-31
**Feature**: [../spec.md](../spec.md)
**Scope**: Appointment/call state model — state definitions, transitions, guards, actors, visibility, timeouts, edge cases

---

## State Definition Completeness

- [x] CHK001 — Are all 8 defined states documented with both their semantic meaning AND their entry condition, not just their label? [Resolved → State Model §State Definitions: all 8 states have explicit entry conditions]
- [x] CHK002 — Is the `calling` state defined to distinguish between "VoIP ring active on patient device" and "doctor is waiting for the ring to be answered" — or does it conflate both? [Resolved → State Definitions §calling: explicitly documented as two aspects of same state]
- [x] CHK003 — Is the `in_progress` state's entry condition defined with a measurable event (e.g., "patient has successfully joined the shared channel") rather than a vague description? [Resolved → State Definitions §in_progress: "backend receives confirmation that the patient has joined the call channel"]
- [x] CHK004 — Is the `missed` state defined to cover both (a) ring timeout expiry AND (b) cases where the patient's device did not receive the notification (e.g., network offline during ring)? [Resolved → State Definitions §missed: both conditions explicitly covered]
- [x] CHK005 — Is the `ended_pending_confirmation` state's entry trigger defined to distinguish "doctor intentionally ended call" from "both parties dropped simultaneously due to connectivity loss"? [Resolved → State Definitions §ended_pending_confirmation: both cause same state; §Confirmation dialog scope note clarifies scope]
- [x] CHK006 — Is there a defined state for when the doctor cancels the call (stops ringing) before the patient answers or ignores it — or does this transition collapse into `missed`? [Gap resolved → FR-026, State Model §calling row]
- [x] CHK007 — Are both `completed` and `not_completed` explicitly identified as terminal states with documented finality (no further transitions permitted from either)? [Resolved → State Definitions: both states include "Terminal — no further transitions permitted"]
- [x] CHK008 — Is the distinction between `not_completed` (doctor's explicit "No" response) and `missed` (patient did not answer) documented in the state definitions to prevent conflation? [Resolved → State Model §not_completed vs. missed callout block]

---

## Transition Completeness

- [x] CHK009 — Are all possible transitions OUT of the `calling` state exhaustively listed? Required: answer (→ `in_progress`), decline (→ `declined`), timeout/no-answer (→ `missed`), doctor cancel (→ ?), and network failure (→ ?) [Gap resolved → State Model §calling row now lists all 5 exits; FR-026]
- [x] CHK010 — Is the `missed` → `in_progress` transition (patient rejoins directly from Appointments tab while call is active) listed in the state model with its guard conditions? [Resolved → State Transitions table: guard conditions = doctor session active + token valid + patient identity match]
- [x] CHK011 — Is the `missed` → `calling` transition (doctor re-initiates call after patient missed it) listed with explicit guard conditions? [Resolved → State Transitions table: guard = within ±30 min; previous session invalidated]
- [x] CHK012 — Is the `declined` → `calling` transition (doctor retries after patient declined) listed with the appointment time window boundary as a guard condition? [Resolved → State Transitions table: guard = within ±30 min; FR-002 defines the window]
- [x] CHK013 — Is the `in_progress` → `ended_pending_confirmation` transition defined for the case where the PATIENT ends the call first (not the doctor)? [Gap resolved → FR-015 updated; State Model §in_progress row]
- [x] CHK014 — Is the `in_progress` → `ended_pending_confirmation` transition defined for simultaneous connectivity loss by both parties — and does it require a doctor action to progress, or does it auto-resolve? [Gap resolved → FR-015, State Model §Simultaneous drop rule, Edge Cases updated]
- [x] CHK015 — Are all transitions OUT of `ended_pending_confirmation` exhaustively listed? Required: doctor "Yes" (→ `completed`), doctor "No" (→ `not_completed`), 24-hour auto-timeout (→ `not_completed`), race condition during active dialog (→ ?) [Gap resolved → State Model §ended_pending_confirmation row now lists all 3 exits; FR-033 covers idempotency for race]
- [x] CHK016 — Is the 24-hour auto-transition from `ended_pending_confirmation` → `not_completed` explicitly listed as a transition row in the state model table? [Gap resolved → State Model §ended_pending_confirmation row updated]
- [x] CHK017 — Is there a defined transition (or explicit prohibition) for what happens if `endAgoraCall` is triggered when the appointment is already in a terminal state (`completed` or `not_completed`)? [Gap resolved → FR-035]

---

## Transition Guard Conditions

- [x] CHK018 — Is the "appointment time window" guard for call initiation (FR-002) defined with a specific numeric boundary? [Resolved → FR-002: ±30 minutes]
- [x] CHK019 — Is the doctor retry-after-decline guard governed by the same window as initial call initiation, and is this documented? [Resolved → FR-002 + State Transitions §Call initiation time window note: same ±30 min for all three initiation paths]
- [x] CHK020 — Is the rejoin eligibility guard formally defined with all three conditions: state, token, identity? [Resolved → State Model §Rejoin eligibility rule + FR-008: all 3 conditions explicit]
- [x] CHK021 — Is "Join Meeting" removal tied to a named state transition, not just a UI-layer rule? [Resolved → FR-010: disappears at state transition to `ended_pending_confirmation` or terminal states]
- [x] CHK022 — Is the cold-start restoration guard defined to specify valid states? [Resolved → FR-005: only valid in `calling` or `in_progress`]
- [x] CHK023 — Is there a defined guard preventing duplicate call initiation on active/terminal appointments? [Gap resolved → FR-027]
- [x] CHK024 — Is the authorization failure error message specified beyond "blocked and logged"? [Resolved → NFR-003: "You are not authorized to join this meeting"]

---

## Actor & Trigger Clarity

- [x] CHK025 — Is it unambiguous which actor triggers `calling` → `missed`? [Resolved → FR-007: system-triggered automatically on timeout; distinct from doctor-cancel (→ `scheduled`) per FR-026]
- [x] CHK026 — Is the entity responsible for the 24-hour auto-transition specified? [Gap resolved → FR-028: backend-enforced, no client dependency]
- [x] CHK027 — Is it defined whether the patient can trigger `in_progress` → `ended_pending_confirmation`? [Resolved → FR-015 + State Transitions: patient ends call is explicitly listed as a trigger]
- [x] CHK028 — Are `handleMissedCall` and `handleCallDeclined` defined as system-automatic? [Resolved → FR-041: both are system-automatic, idempotent]
- [x] CHK029 — Are notification recipients defined for every state transition that produces a notification? [Resolved → FR-042: full notification recipient matrix]
- [x] CHK030 — Is it defined which actor marks the appointment as `in_progress`? [Resolved → State Definitions §in_progress: "backend receives confirmation that the patient has joined the call channel"]

---

## State Visibility & UX Label Mapping

- [x] CHK031 — Is the patient-facing label for `ended_pending_confirmation` state defined? [Resolved → FR-036: "Awaiting Confirmation"]
- [x] CHK032 — Is the patient-facing label for `not_completed` defined and distinct from `missed`? [Resolved → FR-036: "Session Incomplete" vs. "Missed Call" — textually distinct]
- [x] CHK033 — Is the doctor UI label when dialog dismissed but unresolved defined? [Gap resolved → FR-029]
- [x] CHK034 — Is the visual distinction between `completed` and `not_completed` defined with measurable criteria? [Resolved → FR-036: unique labels required per state; no two states may share a label]
- [x] CHK035 — Are the appointment card display states for `calling` and `in_progress` defined for the patient's view? (what does the patient see on the appointment card before answering and while in the meeting?) [Gap resolved → FR-030]

---

## Timeout & Automatic Transition Completeness

- [x] CHK036 — Is the ring timeout duration specified as a numeric value? [Resolved → FR-037: minimum 60 seconds; FR-007 updated to reference this]
- [x] CHK037 — Is the 24-hour countdown start point defined? [Resolved → FR-038: starts from `callEndedAt`, not from dialog display time]
- [x] CHK038 — Is the race condition between auto-transition and doctor response defined? [Resolved → FR-039: doctor's explicit response takes precedence]
- [x] CHK039 — Is the session token validity window defined and consistent with rejoin eligibility? [Resolved → FR-040: token valid minimum 30 min from call initiation]
- [x] CHK040 — Are requirements defined for what happens to the appointment state if the app crashes or is force-quit during a state transition (e.g., crash between `calling` and `in_progress`)? [Gap resolved → FR-031]

---

## Cross-Spec Consistency

- [x] CHK041 — Are state names consistent across all FR requirements? [Resolved → FR-007/008/010/015 updated to use canonical state names; all FRs use `calling`, `in_progress`, `missed`, `ended_pending_confirmation`, `completed`, `not_completed`, `declined`]
- [x] CHK042 — Are state names in User Story acceptance scenarios consistent with the state model? [Resolved → User Stories use `calling`, `in_progress`, `declined`, `not_completed` — all canonical names; no informal synonyms]
- [x] CHK043 — Is Conflict 1 formally resolved by an FR that prohibits old auto-complete behavior? [Resolved → FR-015: "MUST NOT transition directly to `completed` under any end-of-call condition"]
- [x] CHK044 — Does the Implementation Gaps table use consistent state names with the state model? [Resolved → Implementation Gaps table references `callStatus` only for legacy field descriptions; new state names used in Required Action column]

---

## Edge Case & Recovery State Coverage

- [x] CHK045 — Is simultaneous connectivity drop state defined and distinguished from doctor-initiated end? [Resolved → State Definitions §ended_pending_confirmation + State Transitions: both enter same state; entry trigger listed explicitly]
- [x] CHK046 — Is the "patient answers but cannot join" edge case mapped to a named state transition? [Resolved → Edge Cases: appointment remains `in_progress`; patient offered retry; no state change until doctor ends call]
- [x] CHK047 — Is retry count defined? [Gap resolved → FR-032: unlimited within time window]
- [x] CHK048 — Is the latency window between call ending and dialog appearing defined? [Resolved → State Definitions §ended_pending_confirmation: "transition is atomic; no intermediate state exists"]
- [x] CHK049 — Are duplicate/replayed signals handled? [Gap resolved → FR-033]
- [x] CHK050 — Is new vs. reused session on retry defined? [Gap resolved → FR-034]

---

## Notes

- Check items off as completed: `[x]`
- Add inline findings when an item fails (e.g., `- [x] CHK018 — FAIL: FR-002 does not define a numeric window; deferred to implementation`)
- Items marked `[Gap]` indicate requirements missing from the spec — spec updates are required before these can pass
- Items marked `[Clarity]` indicate existing requirements that need to be sharpened with measurable or unambiguous language
- Items marked `[Consistency]` require cross-referencing two or more spec sections to verify alignment
- All CHK items must pass before `/speckit.plan` is run
