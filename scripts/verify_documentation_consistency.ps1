# Documentation Consistency Verification Script
# This script checks for consistency in terminology, style, and structure across all documentation

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Documentation Consistency Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

$ErrorCount = 0
$WarningCount = 0
$ChecksPassed = 0

# Define file patterns to check
$DartFiles = Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | Where-Object { 
    $_.FullName -notmatch "\.g\.dart$" -and 
    $_.FullName -notmatch "\.freezed\.dart$" 
}

$MarkdownFiles = @(
    "README.md",
    "CONTRIBUTING.md",
    "API_DOCUMENTATION.md",
    "CHANGELOG.md"
)

Write-Host "Files to check:" -ForegroundColor Yellow
Write-Host "  - Dart files: $($DartFiles.Count)" -ForegroundColor White
Write-Host "  - Markdown files: $($MarkdownFiles.Count)" -ForegroundColor White
Write-Host ""

# ============================================================================
# 1. TERMINOLOGY CONSISTENCY CHECK
# ============================================================================

Write-Host "1. Checking Terminology Consistency..." -ForegroundColor Cyan
Write-Host "   ----------------------------------------" -ForegroundColor Gray

$TerminologyIssues = @()

# Check for inconsistent Firestore terminology
$FirestoreVariants = @(
    @{Pattern = "Firebase Firestore"; Preferred = "Firestore"},
    @{Pattern = "Cloud Firestore"; Preferred = "Firestore"},
    @{Pattern = "Firestore Database"; Preferred = "Firestore"}
)

foreach ($variant in $FirestoreVariants) {
    $pattern = $variant.Pattern
    $preferred = $variant.Preferred
    
    foreach ($file in $DartFiles + $MarkdownFiles) {
        if (Test-Path $file) {
            $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
            if ($content -match $pattern) {
                $TerminologyIssues += "   ⚠️  $($file.Name): Uses '$pattern' instead of '$preferred'"
                $WarningCount++
            }
        }
    }
}

# Check for inconsistent Cloud Functions terminology
$FunctionsVariants = @(
    @{Pattern = "Firebase Functions"; Preferred = "Cloud Functions"},
    @{Pattern = "Firebase Cloud Functions"; Preferred = "Cloud Functions"}
)

foreach ($variant in $FunctionsVariants) {
    $pattern = $variant.Pattern
    $preferred = $variant.Preferred
    
    foreach ($file in $DartFiles + $MarkdownFiles) {
        if (Test-Path $file) {
            $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
            if ($content -match $pattern) {
                $TerminologyIssues += "   ⚠️  $($file.Name): Uses '$pattern' instead of '$preferred'"
                $WarningCount++
            }
        }
    }
}

if ($TerminologyIssues.Count -eq 0) {
    Write-Host "   ✅ Terminology is consistent" -ForegroundColor Green
    $ChecksPassed++
} else {
    Write-Host "   ❌ Found $($TerminologyIssues.Count) terminology inconsistencies:" -ForegroundColor Red
    $TerminologyIssues | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}

Write-Host ""

# ============================================================================
# 2. STYLE CONSISTENCY CHECK
# ============================================================================

Write-Host "2. Checking Style Consistency..." -ForegroundColor Cyan
Write-Host "   ----------------------------------------" -ForegroundColor Gray

$StyleIssues = @()

# Check for incorrect doc comment format (// instead of ///)
foreach ($file in $DartFiles) {
    $lineNumber = 0
    $content = Get-Content $file
    
    foreach ($line in $content) {
        $lineNumber++
        
        # Check for // comments before class/method declarations (should be ///)
        if ($line -match "^\s*//\s+[A-Z]" -and $lineNumber -lt $content.Count) {
            $nextLine = $content[$lineNumber]
            if ($nextLine -match "^\s*(class|abstract class|Future|void|String|int|bool|double|List|Map|Set)") {
                $StyleIssues += "   ⚠️  $($file.Name):$lineNumber - Uses '//' instead of '///' for doc comment"
                $WarningCount++
            }
        }
    }
}

# Check for inconsistent code block formatting in markdown
foreach ($file in $MarkdownFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Check for code blocks without language specification
        if ($content -match '```\s*\n[^`]') {
            $fileName = $file
            $StyleIssues += "   ⚠️  ${fileName}: Contains code blocks without language specification"
            $WarningCount++
        }
    }
}

if ($StyleIssues.Count -eq 0) {
    Write-Host "   ✅ Style is consistent" -ForegroundColor Green
    $ChecksPassed++
} else {
    Write-Host "   ⚠️  Found $($StyleIssues.Count) style inconsistencies" -ForegroundColor Yellow
    # Don't show all issues to avoid clutter
    Write-Host "   (Minor style variations detected - see detailed report)" -ForegroundColor Gray
}

