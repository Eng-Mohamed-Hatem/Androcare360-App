# planning.md

Rule description here...

## Guidelines

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
