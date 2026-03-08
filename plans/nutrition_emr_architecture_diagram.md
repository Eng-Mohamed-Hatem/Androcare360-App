// ignore_for_file: all  
// ignore_for_file: all
# 🏗️ Nutrition EMR Presentation Layer - Architecture Diagrams

## 📐 System Architecture Overview

```mermaid
graph TB
    subgraph "Presentation Layer"
        Screen[NutritionClinicScreen]
        Wizard[NutritionWizardView]
        Tabbed[NutritionTabbedView]
        Steps[8 Step Widgets]
        Tabs[8 Tab Widgets]
    end
    
    subgraph "State Management"
        EMRNotifier[NutritionEMRNotifier]
        WizardNotifier[NutritionWizardNotifier]
        ViewModeProvider[NutritionViewModeProvider]
    end
    
    subgraph "Domain Layer"
        Repository[NutritionEMRRepository]
        Entity[NutritionEMREntity]
    end
    
    subgraph "Data Layer"
        RepoImpl[NutritionEMRRepositoryImpl]
        Model[NutritionEMRModel]
        Firestore[(Firestore DB elajtech)]
    end
    
    Screen --> EMRNotifier
    Screen --> ViewModeProvider
    Wizard --> WizardNotifier
    Wizard --> Steps
    Tabbed --> Tabs
    
    Steps --> EMRNotifier
    Tabs --> EMRNotifier
    
    EMRNotifier --> Repository
    Repository --> RepoImpl
    RepoImpl --> Model
    Model --> Firestore
    
    Entity -.->|Domain Model| EMRNotifier
    Model -.->|Data Model| RepoImpl
```

## 🔄 State Flow Diagram

```mermaid
stateDiagram-v2
    [*] --> Initializing: Screen Opens
    
    Initializing --> Loading: Load EMR
    Loading --> Loaded: EMR Found
    Loading --> Empty: No EMR
    Loading --> Error: Load Failed
    
    Loaded --> ViewMode: Auto-activate
    Empty --> EditMode: Initialize New
    
    ViewMode --> EditMode: User Clicks Edit
    ViewMode --> Locked: 24h Expired
    
    EditMode --> Dirty: User Changes Data
    Dirty --> Saving: User Clicks Save
    Dirty --> AutoSaving: 30s Timer
    
    Saving --> Saved: Success
    Saving --> Error: Failed
    
    AutoSaving --> Saved: Success
    AutoSaving --> Dirty: Failed
    
    Saved --> ViewMode: Activate View
    
    Error --> Loading: Retry
    Error --> [*]: Exit
    
    Locked --> [*]: Cannot Edit
    ViewMode --> [*]: Exit
```

## 🎯 Component Interaction Flow

```mermaid
sequenceDiagram
    participant User
    participant Screen as NutritionClinicScreen
    participant Notifier as EMRNotifier
    participant Repo as Repository
    participant Firestore as Firestore DB
    
    User->>Screen: Opens EMR Screen
    Screen->>Notifier: loadEMRByAppointment
    Notifier->>Repo: getEMRByAppointmentId
    Repo->>Firestore: Query Collection
    
    alt EMR Exists
        Firestore-->>Repo: Return EMR Data
        Repo-->>Notifier: Right EMR Entity
        Notifier-->>Screen: State: emr loaded
        Screen->>User: Show View Mode
    else EMR Not Found
        Firestore-->>Repo: Empty Result
        Repo-->>Notifier: Right null
        Notifier->>Screen: Initialize New EMR
        Screen->>User: Show Edit Mode
    end
    
    User->>Screen: Toggle Checkbox
    Screen->>Notifier: updateCheckbox field value
    Notifier->>Notifier: Optimistic Update
    Notifier-->>Screen: State: isDirty=true
    Screen->>User: Show Unsaved Indicator
    
    Note over Notifier: Auto-save Timer 30s
    Notifier->>Repo: saveEMR isDraft=true
    Repo->>Firestore: Set Document
    Firestore-->>Repo: Success
    Repo-->>Notifier: Right void
    Notifier-->>Screen: State: lastAutoSave
    
    User->>Screen: Clicks Save Button
    Screen->>Notifier: saveEMR
    Notifier->>Repo: saveEMR
    Repo->>Firestore: Set Document with Audit
    Firestore-->>Repo: Success
    Repo-->>Notifier: Right void
    Notifier-->>Screen: State: isSaved=true isDirty=false
    Screen->>User: Show Success Message
```

