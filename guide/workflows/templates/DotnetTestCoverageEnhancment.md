# .NET Test Coverage Enhancement

Unit tests can be generated using two efficient methods flow by flow or one general flow for full proces

1. Using flow by flow you can see what happen every iteration and can affect on any stage
2. Using only one flow you can provide all necessary data and config one time and you can get your output


# Step for run
1. Install Python 3.12 or higher
2. Install uvx
3. Install Node.js 22 or higher
4. Run command for install codemie-plugins
```bash
  uvx pip install codemie-plugins
```
5. Define default folders and connection to nats catalogue
```
 {
  "PLUGIN_KEY": "<Any value>",
  "PLUGIN_ENGINE_URI": "tls://codemie-nats.<url>:30422",
  "FILE_PATHS": "c:\\scratchpad",
  "ALLOWED_DIRS": "c:\\scratchpad",
  "ALLOWED_DIR": "c:\\scratchpad",
  "PROJECT_BOOTSTRAP": "C:/scratchpad/proba/airun",
  "tree_sitter": {
      "command": "uvx",
      "args": [
        "--index-url",
        "https://nexus-ci.core.kuberocketci.io/repository/krci-python-group/simple/",
        "--from",
        "mcp-server-tree-sitter-extra",
        "mcp-server-tree-sitter-extra"
      ]
   },
  "filesystem_ext": {
  "command": "uvx",
  "args": [
    "--index-url",
    "https://nexus-ci.core.kuberocketci.io/repository/krci-python-group/simple/",
    "--from",
    "mcp-filesystem-extra",
    "mcp-filesystem-extra"
    ]
   },
  "cli-mcp": {
  "command": "uvx",
  "args": [
    "--index-url",
    "https://nexus-ci.core.kuberocketci.io/repository/krci-python-group/simple/",
    "--from",
    "cli-mcp-server",
    "cli-mcp-server"
    ]
   } 
}
   ```
6. Check list of availability MCP server. Should be present "filesystem_ext", "cli-mcp-server" and "tree_sitter"
```bash
  codemie-plugins mcp list
```
7. Update plugin project integration on AI/Run™ for AWS with value from config.json files using PLUGIN_KEY
8. Create folder in scratchpad: ```airun``` in root of your project,
9. Add ```00bootstrap.json``` files with next values in ```airun```
```
 {
  "project_base": "absolute_path_to_your_project",  
 }
```
10. Run MCP servers and codemie-plugins
    For MacOS & Linux
```bash
  export PROJECT_BOOTSTRAP=/<absolute_path_to_your_project>/airun
  codemie-plugins config list
  codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
For Windows
```bash
  set PROJECT_BOOTSTRAP= <absolute_path_to_your_project>\airun
  poetry run codemie-plugins config list
  poetry run codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
11. Go to Workflows and run ```DOTNET: fully automated test generation``` workflow
12. Wait util workflow done
13. Path to result you can find in ```<project_base>/airun/00project-info.json```


If you want to run the flow step by step, you can do so, but you'll need to follow the previous instructions up to step 11

Order of workflow:
- DOTNET: project discovery
- DOTNET: sources triage
- DOTNET: coverage analyzer
- DOTNET: test writer