---
marp: true
theme: anthropic
paginate: true
---

# Claude Code Status Line

## Real-time Terminal Monitoring

<!--
This presentation uses the Uncover theme, one of Marp's three built-in themes.
-->

---

# Agenda

- 📊 What is Status Line?
- ⚙️ Configuration & Setup
- 🎨 Customization Options
- 💡 Practical Examples
- 🚀 Tips & Tricks

---

# Claude Code's Release Velocity

- 📅 **1-3 releases per day**
- 🚀 Status Line: Recent major feature
- 🔄 Constant improvements and updates

<!--
I can't believe the pace at which they release things. If you look at the changelog, they release one to three times per day. A lot of the features are small, but status line is one of the bigger ones that I wanted to show you today.
-->

---

# What is Status Line?

Real-time context monitoring in your terminal

Two customizable status lines:

- **Line 1**: Claude Powerline - Git info, context window, version
- **Line 2**: CC Usage - Cost tracking by session/day/month

---

# Why Status Line?

## Key benefits:

- 👀 **Visibility**: Always see context usage
- 💰 **Cost awareness**: Track spending in real-time
- 🔄 **Session info**: Know your model and version
- 📍 **Git context**: Current branch and status

---

# Setting Up Status Line

## Two approaches:

### 1. Slash command (recommended for setup)

```bash
/statusline
```

### 2. Manual configuration

Edit `~/.zshrc` or `~/.bashrc`

---

# Manual Configuration

```bash
# In your shell config file
statusLine.command "claude status-line"
```

Or for combined output:

```bash
statusLine.command "bash ~/.claude/status-line.sh"
```

---

# Status Line Components

## Available information:

- 📁 Working directory
- 🤖 Current model (Opus, Sonnet, etc.)
- 📊 Context usage (tokens & percentage)
- 💰 Cost information
- 🔢 Version number
- 📝 Transcript path for resume

---

# Example: Claude Powerline

First line configuration:

```bash
claude-powerline \
  --show-git \
  --show-version \
  --show-context \
  --hide-cost  # Cost shown in second line
```

Displays: Git branch, context %, version

---

# Example: CC Usage

Second line configuration:

```bash
cc-usage status-line \
  --session \
  --day \
  --month
```

Shows cost breakdown by time period

---

# Combining Both Lines

Create `~/.claude/status-line.sh`:

```bash
#!/bin/bash
INPUT=$(claude status-line)

# Line 1: Powerline
echo "$INPUT" | claude-powerline \
  --show-git --show-version

# Line 2: Usage
echo "$INPUT" | cc-usage status-line \
  --session --day --month
```

---

# JSON Input Structure

Status line receives JSON with:

- `directory`: Current working directory
- `model`: Active Claude model
- `context`: Token usage info
- `cost`: Pricing information
- `version`: Claude Code version
- `transcript_path`: Resume file location

---

# Customization: Claude Powerline

Configuration file: `~/.claude/powerline.toml`

```toml
[display]
show_git = true
show_version = true
show_context = true
show_cost = false

[git]
show_branch = true
show_ahead_behind = true
```

---

# Customization: CC Usage

Flags for different views:

- `--session`: Current session cost
- `--day`: Today's total
- `--month`: Monthly total
- `--model`: Breakdown by model

Can combine multiple flags for comprehensive view

---

# Context Management

## Understanding the percentages:

- **Context Used**: How full your context window is
- **Context Left**: Remaining space
- Note: They don't always add to 100% due to reserved space

Critical for long sessions!

---

# Cost Tracking

## Subscription vs Pay-per-use:

- **Subscription**: Track against monthly limits
- **Pay-per-use**: Monitor actual costs
- **"Block"**: Subscription-specific metric

Helps optimize model selection

---

# Version Awareness

Why track version?

- Claude Code updates **daily**
- Features change rapidly
- Long-running tabs may be outdated

```bash
# Check if you're behind
claude --version
```

---

# Troubleshooting

## Common issues:

1. **Not updating**: Check shell integration
2. **Missing info**: Verify permissions
3. **Wrong shell**: Ensure correct RC file
4. **Escape sequences**: Terminal compatibility

---

# Advanced: Multiple Projects

Status line updates per terminal tab:

- Different projects = different contexts
- Cost tracking per session
- Git info follows directory

Perfect for multitasking!

---

# Integration with tmux/screen

```bash
# tmux status bar
set -g status-right '#(claude status-line | \
  claude-powerline --compact)'
```

Keeps info visible in multiplexers

---

# Performance Considerations

- Status line polls every prompt
- Minimal overhead (~10ms)
- Cached for rapid updates
- No network calls required

---

# Best Practices

- ✅ **Combine both lines** for full picture
- ✅ **Monitor context** to avoid compaction
- ✅ **Track costs** if on subscription
- ✅ **Update regularly** to get new features
- ✅ **Customize** to your workflow

---

# Pro Tips

1. 🎨 **Color coding**: Red = high usage, Green = plenty of space
2. 📊 **Percentage thresholds**: Configure warnings at 80%
3. 💡 **Micro-compaction**: New feature preserves more context
4. 🔄 **Auto-refresh**: Updates with each command

---

# CC Usage Beyond Status Line

Standalone cost analysis:

```bash
# Detailed cost breakdown
cc-usage

# By model
cc-usage --by-model

# Last 7 days
cc-usage --days 7
```

---

# Future Enhancements

Coming soon:

- 🎯 Custom metrics
- 📈 Usage graphs
- 🔔 Alert thresholds
- 🌍 Multi-account support

---

# Resources

- 📚 [Claude Code Docs](https://docs.anthropic.com/en/docs/claude-code)
- 🔧 [Status Line Setup](https://docs.anthropic.com/en/docs/claude-code/statusline)
- 💬 Issues: [github.com/anthropics/claude-code/issues](https://github.com/anthropics/claude-code/issues)

---

# Questions?

## Key takeaways:

- 📊 Real-time monitoring improves awareness
- 💰 Cost tracking prevents surprises
- 🎨 Highly customizable to your needs

---

# Thank You!

Happy monitoring! 📊