## 🧩 Widget Tree Structure

```mermaid
graph TD
    A[NutritionClinicScreen] --> B{Loading?}
    B -->|Yes| C[CircularProgressIndicator]
    B -->|No| D{Error?}
    
    D -->|Yes| E[Error Widget + Retry Button]
    D -->|No| F{EMR Exists?}
    
    F -->|No + Locked| G[Lock Message]
    F -->|Yes| H{View Mode?}
    
    H -->|Wizard| I[NutritionWizardView]
    H -->|Tabbed| J[NutritionTabbedView]
    
    I --> K[ProgressIndicator]
    I --> L[PageView]
    I --> M[NavigationBar]
    
    L --> N1[Step 1: Anthropometric]
    L --> N2[Step 2: Medical History]
    L --> N3[Step 3: Dietary Assessment]
    L --> N4[Step 4: Lifestyle]
    L --> N5[Step 5: Clinical Findings]
    L --> N6[Step 6: Lab Results]
    L --> N7[Step 7: Nutrition Diagnosis]
    L --> N8[Step 8: Initial Plan]
    
    J --> O[TabBar]
    J --> P[TabBarView]
    
    P --> T1[Tab 1: Anthropometric]
    P --> T2[Tab 2: Medical History]
    P --> T3[Tab 3: Dietary Assessment]
    P --> T4[Tab 4: Lifestyle]
    P --> T5[Tab 5: Clinical Findings]
    P --> T6[Tab 6: Lab Results]
    P --> T7[Tab 7: Nutrition Diagnosis]
    P --> T8[Tab 8: Initial Plan]
    
    N1 --> Q{Edit or View?}
    Q -->|Edit| R[CheckboxListTiles]
    Q -->|View| S[Chips Display]
```

## 📊 Data Model Relationships

```mermaid
erDiagram
    NUTRITION_EMR_ENTITY ||--o{ AUDIT_LOG_ENTRY : contains
    NUTRITION_EMR_ENTITY {
        string id PK
        string patientId FK
        string nutritionistId FK
        string appointmentId FK
        datetime visitDate
        datetime createdAt
        datetime updatedAt
        bool isLocked
        datetime lockedUntil
        bool isFirstVisit
        bool weightMeasured
        bool heightMeasured
        bool bmiCalculated
    }
    
    AUDIT_LOG_ENTRY {
        datetime timestamp
        string userId
        string userName
        string action
        string fieldChanged
        string previousValue
        string newValue
    }
    
    NUTRITION_EMR_STATE ||--|| NUTRITION_EMR_ENTITY : manages
    NUTRITION_EMR_STATE {
        NutritionEMREntity emr
        bool isLoading
        string error
        bool isSaved
        bool isDirty
        datetime lastAutoSaveTime
    }
    
    WIZARD_STATE {
        int currentStep
        Set completedSteps
        Set visitedSteps
    }
    
    VIEW_MODE_STATE {
        bool isViewMode
        bool useWizard
    }
```

## 🔐 Lock Mechanism Flow

```mermaid
graph LR
    A[EMR Created] -->|createdAt: now| B[lockedUntil: now + 24h]
    B --> C{Check Time}
    
    C -->|Within 24h| D[Edit Allowed]
    C -->|After 24h| E[Auto-Locked]
    
    D -->|User Action| F{Save Changes}
    F -->|Yes| G[updatedAt: server time]
    F -->|No| D
    
    E --> H[Read-Only Mode]
    H --> I[View Mode UI]
    I --> J{Admin User?}
    
    J -->|Yes| K[Show Unlock Button]
    J -->|No| L[No Actions]
    
    G --> M[Update Audit Log]
    M --> D
    
    style E fill:#f96,stroke:#f00
    style D fill:#9f6,stroke:#0f0
    style H fill:#ff9,stroke:#f90
```

## 🎨 Auto-Save Mechanism

