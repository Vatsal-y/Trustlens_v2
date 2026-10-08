# Logic Analysis Agent Documentation

## 1. Input & Callers
*   **Called By**: `Orchestrator._run_analysis_agents` (in `backend/orchestrator/orchestrator.py`)
*   **Input Data**:
    *   `features`: A dictionary of logic-related features (e.g., nesting depth, complexity).
    *   `snippets`: A list of `CodeSnippet` objects (max 3). These contain complex control flow code.
*   **Who Feeds It**: The `RoutingPolicy` filters for loops, recursion, and deep nesting, then passes these to the Orchestrator.
*   **Restrictions**: Strictly FORBIDDEN from seeing security-sensitive snippets (SQL, Auth).

## 2. Internals & Logic
*   **Core Library**: `google.generativeai` (via `GeminiClient` wrapper).
*   **Logic Flow**:
    1.  **Safety Check**: Scan tags to ensure no security snippets were accidentally routed here.
    2.  **LLM Call**: Calls `GeminiClient.generate()` for each snippet.
    3.  **Prompt Strategy**: "Analyze this code for LOGIC CORRECTNESS ONLY." Checks for infinite loops, off-by-one errors, unreachable code.
    4.  **Parsing**: Expects JSON with `findings` and `confidence`.

## 3. The LLM Call (Detail)
The agent constructs a prompt like this:
```text
Analyze this code for LOGIC CORRECTNESS ONLY.
Location: {filename}:{line}
Context: {nesting depth, etc}

Code:
{snippet content}

Check for:
1. Infinite loops
2. Unreachable code
3. Logic contradictions
...

Return JSON:
{
    "findings": [{"issue": "Infinite Loop", ...}],
    "confidence": 0.0-1.0
}
```
The LLM evaluates the correctness of the algorithms and control structures.

## 4. Confidence Calculation
*   **Source**: Elicited from the LLM in the `confidence` field.
*   **Aggregation**: **Averages** the confidence scores from all analyzed snippets.
*   **Fallback**: Defaults to `0.6` if the LLM response is malformed.

## 5. Output
Returns an `AgentOutput` object containing:
*   `agent_type`: `LOGIC_ANALYSIS`
*   `confidence`: (Float 0.0-1.0).
*   `findings`: List of logic errors (e.g., "Potential infinite loop in `process_data`").
*   `risk_level`: Maps logic issues to risk (e.g., Infinite Loop = `HIGH`, Off-by-one = `MEDIUM`).
