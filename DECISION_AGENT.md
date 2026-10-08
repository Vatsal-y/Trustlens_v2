# Decision Agent Documentation

## 1. Input & Callers
*   **Called By**: `Orchestrator.analyze_repository` (in `backend/orchestrator/orchestrator.py`)
*   **Unique Role**: This is the **FINAL** agent to run. It synthesizes all other agent outputs.
*   **Input Data**:
    *   `agent_outputs`: List of `AgentOutput` objects from all expert agents (Security, Logic, Quality).
    *   `overall_confidence`: Aggregated confidence score (weighted mean from `ReliabilityEngine`).
    *   `conflicts`: List of detected conflicts between agents (from `ConflictResolver`).
*   **Who Feeds It**: The `Orchestrator` collects all outputs and passes them to the Decision Agent.

## 2. Internals & Logic
*   **Core Logic**: Deterministic rule-based decision making (NO LLM).
*   **Logic Flow**:
    1.  **Risk Identification**: Scans all successful agent outputs to find the **highest risk level**.
        *   Priority: `CRITICAL > HIGH > MEDIUM > LOW > NONE`
    2.  **Action Mapping**: Maps the max risk to a recommendation:
        *   `CRITICAL` → `manual_review_required`
        *   `HIGH` → `review_required`
        *   `MEDIUM` → `proceed_with_caution`
        *   `LOW/NONE` → `acceptable`
    3.  **Decision Confidence Calculation**: Applies conflict penalties to the overall confidence.

## 3. The LLM Call (Detail)
**NONE**. This agent uses pure logic and does not call the LLM.

## 4. Confidence Calculation
*   **Formula**: `Decision Confidence = Overall Confidence - Penalty`
*   **Penalty Calculation**:
    *   Base penalty: `0.2` per conflict
    *   Each conflict has a `disagreement_level` (0.0-1.0) that scales the penalty
    *   Maximum total penalty: `0.5` (capped)
*   **Example**: 
    *   Overall confidence: `0.85`
    *   2 conflicts detected
    *   Penalty: `0.2 × 2 = 0.4`
    *   Final: `0.85 - 0.4 = 0.45`

## 5. Output
Returns an `AgentOutput` object containing:
*   `agent_type`: `DECISION`
*   `confidence`: Decision confidence (after conflict penalties).
*   `findings`: Contains the recommendation (e.g., `{"recommendation": "review_required"}`).
*   `risk_level`: The maximum risk level found across all agents.
*   `metadata`: Includes:
    *   `recommendation`: The action string
    *   `decision_confidence`: The calculated confidence
    *   `agent_traces`: Full trace of all agent outputs for explainability
