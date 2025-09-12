---
marp: true
theme: anthropic
paginate: true
---

# `/agents`
## Claude Code Subagents

Craig Motlin
September 11, 2025

<!--
Hello, I'm Craig Motlin, today I'll be talking about Claude Code, especially a new feature called subagents.
-->

---

# Agenda

- How I'm using subagents and what works well.
- What are subagents good for?
- How subagents compare with other features.
- How to set up your own subagents.

<!--
Claude Code's subagents were released just over a month ago, in late July 2025. When subagents were first released, I couldn't figure out what they were for. Now I've had some time with them, and I find subagents to be extremely powerful. But I've asked around at work, and even though lots of people are using Claude Code, I found that relatively few of our colleagues are using subagents. So i's time for a deep dive.

I'll jump right into how I'm using subagents a real example, then I'll talk about their strengths, I'll compare subagents with other existing features, and I'll show how to set up your own subagents.

My primary goal is to get you using subagents effectively. Since I'm still discovering new use cases myself, I'd love to hear about your experiences - please share what you learn with me or post in Slack so we can all benefit.
-->

---

# Why Me?

- **Role**: IC in DPE, Tech Lead of Multirepo Project
- **AI Interest**: Developer productivity in the ecosystem
- **Claude Code User**: Since developer preview
- **Heavy Usage**: Anthropic changed usage caps for users like me
- **Sharing Knowledge**:
  - Blog: [motlin.com/blog/tags/claude-code](https://motlin.com/blog/tags/claude-code)
  - Config: [github.com/motlin/claude-code-prompts](https://github.com/motlin/claude-code-prompts)

<!--
So why am I (Craig) talking to you about Claude code today?

It's not because this stuff is part of my day-to-day role - which is - I work in developer productivity engineering as the tech lead of the multi-repo project.

But I've been using Claude Code since the developer preview for personal projects, and I've been using Claude Code a LOT.

I'm on the $200/month max plan, and I believe I'm one of those heavy users that prompted Anthropic to change how they calculate usage caps this month. I'm one of the people that tries to get Claude Code to run 24/7.

I also write about these topics on my blog and I share my configuration on GitHub. All of the code examples I show you today are available in that second link. My setup at work is 99% identical. So if you find any of this material useful, you should be able to copy-paste what you like from that open-source version into your configuration.

-->

---

# Example: My Todo Workflow

I keep a markdown todo list in `.llm/todo.md`:
```markdown
- [ ] Add user authentication
- [ ] Fix navigation bug
- [ ] Update dependencies
```

One command processes my entire list:
```bash
/todo-all
```

<!--
Here's the core of my workflow with Claude Code. I write a markdown todo list in a file called `todo.md` and I get Claude to do the todos. When I'm feeling ambitious, I get Claude to implement all of them in a single go. The entry point for that is a slash command that I call `/todo-all`.
-->

---

# `/todo-all` slash command

A summarized version of the slash command's prompt:

1. Find whether there is an incomplete task
   - Run `todo-get $(git rev-parse --show-toplevel)/.llm/todo.md`
   - It returns the first `Not started` task

2. Launch the `do-todo` agent to implement it

3. Repeat until no incomplete tasks remain

<!--
Here's a summarized version of the slash command.

First, it finds incomplete tasks using a custom `todo-get` script that reads the markdown todo list. This `todo-get` is just a python script I wrote to return the first incomplete task.

Second, it launches the `do-todo` subagent to implement that task. This subagent does all the work.

Third, it repeats this process until there are no tasks left.

Here we've invoked a subagent by asking Claude to run it by name. Claude can also invoke sub-agents without you asking and I'll show you more about that later.
-->

---

# The `do-todo` Agent

<style scoped>
.smaller { font-size: 0.7em; }
</style>

A summarized version of the agent's prompt:

<div class="smaller">

1. Run `todo-get $(git rev-parse --show-toplevel)/.llm/todo.md` to get the task
2. Implement the task
3. Ignore all other tasks in the `.llm/todo.md` file or TODOs in the source code
4. When a code change is ready, and we are about to return control to the user, do these things in order:
   - Remove obvious comments using the `@comment-cleaner` agent
   - Verify the build passes using the `@precommit-runner` agent
   - Commit to git using the `@git-commit-handler` agent
   - Rebase on top of the upstream branch with the `@git-rebaser` agent
5. Run `todo-complete $(git rev-parse --show-toplevel)/.llm/todo.md` to mark the task as completed

</div>

<!--

Here's a summarized version of the `do-todo` subagent's prompt.

First, it repeats the work of finding the next incomplete task using the same `todo-get` script. The slash command does not share that context with the subagent, so the subagent has to do it again.

Second, it implements the task. It's instructed to ignore all other tasks in the todo list and any TODOs in the source code - just focus on this one thing.

Next, when a code change is ready and it's about to return control to the user, it runs a sequence of four more agents. These agents are responsible for cleaning up comments, running pre-commit checks, committing to git, and rebasing on top of the upstream branch.

Finally, it marks the task as completed using a `todo-complete` script.

The `do-todo` agent gets a single task from the todo list and implements it. It's instructed to ignore all other tasks and TODOs - just focus on this one thing. After implementing the task, it runs the same sequence of cleanup agents I showed earlier. This focused approach helps the agent succeed at each individual task.
-->

---

# Agent Hierarchy

```
/todo-all → launch the @do-todo agent... Repeat until no incomplete tasks
└── @do-todo → Implement the task... then do these things in order:
    ├── Remove obvious comments using the @comment-cleaner agent
    ├── Verify the build passes using the @precommit-runner agent
    ├── Commit to git using the @git-commit-handler agent
    └── Rebase on upstream with the @git-rebaser agent
        └── invoke the @git-rebase-conflict-resolver agent to handle merge conflicts
            └── If more conflicts arise, repeat the @git-rebase-conflict-resolver agent
```

Agents calling agents calling agents

<!--
Since we have agents calling agents, I show it here as a hierarchy.

The `/todo-all` slash command launches the `do-todo` agent repeatedly.

The `do-todo` agent implements the task, then runs four other agents in sequence: `comment-cleaner`, `precommit-runner`, `git-commit-handler`, and `git-rebaser`.

That last one, the `git-rebaser` subagent, similarly can call another subagent. It's prompt says that if during the rebase it encounters merge conflicts, it should invoke the `git-rebase-conflict-resolver` subagent. And that prompt says if more conflicts arise, call itself again recursively.

So we have agents calling agents calling agents - a deep chain of automation. Each subagent has a focused job written into its prompt, and the prompts explicitly tell agents when to delegate to other agents.
-->

---

# do-todo Agent in Action

<p align="center">

![height:450px](screenshots/do-todo-agent-execution.png)

</p>

<!--
This is the console output from one run of `/todo-all`. What you're seeing at the top level is the repeated invocations of just the `do-todo` subagent - it ran multiple times, once for each task in my todo list.

The nested subagents did run for each task, but their console output is collapsed by default.

Look at the timestamps - each task took between 2 to 10 minutes. This is just a snippet of the output; it continued on for a long time.
-->

---

# Agent Chain Execution

<p align="center">

![width:900px](screenshots/agent-chain-execution.png)

</p>

<!--
An easy way to demonstrate the nested output is to prompt Claude to complete a single task without using a subagent, either by just pasting in the text or using the same prompt as a slash command.

Here we see the sequential execution of `comment-cleaner`, `precommit-runner`, `git-commit-handler`, and `git-rebaser` subagents. At this level, we can see the individual timing of each subagent.
-->

---

# Claude Working Autonomously

<p align="center">

![width:900px](screenshots/statusline-cost-tracking.png)

</p>

<!--
This is a screenshot of my Claude Code statusline. Configuring a statusline is a topic for another day, but I have all sorts of information displayed here - token usage, costs, model being used, and session metrics.

The number circled in red is the number of minutes that Claude Code has been running since it last stopped for human interaction. This chain of todo tasks kept going for about 70 minutes without needing any input from me.

This is the game we play these days: we try to get Claude Code to run for as long as possible without human interaction, within the constraints of the 200,000 token context window. Agents are a key tool for achieving these long autonomous runs - they keep the main context clean while Claude works through complex multi-step tasks. This concept is called context management.
-->

---

# Screenshot: Context Usage Display

<p align="center">

![width:1000px](screenshots/context-usage-display.png)

</p>

<!--
Shows Claude Code's context usage breakdown - system prompt, tools, agents, messages, and free space. Illustrates context management benefits.
-->

---

# Agents Combine Many Features

1. **Context management** - Separate context window
2. **Persistent prompts** - Don't repeat instructions
3. **Automatic triggering** - Based on description
4. **Model switching** - Use Sonnet for simple tasks
5. **Tool restrictions** - Limit what each agent can do

These used to require separate features (tasks, prompts, etc.)

<!--
When subagents were new, I knew that Anthropic built the feature for a reason that wasn't obvious, so I dug in until I found a way to be productive with them. I found that they are more powerful than previous features (like slash commands and MCP) for context management, and that if you use them effectively you can get Claude Code to work independently for longer durations before it requires human involvement again.

Agents combine a bunch of features that are useful. The task tool was a precursor - you could run things in parallel with separate context. But agents add persistent prompts, triggering, model switching, and tool restrictions all in one package.
-->

---

# Thank you

## Questions?

---

# What are sub-agents for?

I just showed what I use sub-agents for, but what are they for in general? What does Anthropic say they're for?

- Anthropic docs are vague: "specialized AI subagents for task-specific workflows"
- They sound like a generic tool for anything in agentic mode
- But what does that even mean?
- The documentation doesn't provide clear guidance

<!--
I just showed what I use sub-agents for - my todo workflow and side quests. But what are they for in general? What does Anthropic say they're for? The docs are kind of vague - they describe them as "specialized AI subagents for task-specific workflows", which sounds like a generic tool for anything in agentic mode. But what does that even mean? The documentation doesn't really provide clear guidance on when to use them.
-->

---

# Anthropic's Documentation

Example agents:
- Code reviewer: "senior code reviewer"
- Debugger: "expert debugger"
- Data scientist: "data scientist"

Personification:
- Anthropic uses personification patterns
- Not clear why sub-agents are needed for these roles
- Seems like regular prompting would work

<!--
Anthropic's examples include code reviewer, debugger, data scientist. They use this personification pattern - "you are a senior code reviewer". This personification approach seems unnecessary. It wasn't clear why sub-agents would be needed for code review or debugging rather than just regular prompting.
-->

---

# What Are Subagents Good For?

## 1. Context Management
- **Problem**: Simple commands → Huge console output → Context pollution
- **Solution**: Separate context windows for each agent
- **Result**: Work longer without compacting

## 2. Working Independently
- Claude Code works for longer durations
- Less frequent human involvement needed
- Parallel task execution

**Example**: Test runner output stays in agent's context, not main window

<!--
Claude Code's subagents are good for two main things: First, context management - they help you avoid context pollution and work longer without needing to compact your conversation. Second, they enable Claude Code to work more independently for longer durations before it requires human involvement again.

The main advantage is context management. Especially the test runner - it's a simple command but the console output is huge. That would all wind up in the context. With agents, I can work a lot longer without compacting. When you compact, sometimes you can continue, sometimes Claude gets really disoriented.
-->

---

# Agent File Structure

```markdown
---
name: your-agent-name
description: When this agent should be invoked
tools: tool1, tool2, tool3  # Optional
---

Your agent's system prompt goes here.
Include specific instructions and constraints.
```

---

# Agent File Locations

| Type | Location | Scope |
|------|----------|-------|
| **Project** | `.claude/agents/` | Current project only |
| **User** | `~/.claude/agents/` | All projects |

Project agents take precedence over user agents

---
