# Perl2Py


## ⚠️ Warning

- Keep track of your token and budget usage by regularly checking the details via the "Usage details" button on workflow-executions page after step 13.
- Project integration and workflow should be created within the same "project". It is recommended to name the project after your specific use case (e.g., "example@email.com").
  A project property is a special attribute in EPAM AI/Run™ for AWS , created by the admin. Each user has their own project, which is automatically named based on their email address


1. Create folder scratchpad on C disk for example "C:\scratchpad"
2. Install Python 3.12 or higher
4. Install uvx
4. Install Node.js 22 or higher
5. Run command for install codemie-plugins
```bash
  pip install codemie-plugins
```

6. Define default MCP servers and connection to nats catalogue at ```<user_home_directory>\.codemie\config.json``` file
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
7. Check list of availability MCP server. Should be present "filesystem_ext" and "tree_sitter"
```bash
  codemie-plugins mcp list
```
8. Create in scratchpad file ```Perl2Py```
9. Create next three sub folder in Perl2Py: ```airun```, ```Perl```, ```Python```
10. Create plugin project integration on EPAM AI/Run™ for AWS  with value from config.json files using PLUGIN_KEY
11. Add ```00bootstrap.json``` files with next values
```
 {
   "project_base": "<path_to>\Perl2Py",
   "perl_dir": "<path_to>\Perl2Py\Perl",  
   "python_dir": "<path_to>\Perl2Py\Python"
 }
```
12. Run MCP servers and codemie-plugins
    For MacOS & Linux
```bash
  cd /scratchpad/Perl2Py
  export ALLOWED_DIR=/scratchpad/Perl2Py
  export FILE_PATHS=/scratchpad/Perl2Py
  export ALLOWED_DIRS=/scratchpad/Perl2Py
  export PROJECT_BOOTSTRAP=/scratchpad/Perl2Py/airun
  codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server,tree_sitter -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
For Windows
```bash
  cd C:\scratchpad\Perl2Py
  set ALLOWED_DIR=C:\scratchpad\Perl2Py
  set ALLOWED_DIRS=C:\scratchpad\Perl2Py
  set FILE_PATHS=C:\scratchpad\Perl2Py
  set PROJECT_BOOTSTRAP=C:\scratchpad\Perl2Py\airun
  codemie-plugins config list
  codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server,tree_sitter -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
13. Left your perl project into ```Perl``` folder
14. Go to Workflows templates
15. Find and create ```Perl2Python: fully automated conversion``` workflow
16. Go to Workflows and run ```Perl2Python: fully automated conversion``` workflow
17. Wait util workflow done
18. Result you can find ```~\scratchpad\Perl2Py\Python```
