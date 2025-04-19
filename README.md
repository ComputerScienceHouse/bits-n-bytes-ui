# Local Setup:

```shell
python3 -m venv .venv # Create virtual environment
source ./venv/bin/activate # Activate virtual environment
pip install -r requirements.txt # Install requirements
```

## Enviroment variables
Create a `config.py` file in the `bnb` directory. This is where you will place your environment variables.
You can copy/paste the following as a starting point:
```python
import os
# UI Settings
os.environ["QT_VIRTUALKEYBOARD_STYLE"] = "default"  # Options: "light", "dark", etc.
os.environ["QT_VIRTUALKEYBOARD_COLOR_SCHEME"] = "dark"  # Options: "light", "dark"
os.environ["BNB_ADMIN_PATTERN"] = "[1, 2, 3, 4]"

# Backend connection
os.environ["BNB_API_ENDPOINT"] = ''
os.environ["BNB_AUTHORIZATION_KEY"] = ''

# Email info for receipts
os.environ["BNB_EMAIL_ADDRESS"] = ''
os.environ["BNB_EMAIL_USER"] = ''
os.environ["BNB_EMAIL_PASSWORD"] = ""

# SMS (Twilio) info for receipts
os.environ["TWILIO_ACCOUNT_SID"]=""
os.environ["TWILIO_AUTH_TOKEN"]=""
os.environ["TWILIO_FROM_NUMBER"]=""

# MQTT Setup
os.environ["MQTT_LOCAL_BROKER_URL"] = "localhost"
os.environ["MQTT_REMOTE_BROKER_URL"] = ""
os.environ["MQTT_PORT"] = "1883"

# OPTIONAL Variables (Mainly for debugging)
os.environ["USE_MOCK_DATA"] = "False" # Set to "True" to use mock data instead of DB.

```

Please ask existing team members of Bits 'n Bytes to get any of the environment variables you don't have. Note that the app will still function without these variables, but the functionality they each provide will be disabled.

## Commands:

- #### run ####
    ```shell 
    bnb run [ARGS]
    ```  
    - args:
        - screen: the screen to be displayed first; default is `main`
### Adding Commands:

WIP

### Using the `bnb` package:

```shell
pip install -e .
```

This will install the package in an 'editable' form so that you can make chnages if you are adding more commands to the package in the future
