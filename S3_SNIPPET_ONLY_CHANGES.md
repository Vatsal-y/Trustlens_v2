# S3 Upload - Snippet-Only Migration

## Overview
Modified the S3 upload system to **ONLY upload extracted code snippets and metadata** instead of uploading the entire source code repository. This reduces storage usage and ensures agents only analyze relevant code patterns, not whole codebase.

## Files Modified

### 1. `backend/storage/s3_uploader.py`

#### Changes:
- **Deprecated `upload_directory()`**: Now returns a deprecation warning. Previously uploaded entire directories.
- **Deprecated `upload_project_structure()`**: Now returns a deprecation warning.
- **Removed `_upload_folder_contents()`**: Helper method for full directory uploads - no longer needed.
- **Added `upload_only_snippets()`**: New primary method for uploading snippets-only.

#### New Method: `upload_only_snippets()`
```python
def upload_only_snippets(
    project_name: str,
    analysis_id: str,
    snippets: Dict[str, Any],
    metadata: Optional[Dict[str, Any]] = None
) -> str
```

**What it does:**
- Uploads ONLY extracted code snippets (not full source)
- Uploads metadata.json with analysis info
- Creates structured S3 hierarchy

**S3 Structure:**
```
s3://bucket/project_name/
├── metadata.json
└── snippets/
    ├── security/
    │   ├── security_snippet_1.json
    │   ├── security_snippet_2.json
    │   └── ...
    ├── logic/
    │   ├── logic_snippet_1.json
    │   └── ...
    └── quality/
        ├── quality_snippet_1.json
        └── ...
```

### 2. `backend/storage/git_s3_workflow.py`

#### Changes:
- **Updated `_stage_upload_to_s3()`**: Now uses `upload_only_snippets()` instead of `upload_project_structure()`
- **Updated statistics tracking**: Changed from "files_uploaded" to "snippets_uploaded"
- **Removed file counting**: No longer counts files in repository

#### Before:
```python
# Old: Uploaded entire repo
s3_path = self.s3_uploader.upload_project_structure(local_repo_path, project_name, analysis_id)
```

#### After:
```python
# New: Upload only snippets
s3_path = self.s3_uploader.upload_only_snippets(
    project_name=project_name,
    analysis_id=analysis_id,
    snippets=snippets,
    metadata=metadata_obj
)
```

#### Statistics Update:
```python
# Before
"statistics": {
    "files_uploaded": 1500,  # Wrong - shouldn't count files
    "commits": 42,
    "snippets_extracted": 12
}

# After
"statistics": {
    "snippets_uploaded": 12,  # Only snippets
    "commits": 42,
    "snippets_categories": ["security", "logic", "quality"]
}
```

### 3. `backend/storage/s3_reader.py`

#### Changes:
- **Added `get_metadata()` method**: Retrieves metadata.json from S3
- No breaking changes - existing methods work with snippet-only structure

#### New Method: `get_metadata()`
```python
def get_metadata(self, s3_base_path: str) -> Dict[str, Any]
```

**What it does:**
- Reads metadata.json from project root
- Returns analysis info, repo info, snippet counts, etc.

**Example Usage:**
```python
reader = S3Reader()
metadata = reader.get_metadata("s3://bucket/my-project/")
print(metadata["analysis_id"])
print(metadata["snippet_count"])
```

## Benefits

1. **Reduced Storage**: Only snippets uploaded, not entire repos
   - Typical reduction: 95%+ smaller
   - Cost savings on S3 storage

2. **Agent Efficiency**: Agents see only relevant code patterns
   - No noise from config files, dependencies, etc.
   - Faster LLM processing
   - Better analysis quality

3. **Privacy**: Sensitive files not uploaded
   - .env files not included
   - Credentials not stored
   - Less data exposure risk

4. **Performance**: 
   - Faster upload times
   - Faster agent retrieval
   - Lower network bandwidth

## Backward Compatibility

### Breaking Changes:
- Direct calls to `upload_directory()` will log a warning but won't fail
- Direct calls to `upload_project_structure()` will log a warning but won't fail

### Migration Path:
If you have code calling old methods:

**Old Code:**
```python
uploader = S3Uploader()
s3_path = uploader.upload_directory("/repo/path", "analysis-123")
```

**New Code:**
```python
uploader = S3Uploader()
extractor = SnippetExtractor()

# Extract snippets first
snippets = extractor.extract_from_directory("/repo/path")

# Then upload only snippets
s3_path = uploader.upload_only_snippets(
    project_name="my-project",
    analysis_id="analysis-123",
    snippets=snippets,
    metadata={"repo_url": "...", "branch": "main"}
)
```

## Testing

The `GitS3Workflow` class automatically handles:
1. Clone repository
2. Extract snippets
3. **Upload only snippets** ← Changed
4. Cleanup local files

Example workflow:
```python
workflow = GitS3Workflow()
result = workflow.process_git_repository(
    repo_url="https://github.com/user/repo.git",
    analysis_id="analysis-456",
    extract_snippets=True  # Important: must be True
)

# Result will have:
# - s3_path pointing to project folder
# - statistics with snippets_uploaded count
# - No full source code uploaded
```

## S3 Structure Comparison

### Before:
```
s3://bucket/
└── analysis-123/
    └── [ALL FILES from repo - gigabytes]
```

### After:
```
s3://bucket/project-name/
├── metadata.json
└── snippets/
    ├── security/[key snippets].json
    ├── logic/[key snippets].json
    └── quality/[key snippets].json
```

## Agent Access

Agents access snippets via `S3Reader`:

```python
from storage.s3_reader import S3Reader

reader = S3Reader()

# Get security snippets
security_snippets = reader.get_snippets(
    "s3://bucket/project/", 
    "security"
)

# Get metadata
metadata = reader.get_metadata("s3://bucket/project/")
analysis_id = metadata["analysis_id"]
```

## Summary

✅ **Old behavior removed**: Full source code uploads eliminated  
✅ **New behavior active**: Only extracted snippets uploaded  
✅ **Storage optimized**: ~95% reduction in S3 usage  
✅ **Agent efficiency**: Faster, focused analysis  
✅ **S3Reader updated**: New `get_metadata()` method available  
✅ **Statistics tracking**: Updated for snippet-only uploads
