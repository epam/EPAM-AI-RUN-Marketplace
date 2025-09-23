# Windup Rules Generation Workflow

## ⚠️ Warning

- Keep track of your token and budget usage by regularly checking the details via the "Usage details" button on workflow-executions page after step 13.
- Project integration and workflow should be created within the same "project". It is recommended to name the project after your specific use case (e.g., "example@email.com").
  A project property is a special attribute in EPAM AI/Run™ for AWS , created by the admin. Each user has their own project, which is automatically named based on their email address

# Step for run
1. Install Python 3.12 or higher
2. Install Node.js 22 or higher
3. Install uvx
4. Run command for install codemie-plugins
```bash
  pip install codemie-plugins
```
5. Create folder in root folder of your project: ```airun``` 
6. Add ```00bootstrap.json``` files with next values in ```airun```
```
 {
  "project_base": "absolute_path_to_your_project",  
 }
```
7. Create ```.codemie``` folder at ```<user_home_directory>``` folder 
8. Create ```config.json``` file at ```<user_home_directory>\.codemie``` folder
9. Define default MCP servers and connection to nats catalogue at ```<user_home_directory>\.codemie\config.json``` file
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
10. Check list of availability MCP server
```bash
  codemie-plugins mcp list
```
11. Create plugin project integration on AI/Run™ with value from config.json files using PLUGIN_KEY, and "Alias" property should be  "demo-plugin-integration"

12. Run MCP servers and codemie-plugins
    For MacOS & Linux
```bash
  cd <absolute_path_to_your_project>
  export PROJECT_BOOTSTRAP=/<absolute_path_to_your_project>/airun
  export ALLOWED_DIRS=/<absolute_path_to_your_project>
  export FILE_PATHS=/<absolute_path_to_your_project>
  export ALLOWED_DIR=/<absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem,filesystem_ext -e filesystem=FILE_PATHS -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
For Windows
```bash
  cd <absolute_path_to_your_project>
  set PROJECT_BOOTSTRAP= <absolute_path_to_your_project>\airun
  set ALLOWED_DIRS=<absolute_path_to_your_project>
  set FILE_PATHS=<absolute_path_to_your_project>
  set ALLOWED_DIR=<absolute_path_to_your_project>
  codemie-plugins mcp run -s filesystem,filesystem-extra -e filesystem=FILE_PATHS -e filesystem-extra=ALLOWED_DIR,PROJECT_BOOTSTRAP
```

13. Go to Workflows templates and find ```Windup Rules Generation Workflow``` template
14. Share workflow with project
15. Run the workflow with a prompt that specifies what you want to migrate. For example: ```I want to migrate from Spring Boot 2 to Spring Boot 3```, ```I want to migrate from Java 8 to Java 17```...
16. Wait util workflow done
17. Result you can find at ```<project_base>/airun```

