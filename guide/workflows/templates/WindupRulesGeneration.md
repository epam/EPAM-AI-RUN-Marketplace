# Windup Rules Generation Workflow


# Step for run
1. Install Python 3.12 or higher
2. Install Node.js 22 or higher
3. Run command for install codemie-plugins
```bash
  pip install codemie-plugins
```
4. Create ```scratchpad``` folder in root of your system 
5. Move copy of your project into ```scratchpad```
6. Create folder in root folder of your project: ```airun``` 
7. Add ```00bootstrap.json``` files with next values in ```airun```
```
 {
  "project_base": "absolute_path_to_your_project",  
 }
```
8. Create ```.codemie``` folder at ```<user_home_directory>``` folder 
9. Create ```config.json``` file at ```<user_home_directory>\.codemie``` folder
10. Define accesses  folders and connection to nats catalogue at ```<user_home_directory>\.codemie\config.json``` file
```
 {
  "PLUGIN_KEY": "<Any value>",
  "PLUGIN_ENGINE_URI": "tls://codemie-nats.<url>:30422",
  "FILE_PATHS": "<root_of_your_system>\\scratchpad\\<folder_name_of_your_project>",
  "ALLOWED_DIRS": "<root_of_your_system>\\scratchpad\\<folder_name_of_your_project>",
  "ALLOWED_DIR": "<root_of_your_system>\\scratchpad\\<folder_name_of_your_project>",
  "PROJECT_BOOTSTRAP": "<root_of_your_system>\\scratchpad\\proba\\airun",
  "mcpServers": {
   "tree_sitter": {
      "command": "uvx",
      "args": [
        "--index-url",
        "https://nexus-ci.core.kuberocketci.io/repository/krci-python-group/simple/",
        "--from",
        "mcp-server-tree-sitter-extra",
        "mcp-server-tree-sitter"
        ]
    },
  "filesystem_ext": {
  "command": "uvx",
  "args": [
    "--index-url",
    "https://nexus-ci.core.kuberocketci.io/repository/krci-python-group/simple/",
    "--from",
    "mcp-filesystem-extra",
    "filesystem-extra"
    ]
   }
 }
}
   ```
11. Check list of availability MCP server. Should be present "filesystem_ext", "cli-mcp-server" and "tree_sitter"
```bash
  codemie-plugins mcp list
```
12. Update plugin project integration on AI/Run™ with value from config.json files using PLUGIN_KEY

13. Run MCP servers and codemie-plugins
    For MacOS & Linux
```bash
  cd <absolute_path_to_your_project>
  export PROJECT_BOOTSTRAP=/<absolute_path_to_your_project>/airun
  export FILE_PATHS = <absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem,filesystem_ext -e filesystem=FILE_PATHS -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
For Windows
```bash
  cd <absolute_path_to_your_project>
  set PROJECT_BOOTSTRAP = <absolute_path_to_your_project>\airun
  set FILE_PATHS = <absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem,filesystem-extra -e filesystem=FILE_PATHS -e filesystem-extra=ALLOWED_DIR,PROJECT_BOOTSTRAP
```

14. Go to Workflows templates and find ```Windup Rules Generation Workflow``` template
15. Share workflow with project
16. Run the workflow with a prompt that specifies what you want to migrate. For example: ```I want to migrate from Spring Boot 2 to Spring Boot 3```, ```I want to migrate from Java 8 to Java 17```...
17. Wait util workflow done
18. Result you can find at ```<project_base>/airun```

