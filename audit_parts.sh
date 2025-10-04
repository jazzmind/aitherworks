#!/bin/bash
# Audit all part YAML files for port naming compliance
# Schema requires: ^(in|out)_(north|south|east|west)$

echo "=== Part YAML Port Naming Audit ==="
echo ""

PARTS_DIR="data/parts"
TOTAL_FILES=0
COMPLIANT_FILES=0
NON_COMPLIANT_FILES=0
ISSUES_FOUND=0

# Schema pattern
VALID_PORT_PATTERN="^(in|out)_(north|south|east|west)$"

echo "Checking all YAML files in $PARTS_DIR/"
echo ""

for yaml_file in $PARTS_DIR/*.yaml; do
    filename=$(basename "$yaml_file")
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    # Extract port names (look for lines under 'ports:' that are keys)
    # This is a simple grep approach - may need refinement
    port_names=$(awk '
        /^ports:/ { in_ports=1; next }
        in_ports && /^[a-z_]+:/ { 
            match($0, /^[[:space:]]*([a-z_]+):/, arr)
            if (arr[1] != "") print arr[1]
        }
        /^[a-z]+:/ && !/^[[:space:]]/ && in_ports { in_ports=0 }
    ' "$yaml_file")
    
    if [ -z "$port_names" ]; then
        echo "⚠️  $filename: No ports found (may need manual check)"
        continue
    fi
    
    file_has_issues=0
    while IFS= read -r port_name; do
        # Check if port name matches schema pattern
        if [[ ! "$port_name" =~ $VALID_PORT_PATTERN ]]; then
            if [ $file_has_issues -eq 0 ]; then
                echo "❌ $filename:"
                file_has_issues=1
                NON_COMPLIANT_FILES=$((NON_COMPLIANT_FILES + 1))
            fi
            echo "   - '$port_name' (should be in|out + _ + north|south|east|west)"
            ISSUES_FOUND=$((ISSUES_FOUND + 1))
        fi
    done <<< "$port_names"
    
    if [ $file_has_issues -eq 0 ]; then
        echo "✅ $filename"
        COMPLIANT_FILES=$((COMPLIANT_FILES + 1))
    fi
done

echo ""
echo "=== Summary ==="
echo "Total files:        $TOTAL_FILES"
echo "Compliant:          $COMPLIANT_FILES"
echo "Non-compliant:      $NON_COMPLIANT_FILES"
echo "Issues found:       $ISSUES_FOUND"
echo ""

if [ $NON_COMPLIANT_FILES -eq 0 ]; then
    echo "✅ All part YAMLs follow schema naming convention!"
    exit 0
else
    echo "❌ Found $NON_COMPLIANT_FILES files with port naming issues"
    exit 1
fi