```mermaid
sequenceDiagram
    participant Timer as Auto-Save Timer
    participant Notifier as EMRNotifier
    participant State as State
    participant Repo as Repository
    
    Note over Timer: Every 30 seconds
    
    Timer->>Notifier: Trigger Auto-Save
    Notifier->>State: Check isDirty
    
    alt isDirty = true
        State-->>Notifier: Changes Detected
        Notifier->>Repo: saveEMR isDraft=true
        Repo->>Repo: Add to Firestore
        Repo-->>Notifier: Success
        Notifier->>State: Update lastAutoSave
        State-->>State: Keep isDirty=true
    else isDirty = false
        State-->>Notifier: No Changes
        Notifier->>Notifier: Skip Save
    end
    
    Note over Timer: Wait 30 seconds
    Timer->>Notifier: Trigger Auto-Save
```

## 🚀 Navigation Flow in Wizard

```mermaid
graph TD
    Start[Step 1] --> Check1{Validate Step 1}
    Check1 -->|Valid| Step2[Step 2]
    Check1 -->|Invalid| Error1[Show Error]
    Error1 --> Start
    
    Step2 --> Check2{Validate Step 2}
    Check2 -->|Valid| Step3[Step 3]
    Check2 -->|Invalid| Error2[Show Error]
    Error2 --> Step2
    
    Step3 --> Check3{Validate Step 3}
    Check3 -->|Valid| Step4[Step 4]
    Check3 -->|Invalid| Error3[Show Error]
    Error3 --> Step3
    
    Step4 --> Check4{Validate Step 4}
    Check4 -->|Valid| Step5[Step 5]
    Check4 -->|Invalid| Error4[Show Error]
    Error4 --> Step4
    
    Step5 --> Check5{Validate Step 5}
    Check5 -->|Valid| Step6[Step 6]
    Check5 -->|Invalid| Error5[Show Error]
    Error5 --> Step5
    
    Step6 --> Check6{Validate Step 6 Optional}
    Check6 -->|Valid or Skip| Step7[Step 7]
    Check6 -->|Invalid| Error6[Show Error]
    Error6 --> Step6
    
    Step7 --> Check7{Validate Step 7}
    Check7 -->|Valid| Step8[Step 8]
    Check7 -->|Invalid| Error7[Show Error]
    Error7 --> Step7
    
    Step8 --> Check8{Validate Step 8}
    Check8 -->|Valid| Complete[Complete Wizard]
    Check8 -->|Invalid| Error8[Show Error]
    Error8 --> Step8
    
    Complete --> Save[Save Full EMR]
    Save --> ViewMode[Activate View Mode]
    
    style Start fill:#9f6
    style Complete fill:#6f9
    style ViewMode fill:#6cf
```

## 🔄 Provider Dependency Graph

```mermaid
graph TB
    subgraph "Core Providers"
        RepoProvider[nutritionEMRRepositoryProvider]
        GetIt[GetIt DI Container]
    end
    
    subgraph "State Providers with autoDispose"
        EMRProvider[nutritionEMRNotifierProvider]
        WizardProvider[nutritionWizardNotifierProvider]
        ViewProvider[nutritionViewModeProvider]
    end
    
    subgraph "UI Consumers"
        Screen[NutritionClinicScreen]
        Wizard[NutritionWizardView]
        Steps[Step Widgets]
    end
    
    GetIt --> RepoProvider
    RepoProvider --> EMRProvider
    
    EMRProvider --> WizardProvider
    EMRProvider --> Screen
    EMRProvider --> Steps
    
    WizardProvider --> Wizard
    ViewProvider --> Screen
    
    style GetIt fill:#f9f
    style EMRProvider fill:#6cf
    style WizardProvider fill:#fc9
    style ViewProvider fill:#9cf
```

## 📱 Responsive Breakpoints

```mermaid
graph LR
    A[Screen Width] --> B{Size?}
    
    B -->|< 600px| C[Mobile Layout]
    B -->|600-1200px| D[Tablet Layout]
    B -->|> 1200px| E[Desktop Layout]
    
    C --> C1[Wizard: Full Width]
    C --> C2[Steps: Vertical Stack]
    C --> C3[FAB: Bottom Right]
    
    D --> D1[Wizard: 80% Width]
    D --> D2[Steps: 2-Column Grid]
    D --> D3[FAB: Bottom Right]
    
    E --> E1[Wizard: 60% Width Centered]
    E --> E2[Steps: 3-Column Grid]
    E --> E3[FAB: Sticky Sidebar]
    
    style C fill:#fcc
    style D fill:#cfc
    style E fill:#ccf
```

## 🎭 Mode Transitions

