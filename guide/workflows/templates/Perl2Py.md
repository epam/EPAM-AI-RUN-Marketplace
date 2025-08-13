# Perl2Py
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
