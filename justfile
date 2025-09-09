# `just --list --unsorted`
[group('default')]
default:
    @just --list --unsorted

# `npm install`
[group('setup')]
install:
    npm install

# Build specific presentation (default format: html)
[group('build')]
build PRESENTATION FORMAT='html': install
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p dist
    base=$(basename "{{PRESENTATION}}")
    output="dist/${base%.md}.{{FORMAT}}"
    npx marp "{{PRESENTATION}}" --theme-set presentations/themes --output "$output" --no-stdin

# Build all presentations (default format: html)
[group('build')]
build-all FORMAT='html': install
    #!/usr/bin/env bash
    set -euo pipefail
    mkdir -p dist
    echo "Building presentations to dist/ as {{FORMAT}}..."
    for file in presentations/*.md; do
        base=$(basename "$file")
        echo "  - Building $base"
        output="dist/${base%.md}.{{FORMAT}}"
        npx marp "$file" --theme-set presentations/themes --output "$output" --no-stdin
    done

[group('dev')]
dev PRESENTATION: install
    npx marp {{PRESENTATION}} --theme-set presentations/themes --server --watch --html

[group('dev')]
dev-all: install
    npx marp --theme-set presentations/themes --server --watch --html presentations


# Generate index page for all presentations in dist
[group('build')]
index:
    #!/usr/bin/env bash
    set -euo pipefail

    # Ensure dist directory exists
    mkdir -p dist

    # Start with header template
    cat templates/index-header.html > dist/index.html

    # Add each presentation using the template
    for file in presentations/*.md; do
        if [ -f "$file" ]; then
            filename=$(basename "$file" .md)
            # Skip template files
            if [[ "$file" == *"/templates/"* ]]; then
                continue
            fi
            # Extract title from first H1 in the file
            title=$(grep '^# ' "$file" | head -1 | sed 's/^# //')
            if [ -z "$title" ]; then
                title="$filename"
            fi
            # Use the presentation template and replace placeholders
            sed -e "s|{{"{{TITLE}}"}}|$title|g" \
                -e "s|{{"{{FILENAME}}"}}|$filename|g" \
                templates/presentation-item.html >> dist/index.html
        fi
    done

    # Add footer template
    cat templates/index-footer.html >> dist/index.html

    echo "Generated index.html in dist/"

# Build everything to dist directory (both html and pdf)
[group('build')]
dist: (build-all "html") (build-all "pdf") index
    #!/usr/bin/env bash
    set -euo pipefail

    # Copy screenshots directory if it exists
    if [ -d "presentations/screenshots" ]; then
        cp -r presentations/screenshots dist/
        echo "Copied screenshots to dist/"
    fi

    # Copy themes directory if it exists
    if [ -d "presentations/themes" ]; then
        cp -r presentations/themes dist/
        echo "Copied themes to dist/"
    fi

[group('quality')]
precommit: install
    #!/usr/bin/env bash
    set -euo pipefail
    echo "Running precommit checks..."

    # Build all presentations to verify they compile
    echo "Building all presentations..."
    mkdir -p dist
    for file in presentations/*.md; do
        if [ -f "$file" ]; then
            base=$(basename "$file")
            echo "  - Building $base"
            npx marp "$file" --theme-set presentations/themes --output "dist/${base%.md}.html" --no-stdin
        fi
    done

    echo "All precommit checks passed!"

[group('clean')]
clean:
    rm -rf dist/
