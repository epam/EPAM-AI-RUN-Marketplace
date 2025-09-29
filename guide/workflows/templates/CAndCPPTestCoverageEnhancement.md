# C/CPP: Test Coverage Enhancement


## ⚠️ Warning

- Keep track of your token and budget usage by regularly checking the details via the "Usage details" button on workflow-executions page after step 17.
- Project integration and workflow should be created within the same "project". It is recommended to name the project after your specific use case (e.g., "example@email.com").
  A project property is a special attribute in EPAM AI/Run™ for AWS , created by the admin. Each user has their own project, which is automatically named based on their email address
- Microsoft Visual C/C++ - should be installed on your machine
- MSVC build tools - should be installed on your machine
- The workflow work only on Windows OS

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
    },
    "noinput_cli": {
      "command": "uvx",
      "args": [
        "--from",
        "noinput_cli_mcp_server",
        "noinput-cli-mcp-server"
        ],
      "env": {
        "ALLOWED_COMMANDS": "all",
        "ALLOWED_FLAGS": "all",
        "MAX_COMMAND_LENGTH": "2048",
        "COMMAND_TIMEOUT": "300",
        "TIMEOUT": "300",
        "ALLOW_SHELL_OPERATORS": "true"
      }
    }
  }
}

   ```
7. Check list of availability MCP server. Should be present "noinput_cli" "filesystem_ext" and "tree_sitter"
```bash
  codemie-plugins mcp list
```
8. Create in scratchpad file ```cpprest```
9.  Left your C or C++ project into ```cpprest``` folder
10. Create next sub folder in root of your project next folder: ```airun```
11. Create plugin project integration on AI/Run™ with value from config.json files using PLUGIN_KEY, and "Alias" property should be  "demo-plugin-integration"
12. Add ```00bootstrap.json``` files with next values in airun folder
```
{
"project_base": "absolute_path_to_your_project",  
}
```
13. Add ```setvars.bat``` files with next values in root folder of your project
```
REM "Switch to project folder"
cd c:\\scratchpad\\cpprest

REM "Call MSVC environment initalization script for platform"
call "C:\\Program Files\\Microsoft Visual Studio\\2022\\Community\\VC\\Auxiliary\\Build\\vcvarsall.bat" amd64

REM "Make VCPKG-installed libraties available to build tools"
set VCPKG_ROOT=C:\\develop\\msvc\\vcpkg
set VCPKG_TOOLCHAIN=%VCPKG_ROOT%\\scripts\\buildsystems\\vcpkg.cmake
```
14. Run MCP servers and codemie-plugins
```bash
  cd C:\scratchpad\cpprest
  set ALLOWED_DIR=C:\scratchpad\cpprest
  set ALLOWED_DIRS=C:\scratchpad\cpprest
  set FILE_PATHS=C:\scratchpad\cpprest
  set PROJECT_BOOTSTRAP=C:\scratchpad\cpprest\<project_folder>\airun
  codemie-plugins config list
 codemie-plugins mcp run -s filesystem,filesystem_ext,noinput_cli -e noinput_cli=ALLOWED_DIR,PROGRAMFILES  -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
15. Go to Workflows templates
16. Find and create next workflow:

 - C/CPP: project discovery
 - C/CPP: sources triage
 - C/CPP: coverage analyzer
 - C/CPP: test writer

17. Go to Workflows and run the workflows which was created in previous step in the same order
18. Result you can find in project ```C:\scratchpad\cpprest\<project_folder>```