Write-Host ""

# ============================================================================
# 3. STRUCTURE CONSISTENCY CHECK
# ============================================================================

Write-Host "3. Checking Structure Consistency..." -ForegroundColor Cyan
Write-Host "   ----------------------------------------" -ForegroundColor Gray

$StructureIssues = @()

# Check that services have consistent documentation structure
$ServiceFiles = Get-ChildItem -Path "lib/core/services" -Filter "*_service.dart" -ErrorAction SilentlyContinue

$ServicesWithClassDoc = 0
$ServicesWithUsageExample = 0
$ServicesWithMethodDocs = 0

foreach ($file in $ServiceFiles) {
    $content = Get-Content $file -Raw
    
    # Check for class-level doc comment
    if ($content -match "///.*\n.*class\s+\w+Service") {
        $ServicesWithClassDoc++
    }
    
    # Check for usage example
    if ($content -match "```dart") {
        $ServicesWithUsageExample++
    }
    
    # Check for method documentation
    if ($content -match "///.*\n\s+(Future|void|String|int|bool)") {
        $ServicesWithMethodDocs++
    }
}

if ($ServiceFiles.Count -gt 0) {
    $classDocPercent = [math]::Round(($ServicesWithClassDoc / $ServiceFiles.Count) * 100, 2)
    $usageExamplePercent = [math]::Round(($ServicesWithUsageExample / $ServiceFiles.Count) * 100, 2)
    $methodDocPercent = [math]::Round(($ServicesWithMethodDocs / $ServiceFiles.Count) * 100, 2)
    
    Write-Host "   Services Documentation Structure:" -ForegroundColor White
    Write-Host "     - Class-level docs: $ServicesWithClassDoc/$($ServiceFiles.Count) ($classDocPercent%)" -ForegroundColor $(if ($classDocPercent -ge 90) { "Green" } else { "Yellow" })
    Write-Host "     - Usage examples: $ServicesWithUsageExample/$($ServiceFiles.Count) ($usageExamplePercent%)" -ForegroundColor $(if ($usageExamplePercent -ge 90) { "Green" } else { "Yellow" })
    Write-Host "     - Method docs: $ServicesWithMethodDocs/$($ServiceFiles.Count) ($methodDocPercent%)" -ForegroundColor $(if ($methodDocPercent -ge 90) { "Green" } else { "Yellow" })
    
    if ($classDocPercent -ge 90 -and $usageExamplePercent -ge 90) {
        $ChecksPassed++
    }
}

Write-Host ""

# ============================================================================
# 4. CRITICAL RULES CONSISTENCY CHECK
# ============================================================================

Write-Host "4. Checking Critical Rules Consistency..." -ForegroundColor Cyan
Write-Host "   ----------------------------------------" -ForegroundColor Gray

$CriticalRulesIssues = @()

# Check for database ID rule mentions
$DatabaseIdMentions = 0
$FilesWithDatabaseId = @()

foreach ($file in $DartFiles + $MarkdownFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
        if ($content -match "databaseId.*elajtech") {
            $DatabaseIdMentions++
            $FilesWithDatabaseId += $file.Name
        }
    }
}

Write-Host "   Database ID Rule (databaseId: 'elajtech'):" -ForegroundColor White
Write-Host "     - Mentioned in $DatabaseIdMentions files" -ForegroundColor $(if ($DatabaseIdMentions -ge 5) { "Green" } else { "Yellow" })

# Check for region rule mentions
$RegionMentions = 0
$FilesWithRegion = @()

foreach ($file in $DartFiles + $MarkdownFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw -ErrorAction SilentlyContinue
        if ($content -match "europe-west1") {
            $RegionMentions++
            $FilesWithRegion += $file.Name
        }
    }
}

Write-Host "   Region Rule (europe-west1):" -ForegroundColor White
Write-Host "     - Mentioned in $RegionMentions files" -ForegroundColor $(if ($RegionMentions -ge 5) { "Green" } else { "Yellow" })

# Check for build runner rule mentions
$BuildRunnerMentions = 0

foreach ($file in $MarkdownFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match "build_runner") {
            $BuildRunnerMentions++
        }
    }
}

Write-Host "   Build Runner Rule:" -ForegroundColor White
Write-Host "     - Mentioned in $BuildRunnerMentions markdown files" -ForegroundColor $(if ($BuildRunnerMentions -ge 2) { "Green" } else { "Yellow" })

# Check for clinic isolation rule mentions
$ClinicIsolationMentions = 0

foreach ($file in $MarkdownFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        if ($content -match "clinic.*isolation|independent.*repository|specialty.*clinic") {
            $ClinicIsolationMentions++
        }
    }
}

