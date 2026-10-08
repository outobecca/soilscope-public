# SKILL: MFCKT AI Lens & Human Interaction

This document guides an LLM (Large Language Model) on how to use the `mcfkt` graph interface and how to communicate with human users through the MFCKT platform.

## 1. Using the `mcfkt` App (Graph Interface)

The `mcfkt` app provides a graph-based view of the codebase and data. Instead of traditional file-based reading, use the following tools to navigate and understand the system efficiently.

### AI Orchestration Model
- **Gemma (Local)**: Your primary source for node analysis and fast searches. Use it for "what does this do?" type queries.
- **Gemini (Cloud)**: Used for high-level reasoning, complex architecture reviews, and proposing large-scale changes. Gemini receives "pruned" context from the local graph to stay within token limits.

### Core Tools

#### `Search(query, limit)`
Semantically searches the graph using vector embeddings. Use this when looking for features without knowing their exact location.

#### `Trace(node_id, direction)`
Follows the code path (lineage) upstream (callers) or downstream (dependencies).

#### `Summarize(cluster_id)`
Uses the local model to provide a technical summary of an entire module or cluster of nodes.

#### `ContextPruning(target_node_id, token_budget)`
Removes boilerplate and irrelevant nodes from the graph before passing the context to a larger model. This is essential for maintaining a high signal-to-noise ratio.

#### `AnomalyDetection()`
Compares the current graph structure against historical states to identify logical inconsistencies or architectural drifts.

#### `AgentPipelineExecute(proposed_patch, affected_nodes)`
Proposes code changes. It returns `SUCCESS` only if the change passes AST validation and compilation. Use `ProposeChange` through Gemini to generate these patches.

## 2. Communicating with Humans

Interaction with human counterparts in MFCKT happens through specialized "Bridges" and "Lenses."

### AI-Bridge & Contextual Help
When a user requests help (e.g., clicking the "Contextual Help (?)" button):
1. **Context Acquisition**: You will receive a payload containing the user's current view (Active Tags), the specific Card they are looking at, and their current system telemetry (excluding cognitive load metrics).
2. **Response Generation**: Provide analytical, direct, and technically grounded answers. Align your tone with the "Scientific Blueprint" aesthetic—professional and concise.
3. **Generative UI Support**: If appropriate, you can generate JSON-defined UI nodes to present information or options to the user directly within their Generative Canvas.

### The Chairman Role
In group or collaborative contexts, an AI agent can take the "Chairman" role:
- **Moderation**: Summarize technical discussions.
- **Validation**: Check proposed actions against the system's "Master Specification" and architectural integrity.
- **Conflict Resolution**: Identify where proposed changes might violate architectural standards or introduce regressions.

### Communication Guidelines
- **Precision**: Use the "Lens System" terminology (Macro, Meso, Micro, Atomic) to describe the scope of your information.
- **Brevity**: Avoid conversational filler. Focus on high-signal data and technical rationale.
- **Transparency**: If an action is rejected by the `AgentPipelineExecute`, explain the specific validation failure (e.g., syntax error, broken dependency) to the user.
