# AGENTS.md - Coding Guidelines for GFWList2PAC

This document provides guidelines for AI coding agents working in the GFWList2PAC repository.

## Project Overview

**GFWList2PAC** is a Bash-based automation tool that generates proxy auto-configuration (PAC) files in multiple formats from domain lists. It fetches whitelist (CNACC) and blacklist (GFWList) domain data, then generates configuration files for various proxy clients including AutoProxy, Clash, Shadowrocket, Surge, Quantumult, v2rayA, and v2rayN.

**License**: Apache 2.0 with Commons Clause v1.0  
**Author**: Zhijie He (hezhijie0327@hotmail.com)  
**Homepage**: https://github.com/hezhijie0327/GFWList2PAC

## Build, Test, and Lint Commands

### Build/Run
```bash
# Full build - generates all output files
bash release.sh

# The script performs:
# 1. Fetches domain lists from upstream sources
# 2. Processes and analyzes domain data
# 3. Generates configuration files in 8 different formats
# 4. Base64 encodes AutoProxy format files
```

### Testing
This project does not have automated tests. Validation is done by:
1. Running `bash release.sh` successfully
2. Verifying all output files are generated: `ls -lh gfwlist2pac_*`
3. Checking file sizes are reasonable (CNACC files ~2-4MB, GFWList files ~0.7-1.2MB)
4. Inspecting file headers contain correct metadata

### Linting
```bash
# Check bash syntax
bash -n release.sh

# Use shellcheck if available
shellcheck release.sh
```

### CI/CD
GitHub Actions workflow (`.github/workflows/main.yml`):
- Runs daily at 00:00 UTC via cron schedule
- Can be triggered manually via workflow_dispatch
- Executes `bash release.sh` and commits generated files

## Code Style Guidelines

### Shell Scripting Standards

#### Shebang and Header
- Always use `#!/bin/bash` as the first line
- Include usage instructions in comments at the top
- Document the script's purpose clearly

#### Function Naming
- Use PascalCase for function names (e.g., `GetData`, `AnalyseData`, `OutputData`)
- Make function names descriptive of their purpose
- Group related functions together

#### Variable Naming
- Use snake_case for variables (e.g., `cnacc_domain`, `gfwlist_data`)
- Use descriptive names that indicate purpose
- Prefix array iteration variables with the array name (e.g., `cnacc_domain_task`)

#### Arrays and Loops
```bash
# Declare arrays with parentheses
cnacc_domain=(
    "https://example.com/list1.txt"
    "https://example.com/list2.txt"
)

# Iterate using array indices
for cnacc_domain_task in "${!cnacc_domain[@]}"; do
    curl -s --connect-timeout 15 "${cnacc_domain[$cnacc_domain_task]}" >> ./output.tmp
done
```

#### Command Execution
- Use `curl -s --connect-timeout 15` for HTTP requests
- Always specify timeouts for external calls
- Redirect output to temporary files with `.tmp` extension
- Use `awk` for text processing where appropriate

#### File Operations
- Create temporary working directory (`./Temp`) for intermediate files
- Clean up temp files after processing: `rm -rf ./Temp`
- Write final output files to parent directory with descriptive names
- Use `>>` for appending to files, `>` for overwriting

#### Comments
```bash
## Section headers use double hash
# Single line comments use single hash
```

#### Error Handling
- Use `exit 1` for invalid conditions
- Validate input parameters before processing
- Check command success implicitly (script fails on errors due to default bash behavior)

#### String Formatting
- Use double quotes for variable expansion: `"${variable}"`
- Use single quotes for literal strings: `'literal text'`
- Use command substitution with `$()`: `$(date "+%Y-%m-%d")`
- Use here-docs or echo for multi-line string generation

### Output File Formats

#### Metadata Headers
All output files must include standardized metadata:
```bash
# Checksum: <base64 timestamp>
# Title: <descriptive title>
# Version: <version-date-build>
# TimeUpdated: <ISO 8601 timestamp>
# Expires: 3 hours (update frequency)
# Homepage: https://github.com/hezhijie0327/GFWList2PAC
```

