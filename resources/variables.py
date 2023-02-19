from datetime import datetime

TODAY = datetime.now()

from RPA.Robocorp.Vault import Vault

secret = Vault().get_secret("credentials")
USER_NAME = secret["username"]
PASSWORD = secret["password"]
ORDER_URL = secret["target_url"]
ORDERFILE_URL = secret["orderfile_url"]