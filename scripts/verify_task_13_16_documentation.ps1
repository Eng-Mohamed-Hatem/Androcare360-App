# Task 13-16 Documentation Verification Script
# Verifies documentation for components documented in Tasks 13-16

Write-Host "=== Task 13-16 Documentation Verification ===" -ForegroundColor Cyan
Write-Host ""

# Define the components that should be documented from Tasks 13-16

# Task 13: Core Services (21 services)
$coreServices = @(
    "lib/core/services/agora_service.dart",
    "lib/core/services/voip_call_service.dart",
    "lib/core/services/call_monitoring_service.dart",
    "lib/core/services/fcm_service.dart",
    "lib/core/services/background_service.dart",
    "lib/core/services/device_info_service.dart",
    "lib/core/services/encryption_service.dart",
    "lib/core/services/notification_service.dart",
    "lib/core/services/token_refresh_service.dart",
    "lib/core/services/video_consultation_service.dart"
)

# Task 14: Data Models
$dataModels = @(
    "lib/core/models/appointment_model.dart",
    "lib/core/models/user_model.dart",
    "lib/features/nutrition/domain/entities/nutrition_emr_entity.dart",
    "lib/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart"
)

# Task 15: Repositories
$repositories = @(
    "lib/features/auth/data/repositories/auth_repository_impl.dart",
    "lib/features/appointments/data/repositories/appointment_repository_impl.dart",
    "lib/features/nutrition/data/repositories/nutrition_emr_repository_impl.dart",
    "lib/features/emr/data/repositories/physiotherapy_emr_repository_impl.dart",
    "lib/features/doctor/data/repositories/doctor_repository_impl.dart"
)

function Check-FileDocumentation {
    param(
        [string]$filePath,
        [string]$category
    )
    
    if (-not (Test-Path $filePath)) {
        return @{
            File = $filePath
            Category = $category
            Status = "Missing"
            ClassDocumented = $false
            MethodsDocumented = 0
            TotalMethods = 0
            HasUsageExample = $false
        }
    }
    
    $content = Get-Content $filePath -Raw
    $lines = Get-Content $filePath
    
    # Check for class-level doc comment
    $hasClassDoc = $content -match '///.*\n.*class\s+\w+'
    
    # Check for usage example in doc comments
    $hasUsageExample = $content -match '```dart'
    
    # Count methods and documented methods
    $methodCount = 0
    $documentedMethodCount = 0
    $previousLine = ""
    
    foreach ($line in $lines) {
        # Check if line is a public method (not starting with _)
        if ($line -match '^\s+(Future<|void|String|int|bool|double|\w+<).*\s+\w+\s*\(') {
            if ($line -notmatch '^\s+_') {
                $methodCount++
                if ($previousLine -match '^\s*///') {
                    $documentedMethodCount++
                }
            }
        }
        $previousLine = $line
    }
    
    return @{
        File = $filePath
        Category = $category
        Status = "Exists"
        ClassDocumented = $hasClassDoc
        MethodsDocumented = $documentedMethodCount
        TotalMethods = $methodCount
        HasUsageExample = $hasUsageExample
        MethodCoverage = if ($methodCount -gt 0) { [math]::Round(($documentedMethodCount / $methodCount) * 100, 2) } else { 0 }
    }
}

# Check all components
$results = @()

Write-Host "Checking Core Services (Task 13)..." -ForegroundColor Yellow
foreach ($service in $coreServices) {
    $result = Check-FileDocumentation -filePath $service -category "Core Service"
    $results += $result
}

Write-Host "Checking Data Models (Task 14)..." -ForegroundColor Yellow
foreach ($model in $dataModels) {
    $result = Check-FileDocumentation -filePath $model -category "Data Model"
    $results += $result
}

Write-Host "Checking Repositories (Task 15)..." -ForegroundColor Yellow
foreach ($repo in $repositories) {
    $result = Check-FileDocumentation -filePath $repo -category "Repository"
    $results += $result
}

Write-Host ""
Write-Host "=== VERIFICATION RESULTS ===" -ForegroundColor Cyan
Write-Host ""

# Summary by category
$categories = $results | Group-Object -Property Category

foreach ($category in $categories) {
    Write-Host "$($category.Name):" -ForegroundColor White
    
    $total = $category.Count
    $classDocumented = ($category.Group | Where-Object { $_.ClassDocumented }).Count
    $withUsageExample = ($category.Group | Where-Object { $_.HasUsageExample }).Count
    $avgMethodCoverage = ($category.Group | Measure-Object -Property MethodCoverage -Average).Average
    
    Write-Host "  Total Files: $total" -ForegroundColor Gray
    Write-Host "  Class-Level Doc: $classDocumented/$total ($([math]::Round(($classDocumented/$total)*100, 2))%)" -ForegroundColor $(if ($classDocumented -eq $total) { "Green" } else { "Red" })
    Write-Host "  With Usage Example: $withUsageExample/$total ($([math]::Round(($withUsageExample/$total)*100, 2))%)" -ForegroundColor $(if ($withUsageExample -eq $total) { "Green" } else { "Yellow" })
    Write-Host "  Avg Method Coverage: $([math]::Round($avgMethodCoverage, 2))%" -ForegroundColor $(if ($avgMethodCoverage -ge 80) { "Green" } elseif ($avgMethodCoverage -ge 50) { "Yellow" } else { "Red" })
    Write-Host ""
}

# Detailed results
Write-Host "=== DETAILED RESULTS ===" -ForegroundColor Cyan
Write-Host ""

