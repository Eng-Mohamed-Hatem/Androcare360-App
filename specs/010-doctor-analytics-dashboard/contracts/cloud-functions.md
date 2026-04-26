# Cloud Functions Contracts: Doctor Analytics Dashboard

**Branch**: `010-doctor-analytics-dashboard` | **Date**: 2026-04-25 **Region**: `europe-west1` | **Database**: `elajtech`

## Callable Functions

### 1. getDoctorsOverview

**Purpose**: Returns paginated, filtered, sorted list of doctor analytics for the overview table (US1, FR-001 through FR-022 summary).

**Auth**: Admin only (verify `userType == 'admin'`)

**Request**:

```json
{
  "periodStart": "2026-04-01T00:00:00Z",
  "periodEnd": "2026-04-30T23:59:59Z",
  "specialtyFilter": "string | null",
  "statusFilter": "all | active | inactive",
  "searchQuery": "string | null",
  "sortBy": "name | appointments | revenue | performanceScore | pendingPayout",
  "sortOrder": "asc | desc",
  "pageSize": 20,
  "cursor": "string | null"
}
```

**Response**:

```json
{
  "doctors": [
    {
      "doctorId": "string",
      "doctorName": "string",
      "profileImage": "string | null",
      "specialty": "string",
      "isActive": true,
      "totalAppointments": 45,
      "completedAppointments": 38,
      "cancelledAppointments": 5,
      "noShowAppointments": 2,
      "completionRate": 0.84,
      "averageResponseTime": 12.5,
      "totalRevenue": 15000.0,
      "platformCommission": 2250.0,
      "netPayout": 12750.0,
      "pendingPayout": 5000.0,
      "payoutStatus": "pending",
      "performanceTotalScore": 78.5,
      "patientRetentionRate": 0.35,
      "lastLoginAt": "2026-04-24T10:30:00Z"
    }
  ],
  "platformSummary": {
    "totalCompletedAppointments": 1250,
    "totalRevenue": 375000.0,
    "totalPendingPayouts": 45000.0,
    "averagePerformanceScore": 72.3,
    "activeDoctorsCount": 85
  },
  "hasMore": true,
  "nextCursor": "string | null"
}
```

**Error codes**: `unauthenticated`, `permission-denied`, `invalid-argument`

---

### 2. getDoctorAnalyticsDetail

**Purpose**: Returns full analytics detail for a single doctor (all FR-001 through FR-022 data).

**Auth**: Admin only

**Request**:
```json
{
  "doctorId": "string",
  "periodStart": "2026-04-01T00:00:00Z",
  "periodEnd": "2026-04-30T23:59:59Z"
}
```

**Response**:

```json
{
  "doctor": {
    "doctorId": "string",
    "doctorName": "string",
    "profileImage": "string | null",
    "specialty": "string",
    "isActive": true
  },
  "appointmentStats": {
    "total": 45,
    "completed": 38,
    "cancelled": 5,
    "noShow": 2,
    "completionRate": 0.84,
    "averageResponseTimeMinutes": 12.5
  },
  "financialSummary": {
    "totalRevenue": 15000.0,
    "platformCommission": 2250.0,
    "netPayout": 12750.0,
    "paidAmount": 7750.0,
    "pendingAmount": 5000.0,
    "commissionRate": 0.15
  },
  "performanceScore": {
    "totalScore": 78.5,
    "completionRateScore": 21.0,
    "patientRatingScore": 20.5,
    "punctualityScore": 19.0,
    "emrSpeedScore": 18.0,
    "hasIncompleteData": false,
    "missingDimensions": []
  },
  "timeSeriesData": {
    "granularity": "monthly",
    "dataPoints": [
      {
        "date": "2026-04-01",
        "appointments": 45,
        "revenue": 15000.0,
        "performanceScore": 78.5,
        "completionRate": 0.84
      }
    ],
    "comparison": {
      "previousPeriod": { "appointments": 40, "revenue": 13000.0 },
      "changePercent": { "appointments": 12.5, "revenue": 15.4 }
    }
  },
  "specialtyBreakdown": [
    { "serviceType": "Video Consultation", "count": 30, "percentage": 66.7 },
    { "serviceType": "Follow-up", "count": 15, "percentage": 33.3 }
  ],
  "patientRetention": {
    "totalUniquePatients": 100,
    "returningPatients": 35,
    "retentionRate": 0.35,
    "hasSufficientData": true
  }
}
```

