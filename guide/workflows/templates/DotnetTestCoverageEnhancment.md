# .NET Test Coverage Enhancement

Unit tests can be generated using two efficient methods flow by flow or one general flow for full proces

1. Using flow by flow you can see what happen every iteration and can affect on any stage
2. Using only one flow you can provide all necessary data and config one time, and you can get your output

## ⚠️ Warning

- Keep track of your token and budget usage by regularly checking the details via the "Usage details" button on workflow-executions page after step 13.
- Project integration and workflow should be created within the same "project". It is recommended to name the project after your specific use case (e.g., "example@email.com").
  A project property is a special attribute in EPAM AI/Run™ for AWS , created by the admin. Each user has their own project, which is automatically named based on their email address



# Step for run
1. Install Python 3.12 or higher
2. Install uvx
3. Install Node.js 22 or higher
4. Run command for install codemie-plugins
```bash
  pip install codemie-plugins
```
5. Define default MCP servers and connection to nats catalogue at ```<user_home_directory>\.codemie\config.json``` file
```
 {
  "PLUGIN_KEY": "<Any value>",
  "PLUGIN_ENGINE_URI": "tls://codemie-nats.<url>:30422",
  "mcpServers": {
    "filesystem_ext": {
      "command": "uvx",
      "args": [
        "--from",
        "mcp-filesystem-extra",
        "filesystem-extra"
        ]
    },
    "tree_sitter": {
      "command": "uvx",
      "args": [
        "--from",
        "mcp-server-tree-sitter-extra",
        "mcp-server-tree-sitter"
        ]
    }
  }
 } 
   ```
6. Check list of availability MCP server. Should be present "filesystem_ext" and "tree_sitter"
```bash
  codemie-plugins mcp list
```
7. Create plugin project integration on EPAM AI/Run™ for AWS  with value from config.json files using PLUGIN_KEY
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
  cd <absolute_path_to_your_project>
  export PROJECT_BOOTSTRAP=/<absolute_path_to_your_project>/airun
  export ALLOWED_DIRS=/<absolute_path_to_your_project>
  export FILE_PATHS=/<absolute_path_to_your_project>
  export ALLOWED_DIR=/<absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
For Windows
```bash
  cd <absolute_path_to_your_project>
  set PROJECT_BOOTSTRAP= <absolute_path_to_your_project>\airun
  set ALLOWED_DIRS=<absolute_path_to_your_project>
  set FILE_PATHS=<absolute_path_to_your_project>
  set ALLOWED_DIR=<absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
11. Go to Workflows templates
12. Find and create ```DOTNET: fully automated test generation``` workflow
13. Run the workflow
14. Wait util workflow done
15. Path to result you can find in ```<project_base>/airun/00project-info.json```


If you want to run the flow step by step, you can do so, but you'll need to follow the previous instructions up to step 11
After it, you need create next workflow from template and run the workflow  

Order of workflow:
- DOTNET: project discovery
- DOTNET: sources triage
- DOTNET: coverage analyzer
- DOTNET: test writer