foreach ($result in $results) {
    $fileName = Split-Path $result.File -Leaf
    $status = if ($result.Status -eq "Missing") { "❌ MISSING" } 
              elseif (-not $result.ClassDocumented) { "⚠️  NO CLASS DOC" }
              elseif (-not $result.HasUsageExample) { "⚠️  NO EXAMPLE" }
              elseif ($result.MethodCoverage -lt 80) { "⚠️  LOW METHOD COV" }
              else { "✅ COMPLETE" }
    
    Write-Host "$status - $fileName" -ForegroundColor $(
        if ($status -eq "✅ COMPLETE") { "Green" }
        elseif ($status -eq "❌ MISSING") { "Red" }
        else { "Yellow" }
    )
    
    if ($result.Status -ne "Missing") {
        Write-Host "    Class Doc: $($result.ClassDocumented) | Usage Example: $($result.HasUsageExample) | Methods: $($result.MethodsDocumented)/$($result.TotalMethods) ($($result.MethodCoverage)%)" -ForegroundColor Gray
    }
}

Write-Host ""

# Overall summary
$totalFiles = $results.Count
$completeFiles = ($results | Where-Object { 
    $_.Status -ne "Missing" -and 
    $_.ClassDocumented -and 
    $_.HasUsageExample -and 
    $_.MethodCoverage -ge 80 
}).Count

$overallCompletion = [math]::Round(($completeFiles / $totalFiles) * 100, 2)

Write-Host "=== OVERALL COMPLETION ===" -ForegroundColor Cyan
Write-Host "Complete Files: $completeFiles/$totalFiles ($overallCompletion%)" -ForegroundColor $(
    if ($overallCompletion -ge 90) { "Green" }
    elseif ($overallCompletion -ge 70) { "Yellow" }
    else { "Red" }
)

# Save report
$reportPath = ".kiro/specs/code-quality-and-testing-improvement/task_13_16_verification_report.md"
$report = @"
# Task 13-16 Documentation Verification Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Overall Completion
- **Total Files Checked:** $totalFiles
- **Complete Files:** $completeFiles
- **Completion Rate:** $overallCompletion%

## Summary by Category

"@

foreach ($category in $categories) {
    $total = $category.Count
    $classDocumented = ($category.Group | Where-Object { $_.ClassDocumented }).Count
    $withUsageExample = ($category.Group | Where-Object { $_.HasUsageExample }).Count
    $avgMethodCoverage = ($category.Group | Measure-Object -Property MethodCoverage -Average).Average
    
    $report += @"

### $($category.Name)
- Total Files: $total
- Class-Level Documentation: $classDocumented/$total ($([math]::Round(($classDocumented/$total)*100, 2))%)
- With Usage Examples: $withUsageExample/$total ($([math]::Round(($withUsageExample/$total)*100, 2))%)
- Average Method Coverage: $([math]::Round($avgMethodCoverage, 2))%

"@
}

$report += @"

## Detailed Results

| File | Status | Class Doc | Usage Example | Method Coverage |
|------|--------|-----------|---------------|-----------------|
"@

foreach ($result in $results) {
    $fileName = Split-Path $result.File -Leaf
    $status = if ($result.Status -eq "Missing") { "❌ Missing" } 
              elseif (-not $result.ClassDocumented) { "⚠️ No Class Doc" }
              elseif (-not $result.HasUsageExample) { "⚠️ No Example" }
              elseif ($result.MethodCoverage -lt 80) { "⚠️ Low Coverage" }
              else { "✅ Complete" }
    
    $classDoc = if ($result.Status -eq "Missing") { "N/A" } else { if ($result.ClassDocumented) { "✅" } else { "❌" } }
    $example = if ($result.Status -eq "Missing") { "N/A" } else { if ($result.HasUsageExample) { "✅" } else { "❌" } }
    $methodCov = if ($result.Status -eq "Missing") { "N/A" } else { "$($result.MethodsDocumented)/$($result.TotalMethods) ($($result.MethodCoverage)%)" }
    
    $report += "`n| $fileName | $status | $classDoc | $example | $methodCov |"
}

$report += @"


## Action Items

"@

# Add action items for incomplete files
$incompleteFiles = $results | Where-Object { 
    $_.Status -eq "Missing" -or 
    -not $_.ClassDocumented -or 
    -not $_.HasUsageExample -or 
    $_.MethodCoverage -lt 80 
}

if ($incompleteFiles.Count -gt 0) {
    $report += "`n### Files Needing Attention ($($incompleteFiles.Count))`n`n"
    foreach ($file in $incompleteFiles) {
        $fileName = Split-Path $file.File -Leaf
        $report += "- **$fileName**`n"
        if ($file.Status -eq "Missing") {
            $report += "  - File is missing`n"
        } else {
            if (-not $file.ClassDocumented) {
                $report += "  - Add class-level doc comment`n"
            }
            if (-not $file.HasUsageExample) {
                $report += "  - Add usage example in doc comment`n"
            }
            if ($file.MethodCoverage -lt 80) {
                $report += "  - Document $($file.TotalMethods - $file.MethodsDocumented) more methods (current: $($file.MethodCoverage)%)`n"
            }
        }
        $report += "`n"
    }
} else {
    $report += "`nNo action items - all files are complete! ✅`n"
}

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host ""
Write-Host "Detailed report saved to: $reportPath" -ForegroundColor Cyan

# Exit code
if ($overallCompletion -ge 90) {
    exit 0
} else {
    exit 1
}
