# Feature Extraction Agent Documentation

## 1. Input & Callers
*   **Called By**: `Orchestrator.analyze_repository` (in `backend/orchestrator/orchestrator.py`).
*   **Unique Role**: This is the **FIRST** agent to run.
*   **Input Data**: `code_files` (Dict[str, str]). This agent sees the **ENTIRE** codebase (file paths and contents).
*   **Who Feeds It**: The `Orchestrator` passes the raw code dictionary directly after reading it from S3.
*   **Restrictions**: NO LLM access. Must only perform fast, static analysis.

## 2. Internals & Logic
*   **Core Logic**: Pure Python string manipulation and regex.
*   **Logic Flow**:
    1.  **Iterate Files**: Loops through every file in the dictionary.
    2.  **Line Counting**: Counts total lines (`total_loc`) and non-empty lines.
    3.  **Language Detection**: Identifies language based on file extension (e.g., `.py`, `.js`).
    4.  **Complexity Scans**:
        *   Counts indentation to estimate `nesting_depth`.
        *   Counts keywords like `def`, `class`, `function` to estimate structure.
    5.  **Long File Detection**: Flags files > 200 lines.

## 3. The LLM Call (Detail)
**NONE**. This agent is strictly deterministic and does not use the LLM.

## 4. Confidence Calculation
*   **Value**: Always **1.0**.
*   **Reasoning**: Counting lines and checking file extensions is mathematically precise. There is no ambiguity or probability involved.

## 5. Output
Returns an `AgentOutput` object containing:
*   `agent_type`: `FEATURE_EXTRACTION`
*   `confidence`: `1.0`
*   `findings`: Summary stats (e.g., "Identified core logic in PYTHON (12 files)").
*   `risk_level`: `NONE` (It describes code, doesn't judge it).
*   `metadata`: The full `features` dictionary used by other agents (containing nesting maps, file counts, etc.).
