Spec Kit Usage Rules for AndroCare / Elajtech



&nbsp;   Always assume Spec Kit is enabled



&nbsp;       When working in the AndroCare/Elajtech repository, always assume that GitHub Spec Kit is installed and initialized under .specify/.



&nbsp;       Do not propose ad‑hoc implementation without considering the Spec Kit lifecycle.



&nbsp;   Enforce the Spec Kit lifecycle for any new feature



&nbsp;       For any new feature, improvement, or significant refactor, you must follow this sequence:



&nbsp;           /speckit.constitution (if the project principles or rules might be affected)



&nbsp;           /speckit.specify



&nbsp;           /speckit.clarify (whenever there is any ambiguity)



&nbsp;           /speckit.plan



&nbsp;           /speckit.checklist



&nbsp;           /speckit.tasks



&nbsp;           /speckit.analyze



&nbsp;           /speckit.implement



&nbsp;       You must not skip from “idea” directly to “implementation” without at least a spec and plan.



&nbsp;   No implementation without spec and plan



&nbsp;       Do not generate production‑level code for a new feature unless:



&nbsp;           A spec exists under .specify/specs/\[feature]/spec.md.



&nbsp;           A plan exists under .specify/specs/\[feature]/plan.md.



&nbsp;       If a request asks for direct implementation and no spec/plan exist, first propose using /speckit.specify and /speckit.plan.



&nbsp;   Align with constitution and rules files



&nbsp;       Always align specs, plans, tasks, and implementation with:



&nbsp;           .specify/memory/constitution.md



&nbsp;           instructions-for-flutter-app-development.md



&nbsp;           important-rules.md (final authority on Elajtech behavior and safety rules).



&nbsp;       If a user request conflicts with these documents, explicitly highlight the conflict and propose updating the constitution/spec first.



&nbsp;   Use clarifying and quality commands by default



&nbsp;       When a feature description is incomplete or ambiguous, you must suggest /speckit.clarify before planning.



&nbsp;       After /speckit.plan, you should suggest /speckit.checklist to generate a quality checklist.



&nbsp;       After /speckit.tasks, you should suggest /speckit.analyze before /speckit.implement for consistency checks.



&nbsp;   Backward documentation for existing features



&nbsp;       If the user asks about an existing feature with no spec, prefer creating a reverse‑engineered spec using /speckit.specify based on the current code, then optionally a plan for refactors or improvements.



&nbsp;   Preference for Flutter‑aware structures



&nbsp;       When creating or modifying plans/specs for AndroCare, always assume:



&nbsp;           Flutter + Dart + Clean Architecture (Presentation/Domain/Data).



&nbsp;           Folder structure rooted in lib/ and lib/features/....



&nbsp;           Tests under test/unit, test/widget, and test/integration





