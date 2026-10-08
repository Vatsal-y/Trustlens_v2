# Code Quality Agent Documentation

## 1. Input & Callers
*   **Called By**: `Orchestrator._run_analysis_agents` (in `backend/orchestrator/orchestrator.py`)
*   **Input Data**: `metrics` (Dict[str, Any]). This is a dictionary of **pre-calculated metrics only** - NO raw code.
*   **Who Feeds It**: The `RoutingPolicy.route_for_quality_agent()` extracts metrics from the features dictionary.
*   **Restrictions**: 
    *   **CANNOT** see raw code or snippets.
    *   **CANNOT** use the LLM.
    *   Advisory only - findings do NOT block deployment.

## 2. Internals & Logic
*   **Core Logic**: Pure Python arithmetic and threshold comparisons.
*   **Logic Flow**:
    1.  **Validation**: Checks that it received metrics, not code (safety check).
    2.  **Threshold Checks**: Compares metrics against hardcoded thresholds:
        *   Max function length: 50 lines
        *   Max file length: 500 lines
        *   Min comment ratio: 0.1
        *   Max complexity (nesting): 10
    3.  **Finding Generation**: Creates advisory findings for violations (e.g., "File exceeds 200 lines").

## 3. The LLM Call (Detail)
**NONE**. This agent is strictly deterministic and metric-based.

## 4. Confidence Calculation
*   **Value**: Always **0.9**.
*   **Reasoning**: Metrics are deterministic (counting lines is exact), but the agent uses `0.9` instead of `1.0` because:
    *   Quality thresholds are somewhat subjective.
    *   It's advisory-only, so it signals "high confidence in the measurement, but not critical".

## 5. Output
Returns an `AgentOutput` object containing:
*   `agent_type`: `CODE_QUALITY`
*   `confidence`: `0.9`
*   `findings`: List of quality issues (e.g., "Deep nesting detected (depth 6)").
*   `risk_level`: Always `LOW` (quality issues don't block deployment).
*   `metadata`: Contains `advisory: True` and `blocking: False` flags.
