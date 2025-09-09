#!/bin/bash

# Script to migrate individual branch-based Docker images to the new images/ structure

set -e

# List of branches to migrate
BRANCHES=(
    "alpine-sshd"
    "beanstalkd" 
    "centos"
    "chrome-vnc"
    "docker-utils"
    "hexo"
    "httplive"
    "ipython"
    "jupyter"
    "kcptun"
    "kcptun-client"
    "lamptun"
    "minicron"
    "minio"
    "nextcloud"
    "opengrok"
    "pyspider"
    "snmpd"
    "ssh-client"
    "sslocal"
    "tox"
    "ubuntu"
    "webcron"
    "webdav"
    "yapf"
    "zabbix"
)

# Function to migrate a single branch
migrate_branch() {
    local branch_name=$1
    echo "Migrating branch: $branch_name"
    
    # Switch to the branch
    git checkout "$branch_name" 2>/dev/null || {
        echo "Warning: Could not checkout branch $branch_name, skipping..."
        return 1
    }
    
    # Create target directory
    mkdir -p "images/$branch_name"
    
    # Copy files if they exist
    if [[ -f "Dockerfile" ]]; then
        cp "Dockerfile" "images/$branch_name/"
        echo "  ✓ Copied Dockerfile"
    fi
    
    if [[ -f "build.sh" ]]; then
        cp "build.sh" "images/$branch_name/"
        echo "  ✓ Copied build.sh"
    fi
    
    if [[ -f "entry.sh" ]]; then
        cp "entry.sh" "images/$branch_name/"
        echo "  ✓ Copied entry.sh"
    fi
    
    if [[ -f "README.md" ]]; then
        # Create a basic README if one doesn't exist or is minimal
        if [[ $(wc -l < "README.md") -gt 5 ]]; then
            cp "README.md" "images/$branch_name/"
            echo "  ✓ Copied README.md"
        else
            # Create a basic README
            cat > "images/$branch_name/README.md" << EOF
# $branch_name Docker Image

Docker image for $branch_name.

## Usage

\`\`\`bash
# Build the image
docker build -t $branch_name .

# Run the container
docker run -d $branch_name
\`\`\`

## Files

- \`Dockerfile\`: Main Docker image definition
$(if [[ -f "build.sh" ]]; then echo "- \`build.sh\`: Build script for image setup"; fi)
$(if [[ -f "entry.sh" ]]; then echo "- \`entry.sh\`: Container entrypoint script"; fi)

## Original Implementation

This image was migrated from the \`$branch_name\` branch of the original repository structure.
EOF
            echo "  ✓ Created basic README.md"
        fi
    else
        # Create a basic README if none exists
        cat > "images/$branch_name/README.md" << EOF
# $branch_name Docker Image

Docker image for $branch_name.

## Usage

\`\`\`bash
# Build the image
docker build -t $branch_name .

# Run the container
docker run -d $branch_name
\`\`\`

## Files

- \`Dockerfile\`: Main Docker image definition
$(if [[ -f "build.sh" ]]; then echo "- \`build.sh\`: Build script for image setup"; fi)
$(if [[ -f "entry.sh" ]]; then echo "- \`entry.sh\`: Container entrypoint script"; fi)

## Original Implementation

This image was migrated from the \`$branch_name\` branch of the original repository structure.
EOF
        echo "  ✓ Created basic README.md"
    fi
    
    # Copy any other relevant files
    for file in Makefile config.* *.conf *.yaml *.yml *.json; do
        if [[ -f "$file" ]]; then
            cp "$file" "images/$branch_name/"
            echo "  ✓ Copied $file"
        fi
    done
    
    echo "  ✓ Migration completed for $branch_name"
    echo ""
}

# Main migration process
echo "Starting migration of branch-based Docker images..."
echo "=========================================="

# Store current branch
CURRENT_BRANCH=$(git branch --show-current)

# Migrate each branch
for branch in "${BRANCHES[@]}"; do
    migrate_branch "$branch"
done

# Return to original branch
echo "Returning to original branch: $CURRENT_BRANCH"
git checkout "$CURRENT_BRANCH"

echo "=========================================="
echo "Migration completed!"
echo ""
echo "Summary:"
echo "- Migrated ${#BRANCHES[@]} image branches"
echo "- Files copied to images/ directory structure"
echo "- Basic READMEs created where needed"
echo ""
echo "Next steps:"
echo "1. Review and update Dockerfiles for modern practices"
echo "2. Test build process for each image"
echo "3. Update documentation as needed"
echo "4. Commit changes to the images branch"
