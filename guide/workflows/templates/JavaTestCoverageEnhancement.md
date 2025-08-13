# Java Test Coverage Enhancement

Unit tests can be generated using two efficient methods flow by flow or one general flow for full proces 

1. Using flow by flow you can see what happen every iteration and can affect on any stage 
2. Using only one flow you can provide all necessary data and config one time and you can get your output 


# Step for run
1. Create folder scratchpad on C disk for example "C:\scratchpad"
2. Install Python 3.12 or higher
4. Install uvx
4. Install Node.js 22 or higher
5. Run command for install codemie-plugins
```bash
  uvx pip install codemie-plugins
```
6. Define default folders and connection to nats catalogue
```
 {
  "PLUGIN_KEY": "<Any value>",
  "PLUGIN_ENGINE_URI": "tls://codemie-nats.<url>:30422",
  "FILE_PATHS": "c:\\scratchpad",
  "ALLOWED_DIRS": "c:\\scratchpad",
  "ALLOWED_DIR": "c:\\scratchpad",
  "PROJECT_BOOTSTRAP": "C:/scratchpad/proba/airun"
 }
   ```
7. Check list of availability MCP server. Should be present "filesystem_ext", "cli-mcp-server" and "tree_sitter"
```bash
  codemie-plugins mcp list
```
8. Update plugin project integration on CodeMie with value from config.json files using PLUGIN_KEY
9. Create folder in scratchpad: ```airun```,
9. Add ```00bootstrap.json``` files with next values
```
 {
  "project_base": "absolute_path_to_your_project",  
 }
```
10. Run MCP servers and codemie-plugins
    For MacOS & Linux
```bash
  export ALLOWED_DIR=/scratchpad/proba
  export FILE_PATHS=/scratchpad/proba
  export PROJECT_BOOTSTRAP=/scratchpad/proba/airun
  codemie-plugins config list
  codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
For Windows
```bash
set ALLOWED_DIR=C:\scratchpad\proba
set FILE_PATHS=C:\scratchpad\proba
set PROJECT_BOOTSTRAP=C:\scratchpad\proba\airun
poetry run codemie-plugins config list
poetry run codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
14. Go to Workflows and run ```JUNIT: fully automated test generation``` workflow
15. Wait util workflow done
16. Result you can find in ```~scratchpad\proba file```


If you want to run the flow step by step, you can do so, but you'll need to follow the previous instructions up to step 14

Order of workflow:
- JUNIT: project discovery
- JUNIT: sources triage
- JUNIT: coverage analyzer
- JUNIT: test writer
- JUNIT: fully automated test generation