```mermaid
stateDiagram-v2
    [*] --> LoadingState
    
    LoadingState --> EmptyState: No EMR
    LoadingState --> ViewState: EMR Found
    LoadingState --> ErrorState: Load Failed
    
    EmptyState --> EditState: Initialize
    
    ViewState --> EditState: Click Edit
    ViewState --> LockedState: isLocked = true
    
    EditState --> DirtyState: Data Changed
    DirtyState --> SavingState: Click Save
    DirtyState --> AutoSavingState: 30s Timer
    
    SavingState --> ViewState: Success
    SavingState --> ErrorState: Failed
    
    AutoSavingState --> DirtyState: Silent Success
    AutoSavingState --> ErrorState: Failed
    
    LockedState --> ViewState: Admin Unlock
    
    ErrorState --> LoadingState: Retry
    
    ViewState --> [*]
    LockedState --> [*]
```

---

## 📊 Performance Optimization Strategy

### Widget Rebuild Optimization

```mermaid
graph TD
    A[State Change] --> B{What Changed?}
    
    B -->|emr.weightMeasured| C[Only AnthropometricStep Rebuilds]
    B -->|isLoading| D[Only Loading Widget Rebuilds]
    B -->|isDirty| E[Only FAB & AppBar Rebuild]
    B -->|Full state| F[Entire Screen Rebuilds]
    
    C --> G[Using select]
    D --> G
    E --> G
    
    G --> H[Minimal Rebuilds]
    F --> I[Full Rebuilds Avoid]
    
    style H fill:#9f6
    style I fill:#f96
```

### Memory Management

```mermaid
graph LR
    A[Screen Opens] --> B[Provider Created]
    B --> C[Notifier Initialized]
    C --> D[Timer Started]
    
    D --> E[Screen Active]
    E --> F[User Navigates Away]
    
    F --> G[autoDispose Triggered]
    G --> H[Timer Cancelled]
    H --> I[Notifier Disposed]
    I --> J[Memory Released]
    
    style G fill:#9f6
    style J fill:#6f9
```

---

## 🔍 Step Validation Rules

| Step | Required Fields | Validation Logic |
|------|-----------------|------------------|
| **1. Anthropometric** | At least 1 checkbox | `weightMeasured OR heightMeasured` |
| **2. Medical History** | Required | `medicalHistoryReviewed = true` |
| **3. Dietary Assessment** | At least 1 checkbox | `dietary24HRecall OR foodFrequencyChecked` |
| **4. Lifestyle** | Optional | Always valid |
| **5. Clinical Findings** | Optional | Always valid |
| **6. Lab Results** | Optional | Always valid |
| **7. Nutrition Diagnosis** | At least 1 checkbox | `inadequateIntakeDiagnosed OR excessiveIntakeDiagnosed OR ...` |
| **8. Initial Plan** | At least 2 checkboxes | Count >= 2 |

---

## 🎯 UI Component Reusability

```mermaid
graph TB
    subgraph "Reusable Widgets"
        CheckboxSection[CheckboxSectionWidget]
        ChipDisplay[ChipDisplayWidget]
        EmptyState[EmptyStateWidget]
        LockIndicator[LockIndicatorWidget]
        ProgressBar[ProgressBarWidget]
    end
    
    subgraph "Step Widgets"
        Step1[AnthropometricStep]
        Step2[MedicalHistoryStep]
        Step3[DietaryAssessmentStep]
    end
    
    subgraph "Tab Widgets"
        Tab1[AnthropometricTab]
        Tab2[MedicalHistoryTab]
        Tab3[DietaryAssessmentTab]
    end
    
    Step1 --> CheckboxSection
    Step1 --> ChipDisplay
    Step1 --> EmptyState
    
    Step2 --> CheckboxSection
    Step2 --> ChipDisplay
    
    Step3 --> CheckboxSection
    Step3 --> ChipDisplay
    
    Tab1 --> CheckboxSection
    Tab1 --> ChipDisplay
    
    Tab2 --> CheckboxSection
    Tab2 --> ChipDisplay
    
    Tab3 --> CheckboxSection
    Tab3 --> ChipDisplay
    
    Screen[NutritionClinicScreen] --> LockIndicator
    Screen --> ProgressBar
```

---

**Document Version:** 1.0  
**Last Updated:** 2026-01-22  
**Status:** Architecture Design Phase