**Error codes**: `unauthenticated`, `permission-denied`, `not-found` (doctor not found)

---

### 3. getPlatformSummary

**Purpose**: Returns platform-wide summary for the 4 summary cards. Called separately for responsive card updates when only filters change.

**Auth**: Admin only

**Request**:

```json
{
  "periodStart": "2026-04-01T00:00:00Z",
  "periodEnd": "2026-04-30T23:59:59Z",
  "specialtyFilter": "string | null"
}
```

**Response**:

```json
{
  "totalCompletedAppointments": 1250,
  "totalRevenue": 375000.0,
  "totalPendingPayouts": 45000.0,
  "averagePerformanceScore": 72.3,
  "activeDoctorsCount": 85
}
```

---

### 4. exportPayoutReport

**Purpose**: Returns structured payout data for a doctor in a given month, for client-side PDF/Excel generation (US5, FR-017, FR-018).

**Auth**: Admin only

**Request**:
```json
{
  "doctorId": "string",
  "year": 2026,
  "month": 4
}
```

**Response**:

```json
{
  "doctorName": "string",
  "specialty": "string",
  "period": { "start": "2026-04-01", "end": "2026-04-30" },
  "entries": [
    {
      "appointmentId": "string",
      "patientName": "string",
      "appointmentDate": "2026-04-15T10:00:00Z",
      "status": "completed",
      "fee": 200.0,
      "commission": 30.0,
      "netAmount": 170.0
    }
  ],
  "totalRevenue": 15000.0,
  "totalCommission": 2250.0,
  "totalNetPayout": 12750.0,
  "generatedAt": "2026-04-25T16:00:00Z"
}
```

**Error codes**: `unauthenticated`, `permission-denied`, `not-found`, `no-data` (no appointments in period)

---

### 5. getAdminAlerts

**Purpose**: Returns active (unresolved) alerts for the admin. Also supports acknowledging alerts.

**Auth**: Admin only

**Request**:

```json
{
  "includeRead": false,
  "limit": 50
}
```

**Response**:

```json
{
  "alerts": [
    {
      "id": "string",
      "type": "financial | performance | activity",
      "doctorId": "string",
      "doctorName": "string",
      "title": "string",
      "message": "string",
      "triggerValue": "string",
      "threshold": "string",
      "isRead": false,
      "createdAt": "2026-04-25T15:00:00Z"
    }
  ],
  "unreadCount": 5
}
```

---

### 6. acknowledgeAlert

**Purpose**: Marks an alert as read/resolved.

**Auth**: Admin only

**Request**:

```json
{
  "alertId": "string"
}
```

**Response**:

```json
{
  "success": true
}
```

---

## Scheduled Function

### checkAdminAlerts

**Trigger**: Pub/Sub, every 1 hour **Region**: europe-west1

**Behavior**:

1. Query all active doctors from `users` where `userType == 'doctor'`
2. For each doctor, evaluate:
   - **Financial**: Sum pending payouts. If &gt; configurable threshold, create alert.
   - **Performance**: Calculate completion rate over last 30 days. If &lt; 70%, create/update alert.
   - **Activity**: Check `lastLoginAt`. If &gt; 7 days ago, create/update alert.
3. Write new alerts to `admin_alerts` collection. Update existing alerts if condition persists.
4. Log all evaluations in `kDebugMode` equivalent (Cloud Functions console.log).

**Configuration** (stored in Firestore `admin_settings/alert_thresholds`):

```json
{
  "payoutThreshold": 5000.0,
  "completionRateThreshold": 0.70,
  "inactivityDaysThreshold": 7
}
```

## Firestore Indexes Required

Add to `firestore.indexes.json`:

```json
{
  "indexes": [
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "completedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "completedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "doctorId", "order": "ASCENDING" },
        { "fieldPath": "patientId", "order": "ASCENDING" }
      ]
    },
    {
      "collectionGroup": "appointments",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "status", "order": "ASCENDING" },
        { "fieldPath": "completedAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "admin_alerts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "isRead", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "admin_alerts",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "type", "order": "ASCENDING" },
        { "fieldPath": "createdAt", "order": "DESCENDING" }
      ]
    },
    {
      "collectionGroup": "users",
      "queryScope": "COLLECTION",
      "fields": [
        { "fieldPath": "userType", "order": "ASCENDING" },
        { "fieldPath": "isActive", "order": "ASCENDING" }
      ]
    }
  ]
}
```
