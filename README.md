# Claude Code Presentations

Marp-based presentations about Claude Code's advanced features.

## 📚 Available Presentations

1. **Agents** - Specialized AI subagents for task automation
2. **Status Line** - Real-time terminal monitoring

## 🚀 Quick Start

```bash
# Install dependencies
just install

# List available commands
just

# Start development server for all presentations
just dev-all

# Start development server for a specific presentation
just dev presentations/agents.md

# Build all presentations to HTML
just build-all
```

## 📦 Commands

### Development

```bash
just dev PRESENTATION  # Dev mode with live reload for specific presentation
just dev-all          # Dev mode for all presentations
```

### Building

```bash
just build PRESENTATION         # Build specific presentation to HTML
just build PRESENTATION pdf     # Build specific presentation to PDF
just build-all                  # Build all presentations to HTML
just build-all pdf              # Build all presentations to PDF
just dist                       # Build all formats (HTML and PDF) to dist/
```

### Other

```bash
just install    # Install npm dependencies
just precommit  # Run precommit checks
just clean      # Remove all build artifacts
just            # List all available commands
```

## 📁 Project Structure

```text
marp/
├── presentations/
│   ├── agents.md
│   ├── statusline.md
│   ├── screenshots/    # Images used in presentations
│   ├── themes/         # Custom Marp themes
│   │   └── anthropic.css
│   └── templates/
│       └── default.md
├── justfile
├── package.json
└── README.md
```

## 🎯 Presentation Topics

### Agents

- What are Agents and why use them
- Creating & managing agents
- Real-world examples
- Best practices & advanced usage

### Status Line

- Real-time context monitoring
- Configuration & setup
- Customization options
- Cost tracking & management

## 🛠️ Requirements

- Node.js & npm
- just (command runner)

## 📝 Editing

Edit presentations using Marp markdown syntax:

```markdown
---
marp: true
theme: default
paginate: true
---

# Slide Title

Content here

---

# Next Slide
```

## 🔗 Resources

- [Marp Documentation](https://marp.app)
- [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)
