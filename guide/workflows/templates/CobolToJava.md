# Prerequisites

## Filesystem preparation

- It is recommended to start with a new folder for the conversion project. Select and create a <project_base> folder on disk.
- Create the following folders inside <project_base>. airun - AI workspace  (mf_reports - folder for reports from AI/RUN MFLens application - add reports to this folder (Guide on how to download these reports is included in the workflow demo showcase video)
- Workflow requires bash on your local machine to run properly.
- Add nhrun and nhcheck scripts (requires bash to run) in /usr/local/bin or similar directory from $PATH environment variable.

## AI/RUN CodeMie preparation
- Set Plugin and Jira integrations

## Running MCP servers
For properly executing the conversion, the following MCP servers are required:

- filesystem
- filesystem_ext
- cli-mcp-server


Run plugins and give them access to the project tree:
- Set environment variables pointing to root of your project: ALLOWED_DIR, FILE_PATHS
- Set environment variables pointing to project_root/airun directory: PROJECT_BOOTSTRAP
- Run plugin: codemie-plugins mcp run -s filesystem -e filesystem=FILE_PATHS
- Run plugin: codemie-plugins mcp run -s filesystem_ext -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
- Run plugin: codemie-plugins mcp run -s cli-mcp-server -e cli-mcp-server=ALLOWED_DIR

Here is an example for properly configuring and running MCP servers:

```bash
set ALLOWED_DIR=C:\<project_base>
set FILE_PATHS=C:\<project_base>
set PROJECT_BOOTSTRAP=C:\<project_base>\airun
codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server -e filesystem=FILE_PATHS -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```

## Conversion process:
- All AI/RUN MFLens reports in the airun/mf_reports/ folder are analyzed, and the application is summarized in airun/analysis.md.
- A conversion plan is created and saved in airun/migration_plan.json.
- Detailed descriptions for each migration step from the plan are created and saved in airun/plan_details/{step_id}.md.
- The conversion is run based on these steps, and Java application files are saved in the airun/app/ folder.
- Validation results and issues are documented in airun/validate_log.md.

## Post-conversion process:
- If any issues are found (such as compilation errors, missing implementations, or TODOs), a dedicated "fix" step is triggered.
- During the "fix" step, the issues listed in airun/validate_log.md are addressed, and the code is retested until all problems are resolved and the application builds and tests pass.
- If the result looks plausible - start functional testing of the converted application