#### Version Format
- Format: `<base-version>-<YYYYMMDD>-<build-number>`
- Build number: hour divided by 3 (0-7, representing 3-hour update cycles)
- Example: `1.0.0-20260207-5`

#### Domain Rules Format
Each output format has specific syntax:
- **AutoProxy**: `||domain.com^` (proxy) or `@@||domain.com^` (direct)
- **Clash**: `  - DOMAIN-SUFFIX,domain.com`
- **Clash Premium**: `  - '+.domain.com'`
- **Shadowrocket/Surge/Quantumult**: `DOMAIN-SUFFIX,domain.com,ACTION`
- **v2rayA**: `domain:domain.com,` (aggregated with wrapper)
- **v2rayN**: `domain:domain.com,` (one per line)

### Data Processing Patterns

#### Two-List System
- **CNACC** (whitelist): Chinese accessible domains → DIRECT routing
- **GFWList** (blacklist): Blocked domains → PROXY routing
- Process both lists with identical logic but different routing actions

#### Pipeline Structure
1. **GetData()**: Fetch upstream domain lists via curl
2. **AnalyseData()**: Parse and extract domains using awk
3. **GenerateHeaderInformation()**: Create metadata for all formats
4. **OutputData()**: Loop through domains and write rules
5. **GenerateFooterInformation()**: Add closing syntax where needed
6. **EncodeData()**: Base64 encode specific formats (AutoProxy)

## Git Workflow

### Branching
- Main branch: `source` (not `main` or `master`)
- Generated files committed directly to `source` branch
- CI automatically commits after each build

### Commit Messages
- Format: Automated commits use "Generated by GitHub Actions"
- Manual commits should describe changes to `release.sh` logic

### Files to Commit
- Always commit: `release.sh`, `LICENSE`, `.github/workflows/main.yml`
- Generated output files: All `gfwlist2pac_*` files (committed by CI)
- Never commit: `Temp/` directory or `*.tmp` files

## Common Tasks

### Adding a New Output Format
1. Create header function in `GenerateHeaderInformation()`
2. Create footer function in `GenerateFooterInformation()` if needed
3. Add domain rule generation in `OutputData()` loops
4. Add encoding function in `EncodeData()` if needed
5. Call new functions in appropriate sections
6. Update file pattern documentation

### Modifying Domain Sources
1. Update URL arrays in `GetData()` function:
   - `cnacc_domain` array for whitelist sources
   - `gfwlist_domain` array for blacklist sources
2. Ensure curl has proper timeout settings
3. Test fetching and processing manually

### Changing Update Frequency
1. Modify cron schedule in `.github/workflows/main.yml`
2. Update "Expires" metadata in `GenerateHeaderInformation()`
3. Adjust version build number calculation if needed

### Debugging
```bash
# Run with verbose output
bash -x release.sh

# Check intermediate files (run partially)
# Modify script to comment out cleanup: # rm -rf ./Temp
# Inspect: ls -lh Temp/*.tmp
```

## Important Notes

- **DO NOT** modify generated `gfwlist2pac_*` files directly (they're overwritten)
- **DO NOT** commit temporary files or the `Temp/` directory
- **DO NOT** change function execution order (dependencies exist)
- **ALWAYS** maintain header metadata consistency across formats
- **ALWAYS** test with actual domain lists (script requires network access)
- **ALWAYS** preserve Base64 encoding for AutoProxy format

## Dependencies

### Required System Tools
- `bash` (4.0+)
- `curl` (with HTTPS support)
- `awk` (gawk or mawk)
- `base64`
- `date` (with GNU date flags like `-d`)
- `sed`

### Platform Compatibility
- Designed for Linux (uses GNU date syntax)
- GitHub Actions runner: `ubuntu-latest`
- May require modifications for macOS/BSD (date command differences)

## Quick Reference

```bash
# Full build cycle
bash release.sh

# Check syntax
bash -n release.sh

# Validate outputs exist
ls -1 gfwlist2pac_* | wc -l  # Should show 16 files

# View metadata from generated file
head -10 gfwlist2pac_gfwlist_clash.yaml

# Test GitHub Actions locally (requires act)
act -j build
```

---
*This document is for AI coding agents. Keep it updated when modifying project structure or workflows.*
