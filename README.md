# Setup:

```shell
python3 -m venv venv
pip install -r requirements.txt
```

## To use `bnb` package:

```shell
pip install -e .
```

This will install the package in an 'editable' form so that you can make chnages if you are adding more commands to the package in the future

### Commands:

- #### run ####
    ```shell 
    bnb run [ARGS]
    ```  
    - args:
        - screen: the screen to be displayed first; default is `main`
### Adding Commands:

To be written

## Enviroment variables

```python
import os

os.environ["QT_VIRTUALKEYBOARD_STYLE"] = "dark"
os.environ["QT_VIRTUALKEYBOARD_COLOR_SCHEME"] = "dark"
os.environ["BNB_API_ENDPOINT"] = ************
os.environ["BNB_AUTHORIZATION_KEY"] = ************
os.environ["BNB_ADMIN_PATTERN"] = "[1, 2, 3, 4]"
```
import the rest:

```python 
os.environ["QT_QUICK_CONTROLS_STYLE"] = "MCUDefaultStyle"
os.environ["QT_IM_MODULE"] = "qtvirtualkeyboard"
```
into `main.py`

Please refer to existing members of BnB to get the `BNB_API_ENDPOINT` and `BNB_AUTHORIZATION_KEY`


