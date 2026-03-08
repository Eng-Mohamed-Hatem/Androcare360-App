# Repository Documentation Verification Script
# Specifically checks the 5 repositories from Task 15

Write-Host "=== Repository Documentation Verification ===" -ForegroundColor Cyan
Write-Host ""

# Define the 5 repositories to check
$repositories = @(
    @{
        Path = "lib/features/auth/data/repositories/auth_repository_impl.dart"
        Name = "AuthRepositoryImpl"
    },
    @{
        Path = "lib/features/appointments/data/repositories/appointment_repository_impl.dart"
        Name = "AppointmentRepositoryImpl"
    },
    @{
        Path = "lib/features/nutrition/data/repositories/nutrition_emr_repository_impl.dart"
        Name = "NutritionEMRRepositoryImpl"
    },
    @{
        Path = "lib/features/emr/data/repositories/physiotherapy_emr_repository_impl.dart"
        Name = "PhysiotherapyEMRRepositoryImpl"
    },
    @{
        Path = "lib/features/doctor/data/repositories/doctor_repository_impl.dart"
        Name = "DoctorRepositoryImpl"
    }
)

function Check-RepositoryDocumentation {
    param(
        [string]$filePath,
        [string]$repoName
    )
    
    if (-not (Test-Path $filePath)) {
        return @{
            Name = $repoName
            Status = "❌ File Not Found"
            HasClassDoc = $false
            HasUsageExample = $false
            HasDIDoc = $false
            HasErrorHandlingDoc = $false
            HasCriticalRules = $false
            MethodCount = 0
            DocumentedMethods = 0
        }
    }
    
    $content = Get-Content $filePath -Raw
    
    # Check for class-level doc comment (/// before class declaration)
    $hasClassDoc = $content -match '///[\s\S]*?class\s+' + [regex]::Escape($repoName)
    
    # Check for usage example
    $hasUsageExample = $content -match '```dart'
    
    # Check for DI documentation
    $hasDIDoc = $content -match '@LazySingleton' -or $content -match 'Dependency Injection'
    
    # Check for error handling documentation
    $hasErrorHandlingDoc = $content -match 'Either<Failure' -or $content -match 'Error Handling'
    
    # Check for critical database rules
    $hasCriticalRules = $content -match "databaseId: 'elajtech'" -or $content -match 'CRITICAL DATABASE RULES'
    
    # Count methods
    $methodMatches = [regex]::Matches($content, '@override\s+Future<')
    $methodCount = $methodMatches.Count
    
    # Count documented methods (methods with /// comment before @override)
    $documentedMethodCount = 0
    $lines = Get-Content $filePath
    for ($i = 0; $i -lt $lines.Count; $i++) {
        if ($lines[$i] -match '@override') {
            # Check if previous non-empty line is a doc comment
            for ($j = $i - 1; $j -ge 0; $j--) {
                if ($lines[$j] -match '\S') {  # Non-empty line
                    if ($lines[$j] -match '^\s*///') {
                        $documentedMethodCount++
                    }
                    break
                }
            }
        }
    }
    
    $methodCoverage = if ($methodCount -gt 0) { 
        [math]::Round(($documentedMethodCount / $methodCount) * 100, 2) 
    } else { 
        100  # If no methods, consider it complete
    }
    
    # Determine status
    $status = if ($hasClassDoc -and $hasUsageExample -and $hasDIDoc -and $hasErrorHandlingDoc -and $hasCriticalRules -and $methodCoverage -ge 80) {
        "✅ Complete"
    } elseif ($hasClassDoc) {
        "⚠️  Partial"
    } else {
        "❌ Incomplete"
    }
    
    return @{
        Name = $repoName
        Status = $status
        HasClassDoc = $hasClassDoc
        HasUsageExample = $hasUsageExample
        HasDIDoc = $hasDIDoc
        HasErrorHandlingDoc = $hasErrorHandlingDoc
        HasCriticalRules = $hasCriticalRules
        MethodCount = $methodCount
        DocumentedMethods = $documentedMethodCount
        MethodCoverage = $methodCoverage
    }
}

# Check all repositories
$results = @()
foreach ($repo in $repositories) {
    Write-Host "Checking $($repo.Name)..." -ForegroundColor Yellow
    $result = Check-RepositoryDocumentation -filePath $repo.Path -repoName $repo.Name
    $results += $result
}

