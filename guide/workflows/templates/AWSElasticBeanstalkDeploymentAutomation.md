# BeanStalker: AWS Elastic Beanstalk Deployment Automation

## ⚠️ Warning

- The workflow works only on Unix-like operating systems. If you are using Windows, please run all commands from WSL (Windows Subsystem for Linux).
- AWS CLI - should be installed and configured
- Workflow use only default AWS profile which is configured on your machine (or WSL)
- eb (awsebcli) - should be installed on your machine (or WSL)
- dos2unix - if you are using WSL, it should be installed within your WSL
- jq - should be installed on your machine (or WSL)

# Step for run
1. Go to WSL(if you use Windows)
2. Install Python 3.12 or higher
3. Install Node.js 22 or higher
4. Create or activate a Python virtual environment
5. Clone  folder ```guide/workflows/resources``` to your computer. (if you use Windows, pls, copy to WSL folders)
6. Find "PrefixListId" in aws account
7. Prepare the Templates
```bash
  # Rename all template files to their actual names
  mv .ebextensions/00-unified.config.template .ebextensions/00-unified.config
  mv cleanup.sh.template cleanup.sh
  mv deploy.sh.template deploy.sh
  mv infrastructure/eb-infra-simple.yaml.template infrastructure/eb-infra-simple.yaml
  mv infrastructure/eb-infra-with-rds.yaml.template infrastructure/eb-infra-with-rds.yaml

  # Make scripts executable
  chmod -R 777 beanstalker
  
  # If you use WSL, make sure to run the following commands 
  dos2unix cleanup.sh
  dos2unix deploy.sh
```
8. Prepare Your Application
Place your application in a folder named `<name>_app` in the working directory:

```bash
# Example for a Java application
cp -r /path/to/your/java/app ./java_app

# Example for a Python application
cp -r /path/to/your/python/app ./python_app
```
**Important**: For Python applications, ensure `requirements.txt` is in the root folder of your application.
For example 
```
Flask==2.3.2
gunicorn==21.2.0
```

9. Update default values in deploy.sh and cleanup.sh files 
```
STACK_NAME="${STACK_NAME:-eb-vpn-infrastructure}"
APP_NAME="${APP_NAME:-my-eb-app}"
ENV_NAME="${ENV_NAME:-my-eb-env}"
REGION="${AWS_REGION:-eu-central-1}"
PLATFORM="${PLATFORM:-corretto-17}"
DB_USERNAME="${DB_USERNAME:-xxxxxxxxxxxxx}"
DB_PASSWORD="${DB_PASSWORD:-xxxxxxxxxxxxx}"
DB_ENGINE="${DB_ENGINE:-postgres}"
```
and
```
STACK_NAME="${STACK_NAME:-eb-vpn-infrastructure}"
ENV_NAME="${ENV_NAME:-my-eb-env}"
REGION="${AWS_REGION:-eu-central-1}"
```
10. Update ```SourcePrefixListId``` property in next files:  ```00-unified.config```, ```eb-infra-simple.yaml```, ```eb-infra-with-rds.yaml```
11. Update all values where placeholder like ```xxxxxxxxxxxxx``` in file ```eb-infra-with-rds.yaml```
12. Update ```Procfile``` with command for run your application
    The Procfile tells Elastic Beanstalk how to start your application. When using workflows, this is auto-generated. For manual deployment, create a `Procfile` in your application root:

Go Application
```
web: ./application
```

Java Spring Boot Application
```
web: java -jar application.jar --server.port=8000
```

Node.js Application
```
web: node server.js
```

Python Flask Application
```
web: gunicorn --bind :8000 --workers 3 app:application
```

 Python Django Application
```
web: gunicorn --bind :8000 myproject.wsgi
```

13. Run command for install codemie-plugins
```bash
  pip install codemie-plugins
```
14. Create ```.codemie``` folder at ```<user_home_directory>``` folder
15. Create ```config.json``` file at ```<user_home_directory>\.codemie``` folder
16. Define MCP connection to nats catalogue at ```<user_home_directory>\.codemie\config.json``` file
```
{
 "PLUGIN_KEY": "<Any value>",
 "PLUGIN_ENGINE_URI": "tls://codemie-nats.<url>:30422",
}
   ```
17. Check list of availability MCP server
```bash
  codemie-plugins mcp list
```
18. Update plugin project integration on AI/Run™ with value from config.json files using PLUGIN_KEY

19. Run MCP servers and codemie-plugins
    <unix_like_absolute_path_to_your_project> - according to step 5
```bash
  cd <unix_like_absolute_path_to_your_project>
  export ALLOWED_DIRS="<unix_like_absolute_path_to_your_project>"
  export ALLOWED_DIR="<unix_like_absolute_path_to_your_project>"
  export FILE_PATHS="<unix_like_absolute_path_to_your_project>,/tmp"
  codemie-plugins mcp run -s filesystem,cli-mcp-server -e filesystem=FILE_PATHS -e cli-mcp-server=ALLOWED_DIR
```
20. Create new Plugin integration with ```PLUGIN_KEY``` from step 16 for your project
21. Go to assistant templates and find the ```Bean: AWS Elastic Beanstalk Agentic Assistant``` template
22. Create assistant from template for your project and add Plugin integration from step 20
23. Go to Workflows templates and find the ```BeanStalker: AWS Elastic Beanstalk Deployment Automation``` template
24. Create workflow with project for your project and replace the ```PRECONFIGURED:amna-aws-eb-bean``` value with assistant id from step 21
25. Run the workflow with a prompt that specifies what type of deployment you want. For example: ```Deploy with simple type deployment```, ```Deploy with rds type deployment```...
26. Wait util workflow done
27. Check URL from output


If you need destroy environment
1. All previous step should be Done
2. Go to Workflows templates and find the ```BeanDestroyer: AWS Elastic Beanstalk Teardown Automation``` template
3. Create workflow with project for your project and replace the ```PRECONFIGURED:amna-aws-eb-bean``` value with assistant id from step 21
4. Run the workflow with a prompt
5. Wait util workflow done