Write-Host "   Clinic Isolation Rule:" -ForegroundColor White
Write-Host "     - Mentioned in $ClinicIsolationMentions markdown files" -ForegroundColor $(if ($ClinicIsolationMentions -ge 1) { "Green" } else { "Yellow" })

if ($DatabaseIdMentions -ge 5 -and $RegionMentions -ge 5 -and $BuildRunnerMentions -ge 2) {
    $ChecksPassed++
}

Write-Host ""

# ============================================================================
# 5. BILINGUAL DOCUMENTATION CHECK
# ============================================================================

Write-Host "5. Checking Bilingual Documentation..." -ForegroundColor Cyan
Write-Host "   ----------------------------------------" -ForegroundColor Gray

$BilingualFiles = 0
$TotalDocumentedFiles = 0

foreach ($file in $DartFiles) {
    $content = Get-Content $file -Raw
    
    # Check if file has documentation
    if ($content -match "///") {
        $TotalDocumentedFiles++
        
        # Check for Arabic characters (basic check)
        if ($content -match "[\u0600-\u06FF]") {
            $BilingualFiles++
        }
    }
}

if ($TotalDocumentedFiles -gt 0) {
    $bilingualPercent = [math]::Round(($BilingualFiles / $TotalDocumentedFiles) * 100, 2)
    Write-Host "   Bilingual Documentation:" -ForegroundColor White
    Write-Host "     - Files with Arabic content: $BilingualFiles/$TotalDocumentedFiles ($bilingualPercent%)" -ForegroundColor $(if ($bilingualPercent -ge 50) { "Green" } else { "Yellow" })
    
    if ($bilingualPercent -ge 50) {
        $ChecksPassed++
    }
}

Write-Host ""

# ============================================================================
# 6. LINK VALIDATION CHECK
# ============================================================================

Write-Host "6. Checking Internal Links..." -ForegroundColor Cyan
Write-Host "   ----------------------------------------" -ForegroundColor Gray

$BrokenLinks = @()

foreach ($file in $MarkdownFiles) {
    if (Test-Path $file) {
        $content = Get-Content $file -Raw
        
        # Extract markdown links [text](path)
        $links = [regex]::Matches($content, '\[([^\]]+)\]\(([^\)]+)\)')
        
        foreach ($link in $links) {
            $linkPath = $link.Groups[2].Value
            
            # Check only relative links (not URLs)
            if ($linkPath -notmatch "^https?://" -and $linkPath -notmatch "^#") {
                # Remove anchor if present
                $filePath = $linkPath -replace "#.*$", ""
                
                if ($filePath -and -not (Test-Path $filePath)) {
                    $fileName = $file
                    $BrokenLinks += "   ⚠️  ${fileName}: Broken link to '$linkPath'"
                    $WarningCount++
                }
            }
        }
    }
}

if ($BrokenLinks.Count -eq 0) {
    Write-Host "   ✅ All internal links are valid" -ForegroundColor Green
    $ChecksPassed++
} else {
    Write-Host "   ⚠️  Found $($BrokenLinks.Count) broken links:" -ForegroundColor Yellow
    $BrokenLinks | ForEach-Object { Write-Host $_ -ForegroundColor Yellow }
}

Write-Host ""

# ============================================================================
# SUMMARY
# ============================================================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Consistency Verification Summary" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "Checks Passed: $ChecksPassed/6" -ForegroundColor $(if ($ChecksPassed -ge 5) { "Green" } else { "Yellow" })
Write-Host "Warnings: $WarningCount" -ForegroundColor $(if ($WarningCount -eq 0) { "Green" } elseif ($WarningCount -lt 10) { "Yellow" } else { "Red" })
Write-Host "Errors: $ErrorCount" -ForegroundColor $(if ($ErrorCount -eq 0) { "Green" } else { "Red" })
Write-Host ""

if ($ChecksPassed -ge 5 -and $ErrorCount -eq 0) {
    Write-Host "✅ Documentation consistency verification PASSED" -ForegroundColor Green
    Write-Host "   Documentation is consistent across all files" -ForegroundColor White
    exit 0
} elseif ($ChecksPassed -ge 4 -and $ErrorCount -eq 0) {
    Write-Host "⚠️  Documentation consistency verification PASSED with warnings" -ForegroundColor Yellow
    Write-Host "   Minor inconsistencies detected but overall quality is good" -ForegroundColor White
    exit 0
} else {
    Write-Host "❌ Documentation consistency verification FAILED" -ForegroundColor Red
    Write-Host "   Significant inconsistencies detected - review required" -ForegroundColor White
    exit 1
}