Write-Host ""
Write-Host "=== RESULTS ===" -ForegroundColor Cyan
Write-Host ""

# Display results
foreach ($result in $results) {
    Write-Host "$($result.Status) - $($result.Name)" -ForegroundColor $(
        if ($result.Status -eq "✅ Complete") { "Green" }
        elseif ($result.Status -eq "⚠️  Partial") { "Yellow" }
        else { "Red" }
    )
    
    if ($result.Status -ne "❌ File Not Found") {
        Write-Host "  Class Doc: $($result.HasClassDoc)" -ForegroundColor Gray
        Write-Host "  Usage Example: $($result.HasUsageExample)" -ForegroundColor Gray
        Write-Host "  DI Documentation: $($result.HasDIDoc)" -ForegroundColor Gray
        Write-Host "  Error Handling Doc: $($result.HasErrorHandlingDoc)" -ForegroundColor Gray
        Write-Host "  Critical Rules: $($result.HasCriticalRules)" -ForegroundColor Gray
        Write-Host "  Methods: $($result.DocumentedMethods)/$($result.MethodCount) ($($result.MethodCoverage)%)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Summary
$completeCount = ($results | Where-Object { $_.Status -eq "✅ Complete" }).Count
$totalCount = $results.Count
$completionRate = [math]::Round(($completeCount / $totalCount) * 100, 2)

Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Complete: $completeCount/$totalCount ($completionRate%)" -ForegroundColor $(
    if ($completionRate -eq 100) { "Green" }
    elseif ($completionRate -ge 80) { "Yellow" }
    else { "Red" }
)

# Save report
$reportPath = ".kiro/specs/code-quality-and-testing-improvement/repository_documentation_report.md"
$report = @"
# Repository Documentation Verification Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Summary
- **Total Repositories:** $totalCount
- **Complete:** $completeCount
- **Completion Rate:** $completionRate%

## Detailed Results

| Repository | Status | Class Doc | Usage Example | DI Doc | Error Handling | Critical Rules | Method Coverage |
|------------|--------|-----------|---------------|--------|----------------|----------------|-----------------|
"@

foreach ($result in $results) {
    $classDoc = if ($result.HasClassDoc) { "✅" } else { "❌" }
    $example = if ($result.HasUsageExample) { "✅" } else { "❌" }
    $diDoc = if ($result.HasDIDoc) { "✅" } else { "❌" }
    $errorDoc = if ($result.HasErrorHandlingDoc) { "✅" } else { "❌" }
    $rules = if ($result.HasCriticalRules) { "✅" } else { "❌" }
    $methods = "$($result.DocumentedMethods)/$($result.MethodCount) ($($result.MethodCoverage)%)"
    
    $report += "`n| $($result.Name) | $($result.Status) | $classDoc | $example | $diDoc | $errorDoc | $rules | $methods |"
}

$report += @"


## Analysis

"@

if ($completionRate -eq 100) {
    $report += "✅ All repositories have complete documentation!`n`n"
} else {
    $report += "### Repositories Needing Attention`n`n"
    $incomplete = $results | Where-Object { $_.Status -ne "✅ Complete" }
    foreach ($repo in $incomplete) {
        $report += "**$($repo.Name)**`n"
        if (-not $repo.HasClassDoc) { $report += "- Add class-level documentation`n" }
        if (-not $repo.HasUsageExample) { $report += "- Add usage example`n" }
        if (-not $repo.HasDIDoc) { $report += "- Document dependency injection`n" }
        if (-not $repo.HasErrorHandlingDoc) { $report += "- Document error handling`n" }
        if (-not $repo.HasCriticalRules) { $report += "- Document critical database rules`n" }
        if ($repo.MethodCoverage -lt 80) { 
            $needed = $repo.MethodCount - $repo.DocumentedMethods
            $report += "- Document $needed more methods (current: $($repo.MethodCoverage)%)`n" 
        }
        $report += "`n"
    }
}

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host ""
Write-Host "Report saved to: $reportPath" -ForegroundColor Cyan

# Exit code
if ($completionRate -eq 100) {
    exit 0
} else {
    exit 1
}
