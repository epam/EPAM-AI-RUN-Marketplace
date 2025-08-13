# Workflow Templates

## Table of Contents
1. [Overview](#overview)
2. [Perl2Python: fully automated conversion](#Perl2Py)
3. [Java Test Coverage Enhancement](#java-test-coverage-enhancement)
4. OKTA implementation
5. Linq to SQL
11. DOTNET: test writer
12. DOTNET: sources triage
13. DOTNET: project discovery
14. DOTNET: fully automated test generation
15. DOTNET: coverage analyzer
16. DOTNET: fully automated test generation
17. DOTNET: coverage analyzer
18. .NET: Migration .NET Framework v4.5.2 to .NET 8
19. JS: coverage analyzer
20. JS: fully automated test generation
21. JS: project discovery
22. JS: sources triage
23. JS: test writer
24. amazon_q_wf
25. BeanStalkerWF
26. VM: VM to AMI Migration
27. VM: Migration VMWare to AWS
28. OKTA implementation



# Overview
Here you can find detailed instruction how to set up workflow form pre-created workflow template ....
You need to navigate to workflow section, pick up workflow you interested and check instraction for using the Workflow

## ⚠️ Warning
1. Do not connect too many plugins at once.
2. A workflow that uses plugin integration cannot be simultaneously connected to multiple computers.

### Using workflows across multiple projects
If you want to use the same workflow simultaneously in different projects:
1. Create a copy of the workflow for your own project (your@email.com)
2. Create a plugin integration specifically for your project (your@email.com)



# Perl2Py
1. Create folder scratchpad on C disk for example "C:\scratchpad"
2. Install Python 3.12 or higher
4. Install uvx
4. Install Node.js 22 or higher
5. Run command for install codemie-plugins
```bash
  uvx pip install codemie-plugins
```
<!-- 
5. Define  filesystem_ext MCP  and tree_sitter custom servers in your global configuration file (~/.codemie/config.json or C:\Users\<your_user>\.codemie\config.json) ?????
```
   "filesystem_ext": {
   "command": "C:/Users/volodymyr_lembak/ai-run-mcp-servers/run-mcp.bat",
   "args": [
   ]
   },
   "tree_sitter": {
   "command": "C:/Users/volodymyr_lembak/ai-run-mcp-servers/run-mcp_1.bat",
   "args": [
   ]
   }
   ```
-->
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
7. Check list of availability MCP server. Should be present "filesystem_ext" and "tree_sitter"
```bash
  codemie-plugins mcp list
```
8. Create in scratchpad file ```Perl2Py```
9. Create next three sub folder in Perl2Py: ```airun```, ```Perl```, ```Python```
10. Update plugin project integration on CodeMie with value from config.json files using PLUGIN_KEY
11. Add ```00bootstrap.json``` files with next values
```
 {
   "project_base": "C:\scratchpad\Perl2Py",
   "perl_dir": "C:\scratchpad\Perl2Py\Perl",  
   "python_dir": "C:\scratchpad\Perl2Py\Python"
 }
```
12. Run MCP servers and codemie-plugins
   For MacOS & Linux
```bash
  export ALLOWED_DIR=/scratchpad/Perl2Py
  export FILE_PATHS=/scratchpad/Perl2Py
  export PROJECT_BOOTSTRAP=/scratchpad/Perl2Py/airun
  codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server,tree_sitter -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
   For Windows
```bash
  set ALLOWED_DIR=C:\scratchpad\Perl2Py
  set FILE_PATHS=C:\scratchpad\Perl2Py
  set PROJECT_BOOTSTRAP=C:\scratchpad\Perl2Py\airun
  codemie-plugins config list
  codemie-plugins mcp run -s filesystem,filesystem_ext,cli-mcp-server,tree_sitter -e cli-mcp-server=ALLOWED_DIR -e filesystem_ext=ALLOWED_DIR,PROJECT_BOOTSTRAP
```
13. Left your perl project into ```Perl``` folder
14. Go to Workflows and run ```Perl2Python: fully automated conversion``` workflow
15. Wait util workflow done 
16. Result you can find ```~\scratchpad\Perl2Py\Python```

