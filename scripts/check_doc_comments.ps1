# Documentation Completeness Verification Script
# Checks for missing doc comments in Dart files

Write-Host "=== Documentation Completeness Check ===" -ForegroundColor Cyan
Write-Host ""

# Initialize counters
$totalClasses = 0
$documentedClasses = 0
$totalMethods = 0
$documentedMethods = 0
$totalFields = 0
$documentedFields = 0

# Arrays to store undocumented items
$undocumentedClasses = @()
$undocumentedMethods = @()
$undocumentedFields = @()

# Function to check if a line is a doc comment
function Is-DocComment {
    param($line)
    return $line -match '^\s*///'
}

# Function to check if a line is a class declaration
function Is-ClassDeclaration {
    param($line)
    return $line -match '^\s*(abstract\s+)?class\s+\w+'
}

# Function to check if a line is a public method
function Is-PublicMethod {
    param($line)
    # Match public methods (not starting with _)
    return $line -match '^\s+[A-Z]\w*\s+\w+\s*\(' -and $line -notmatch '^\s+_'
}

# Function to check if a line is a public field
function Is-PublicField {
    param($line)
    # Match public fields (final or static, not starting with _)
    return ($line -match '^\s+(final|static)\s+' -or $line -match '^\s+[A-Z]\w+\s+\w+\s*[;=]') -and $line -notmatch '^\s+_'
}

# Get all Dart files excluding generated files
$dartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | 
    Where-Object { 
        $_.Name -notmatch '\.g\.dart$' -and 
        $_.Name -notmatch '\.freezed\.dart$' -and
        $_.Name -notmatch '\.config\.dart$'
    }

Write-Host "Analyzing $($dartFiles.Count) Dart files..." -ForegroundColor Yellow
Write-Host ""

foreach ($file in $dartFiles) {
    $lines = Get-Content $file.FullName
    $previousLine = ""
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $line = $lines[$i]
        
        # Check for class declarations
        if (Is-ClassDeclaration $line) {
            $totalClasses++
            if (Is-DocComment $previousLine) {
                $documentedClasses++
            } else {
                $undocumentedClasses += "$($file.FullName):$($i+1) - $($line.Trim())"
            }
        }
        
        # Check for public methods
        if (Is-PublicMethod $line) {
            $totalMethods++
            if (Is-DocComment $previousLine) {
                $documentedMethods++
            } else {
                $undocumentedMethods += "$($file.FullName):$($i+1) - $($line.Trim())"
            }
        }
        
        # Check for public fields
        if (Is-PublicField $line) {
            $totalFields++
            if (Is-DocComment $previousLine) {
                $documentedFields++
            } else {
                $undocumentedFields += "$($file.FullName):$($i+1) - $($line.Trim())"
            }
        }
        
        $previousLine = $line
    }
}

# Calculate totals and percentages
$totalAPIs = $totalClasses + $totalMethods + $totalFields
$documentedAPIs = $documentedClasses + $documentedMethods + $documentedFields

$classPercentage = if ($totalClasses -gt 0) { [math]::Round(($documentedClasses / $totalClasses) * 100, 2) } else { 0 }
$methodPercentage = if ($totalMethods -gt 0) { [math]::Round(($documentedMethods / $totalMethods) * 100, 2) } else { 0 }
$fieldPercentage = if ($totalFields -gt 0) { [math]::Round(($documentedFields / $totalFields) * 100, 2) } else { 0 }
$overallPercentage = if ($totalAPIs -gt 0) { [math]::Round(($documentedAPIs / $totalAPIs) * 100, 2) } else { 0 }

# Display results
Write-Host "=== DOCUMENTATION COVERAGE SUMMARY ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Classes:" -ForegroundColor White
Write-Host "  Total: $totalClasses" -ForegroundColor Gray
Write-Host "  Documented: $documentedClasses" -ForegroundColor Gray
Write-Host "  Coverage: $classPercentage%" -ForegroundColor $(if ($classPercentage -ge 90) { "Green" } elseif ($classPercentage -ge 70) { "Yellow" } else { "Red" })
Write-Host ""

Write-Host "Methods:" -ForegroundColor White
Write-Host "  Total: $totalMethods" -ForegroundColor Gray
Write-Host "  Documented: $documentedMethods" -ForegroundColor Gray
Write-Host "  Coverage: $methodPercentage%" -ForegroundColor $(if ($methodPercentage -ge 90) { "Green" } elseif ($methodPercentage -ge 70) { "Yellow" } else { "Red" })
Write-Host ""

Write-Host "Fields:" -ForegroundColor White
Write-Host "  Total: $totalFields" -ForegroundColor Gray
Write-Host "  Documented: $documentedFields" -ForegroundColor Gray
Write-Host "  Coverage: $fieldPercentage%" -ForegroundColor $(if ($fieldPercentage -ge 90) { "Green" } elseif ($fieldPercentage -ge 70) { "Yellow" } else { "Red" })
Write-Host ""

Write-Host "=== OVERALL COVERAGE ===" -ForegroundColor Cyan
Write-Host "Total Public APIs: $totalAPIs" -ForegroundColor White
Write-Host "Documented APIs: $documentedAPIs" -ForegroundColor White
Write-Host "Coverage: $overallPercentage%" -ForegroundColor $(if ($overallPercentage -ge 90) { "Green" } elseif ($overallPercentage -ge 70) { "Yellow" } else { "Red" })
Write-Host ""

# Check if target met
if ($overallPercentage -ge 90) {
    Write-Host "✅ Coverage target met (≥ 90%)" -ForegroundColor Green
} else {
    Write-Host "❌ Coverage below target: $overallPercentage% < 90%" -ForegroundColor Red
    $needed = [math]::Ceiling(($totalAPIs * 0.9) - $documentedAPIs)
    Write-Host "Need to document $needed more APIs to reach 90%" -ForegroundColor Yellow
}

Write-Host ""

# Save detailed report
$reportPath = ".kiro/specs/code-quality-and-testing-improvement/doc_coverage_report.txt"
$report = @"
# Documentation Coverage Report
Generated: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

## Overall Coverage
- Total Public APIs: $totalAPIs
- Documented APIs: $documentedAPIs
- Coverage: $overallPercentage%

## Coverage by Category
| Category | Total | Documented | Coverage |
|----------|-------|------------|----------|
| Classes  | $totalClasses | $documentedClasses | $classPercentage% |
| Methods  | $totalMethods | $documentedMethods | $methodPercentage% |
| Fields   | $totalFields | $documentedFields | $fieldPercentage% |

## Undocumented Classes ($($undocumentedClasses.Count))
$($undocumentedClasses -join "`n")

## Undocumented Methods ($($undocumentedMethods.Count))
$($undocumentedMethods -join "`n")

## Undocumented Fields ($($undocumentedFields.Count))
$($undocumentedFields -join "`n")
"@

$report | Out-File -FilePath $reportPath -Encoding UTF8
Write-Host "Detailed report saved to: $reportPath" -ForegroundColor Cyan
Write-Host ""

# Exit with appropriate code
if ($overallPercentage -ge 90) {
    exit 0
} else {
    exit 1
}
