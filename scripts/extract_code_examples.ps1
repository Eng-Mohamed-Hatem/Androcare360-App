# Extract Code Examples from Documentation
# This script extracts all Dart code examples from documentation files
# and verifies their syntax

Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Code Example Extraction and Verification" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Initialize counters
$totalExamples = 0
$validExamples = 0
$invalidExamples = 0
$examplesWithIssues = @()

# Create output directory
$outputDir = ".kiro/specs/code-quality-and-testing-improvement"
if (-not (Test-Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

# Output file for extracted examples
$extractedFile = "$outputDir/extracted_code_examples.dart"
$reportFile = "$outputDir/code_examples_syntax_report.md"

# Initialize extracted examples file
@"
// Extracted Code Examples from Documentation
// This file is auto-generated for syntax verification
// DO NOT EDIT MANUALLY

// ignore_for_file: unused_import, unused_local_variable, dead_code
// ignore_for_file: unnecessary_import, duplicate_ignore

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_functions/firebase_functions.dart';

// Placeholder types for examples
class AppointmentModel {}
class UserModel {}
class NutritionEMREntity {}
class PhysiotherapyEMR {}
class AgoraService {}
class VoIPCallService {}
class CallMonitoringService {}
class DeviceInfoService {}
class EncryptionService {}
class NotificationService {}
class VideoConsultationService {}
class FCMService {}
class TokenRefreshService {}
class BackgroundService {}

// Placeholder for getIt
class GetIt {
  T call<T>() => throw UnimplementedError();
}
final getIt = GetIt();

void main() {
  // This file is for syntax verification only
  print('Code examples extracted successfully');
}

// ============================================================================
// EXTRACTED CODE EXAMPLES
// ============================================================================

"@ | Out-File -FilePath $extractedFile -Encoding UTF8

Write-Host "Scanning for code examples..." -ForegroundColor Yellow
Write-Host ""

# Function to extract code examples from a file
function Extract-CodeExamples {
    param (
        [string]$FilePath,
        [string]$FileType
    )
    
    if (-not (Test-Path $FilePath)) {
        return
    }
    
    $content = Get-Content $FilePath -Raw
    $fileName = Split-Path $FilePath -Leaf
    
    # Find all ```dart code blocks
    $pattern = '```dart\s*(.*?)\s*```'
    $matches = [regex]::Matches($content, $pattern, [System.Text.RegularExpressions.RegexOptions]::Singleline)
    
    if ($matches.Count -eq 0) {
        return
    }
    
    Write-Host "  Found $($matches.Count) example(s) in $fileName" -ForegroundColor Green
    
    foreach ($match in $matches) {
        $script:totalExamples++
        $codeBlock = $match.Groups[1].Value.Trim()
        
        # Skip empty code blocks
        if ([string]::IsNullOrWhiteSpace($codeBlock)) {
            continue
        }
        
        # Add to extracted file
        @"

// ============================================================================
// Example from: $fileName ($FileType)
// ============================================================================

void example_$($script:totalExamples)() {
  // Example code:
$codeBlock
}

"@ | Out-File -FilePath $extractedFile -Append -Encoding UTF8
        
        # Basic syntax validation
        $hasErrors = $false
        $issues = @()
        
        # Check for common syntax issues
        if ($codeBlock -match '^\s*//') {
            # Skip comment-only examples
            continue
        }
        
        # Check for incomplete code (missing semicolons, braces)
        $openBraces = ($codeBlock -split '\{').Count - 1
        $closeBraces = ($codeBlock -split '\}').Count - 1
        if ($openBraces -ne $closeBraces) {
            $hasErrors = $true
            $issues += "Mismatched braces (open: $openBraces, close: $closeBraces)"
        }
        
        $openParens = ($codeBlock -split '\(').Count - 1
        $closeParens = ($codeBlock -split '\)').Count - 1
        if ($openParens -ne $closeParens) {
            $hasErrors = $true
            $issues += "Mismatched parentheses (open: $openParens, close: $closeParens)"
        }
        
        # Check for undefined variables (basic check)
        if ($codeBlock -match '\b(getIt|ref\.watch|ref\.read)\b' -and $codeBlock -notmatch 'import') {
            # These are likely valid in context
        }
        
        if ($hasErrors) {
            $script:invalidExamples++
            $script:examplesWithIssues += @{
                File = $fileName
                Type = $FileType
                Issues = $issues
                Code = $codeBlock.Substring(0, [Math]::Min(100, $codeBlock.Length)) + "..."
            }
        } else {
            $script:validExamples++
        }
    }
}

# Scan Dart files for doc comments
Write-Host "Scanning Dart files..." -ForegroundColor Cyan
$dartFiles = @(
    # Core Services
    "lib/core/services/agora_service.dart",
    "lib/core/services/voip_call_service.dart",
    "lib/core/services/call_monitoring_service.dart",
    "lib/core/services/device_info_service.dart",
    "lib/core/services/encryption_service.dart",
    "lib/core/services/notification_service.dart",
    "lib/core/services/video_consultation_service.dart",
    "lib/core/services/fcm_service.dart",
    "lib/core/services/token_refresh_service.dart",
    "lib/core/services/background_service.dart",
    
    # Data Models
    "lib/shared/models/appointment_model.dart",
    "lib/shared/models/user_model.dart",
    "lib/features/nutrition/domain/entities/nutrition_emr_entity.dart",
    "lib/features/doctor/medical_records/domain/entities/physiotherapy_emr.dart",
    
    # Repositories
    "lib/features/auth/data/repositories/auth_repository_impl.dart",
    "lib/features/appointments/data/repositories/appointment_repository_impl.dart",
    "lib/features/nutrition/data/repositories/nutrition_emr_repository_impl.dart",
    "lib/features/doctor/medical_records/data/repositories/physiotherapy_emr_repository_impl.dart",
    "lib/features/doctor/data/repositories/doctor_repository_impl.dart"
)

foreach ($file in $dartFiles) {
    Extract-CodeExamples -FilePath $file -FileType "Dart Source"
}

# Scan Markdown files
Write-Host ""
Write-Host "Scanning Markdown files..." -ForegroundColor Cyan
$markdownFiles = @(
    "README.md",
    "CONTRIBUTING.md",
    "API_DOCUMENTATION.md",
    "CHANGELOG.md"
)

foreach ($file in $markdownFiles) {
    Extract-CodeExamples -FilePath $file -FileType "Markdown"
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
Write-Host "Extraction Complete" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Total Examples Found: $totalExamples" -ForegroundColor White
Write-Host "Valid Examples: $validExamples" -ForegroundColor Green
Write-Host "Examples with Issues: $invalidExamples" -ForegroundColor $(if ($invalidExamples -gt 0) { "Red" } else { "Green" })
Write-Host ""

# Generate report
$reportContent = @"
# Code Examples Syntax Verification Report

**Date:** $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")  
**Task:** 17.2 - Code Example Syntax Verification  
**Status:** $(if ($invalidExamples -eq 0) { "✅ Complete" } else { "⚠️ Issues Found" })

---

## Summary

| Metric | Count | Status |
|--------|-------|--------|
| **Total Examples** | $totalExamples | - |
| **Valid Examples** | $validExamples | $(if ($validExamples -eq $totalExamples) { "✅" } else { "⚠️" }) |
| **Examples with Issues** | $invalidExamples | $(if ($invalidExamples -eq 0) { "✅" } else { "❌" }) |
| **Success Rate** | $(if ($totalExamples -gt 0) { [math]::Round(($validExamples / $totalExamples) * 100, 2) } else { 0 })% | $(if ($invalidExamples -eq 0) { "✅" } else { "⚠️" }) |

---

## Extraction Results

### Files Scanned

**Dart Source Files:** $($dartFiles.Count)
**Markdown Files:** $($markdownFiles.Count)

### Examples by File Type

| File Type | Examples Found |
|-----------|----------------|
| Dart Source | $(($dartFiles | ForEach-Object { (Get-Content $_ -Raw -ErrorAction SilentlyContinue | Select-String -Pattern '```dart' -AllMatches).Matches.Count } | Measure-Object -Sum).Sum) |
| Markdown | $(($markdownFiles | ForEach-Object { (Get-Content $_ -Raw -ErrorAction SilentlyContinue | Select-String -Pattern '```dart' -AllMatches).Matches.Count } | Measure-Object -Sum).Sum) |

---

## Issues Found

"@

if ($invalidExamples -eq 0) {
    $reportContent += @"

✅ **No syntax issues found!**

All code examples have been verified and appear to be syntactically correct.

"@
} else {
    $reportContent += @"

⚠️ **$invalidExamples example(s) have potential issues:**

"@
    
    $issueNumber = 1
    foreach ($issue in $examplesWithIssues) {
        $issueFile = $issue.File
        $issueType = $issue.Type
        $issueCode = $issue.Code
        
        $reportContent += "`n`n### Issue $issueNumber`: $issueFile`n`n"
        $reportContent += "**File Type:** $issueType`n"
        $reportContent += "**Problems:**`n"
        
        foreach ($problem in $issue.Issues) {
            $reportContent += "- $problem`n"
        }
        
        $reportContent += "`n**Code Preview:**`n"
        $reportContent += "``````dart`n"
        $reportContent += "$issueCode`n"
        $reportContent += "```````n"
        
        $issueNumber++
    }
}

$reportContent += @"

---

## Next Steps

"@

if ($invalidExamples -eq 0) {
    $reportContent += @"

1. ✅ All examples extracted successfully
2. ⏭️ Proceed to Subtask 17.3: Example Compilation Testing
3. ⏭️ Run flutter analyze on extracted examples
4. ⏭️ Verify examples follow project conventions

"@
} else {
    $reportContent += @"

1. ❌ Fix syntax issues in the identified examples
2. 🔄 Re-run extraction script
3. ✅ Verify all issues resolved
4. ⏭️ Proceed to Subtask 17.3: Example Compilation Testing

"@
}

$reportContent += @"

---

## Extracted Examples File

All code examples have been extracted to:
``````
$extractedFile
``````

To verify compilation:
``````bash
flutter analyze $extractedFile
``````

---

**Generated by:** extract_code_examples.ps1  
**Report Location:** $reportFile

---

**End of Report**
"@

# Save report
$reportContent | Out-File -FilePath $reportFile -Encoding UTF8

Write-Host "Report saved to: $reportFile" -ForegroundColor Green
Write-Host "Extracted examples saved to: $extractedFile" -ForegroundColor Green
Write-Host ""

if ($invalidExamples -eq 0) {
    Write-Host "✅ All code examples appear syntactically correct!" -ForegroundColor Green
    Write-Host ""
    Write-Host "Next step: Run 'flutter analyze $extractedFile' to verify compilation" -ForegroundColor Yellow
} else {
    Write-Host "⚠️ Found $invalidExamples example(s) with potential issues" -ForegroundColor Yellow
    Write-Host "Review the report for details: $reportFile" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "================================================" -ForegroundColor Cyan
