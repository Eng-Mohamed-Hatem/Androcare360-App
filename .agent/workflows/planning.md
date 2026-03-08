---
description: 
---

# 🛡️ Project Analysis & Planning Protocol
Before any code implementation, Kilo Code MUST follow these steps:

1. **Deep Analysis**: Scan and analyze all relevant project files related to the requested task.
2. **Context Mapping**: Identify dependencies between the target files and other modules (State Management, Domain Entities, Repositories).
3. **Drafting the Plan**: Create a detailed execution plan explaining:
   - What logic will be changed.
   - Which files will be modified or created.
   - How to avoid potential regressions or rendering errors (e.g., Semantics/Rebuild issues).
4. **User Approval**: Present the plan to the user and wait for explicit approval before writing a single line of code.
5. **Pre-Flight Check**: Ensure all new fields comply with Elajtech standards (Freezed, Null Safety, databaseId: 'elajtech').

Task Completion & Reporting Protocol

    Mandatory Requirement: From now on, upon the completion of every task or set of tasks, you must provide a 'Comprehensive Accomplishment Report' before proceeding to the next objective. The report must follow this structured format:

        Executive Summary: A clear, bulleted list of the functionalities that are now fully operational.

        Code Changes:

            Files Modified/Created: A precise list of the file paths involved.

            Functionality Overview: A brief explanation of the new functions or logic introduced.

        Infrastructure Updates:

            Firestore Changes: Any modifications related to the databaseId: 'elajtech'.

            Configuration Updates: Any changes in configuration files such as AndroidManifest.xml, Info.plist, or .env.

        Verification & Quality Assurance:

            Flutter Analyze: Confirmation that flutter analyze was run and resulted in 0 Errors.

            Deployment Status: Confirmation of a successful firebase deploy if Cloud Functions were modified.

        Resolved Issues: Documentation of any UI issues (e.g., Overflow), library conflicts, or logic bugs that were addressed during the task.

        Next Steps: A clear recommendation on the manual/automated tests required or the next logical task to be initiated.