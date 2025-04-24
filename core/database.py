###############################################################################
#
# File: database.py
#
# Author: Isaac Ingram
#
# Purpose: Provide a connection to the database
#
###############################################################################
import os
import requests
from typing import List
import config
from core.data_classes import *

API_ENDPOINT = os.getenv("BNB_API_ENDPOINT", '')
AUTHORIZATION_KEY = os.getenv("BNB_AUTHORIZATION_KEY", '')

MOCK_ITEMS = {
    2: Item(2, "Sour Patch Kids", "567890123456", 3.50, 90, 226, 15, "images/item_placeholder.png", ""),
    3: Item(3, "Brownie Brittle", "", 3.00, 90, 78, 10, "images/item_placeholder.png", ""),
}

# [
#     {
#         "id": 1,
#         "name": "Jolt Soda",
#         "price": 1.5,
#         "quantity": 1,
#         "thumb_img": "http://placehold.jp/150x150.png",
#         "upc": "1000000000",
#         "vision_class": "",
#         "weight_avg": 1.0,
#         "weight_std": 1.0
#     },
#     {
#         "id": 2,
#         "name": "Sour Patch Kids",
#         "price": 2.5,
#         "quantity": 1,
#         "thumb_img": "http://placehold.jp/150x150.png",
#         "upc": "070462035964",
#         "vision_class": "",
#         "weight_avg": 226.0,
#         "weight_std": 10.0
#     },
#     {
#         "id": 3,
#         "name": "Brownie Brittle",
#         "price": 2.5,
#         "quantity": 1,
#         "thumb_img": "http://placehold.jp/150x150.png",
#         "upc": "711747011128",
#         "vision_class": "",
#         "weight_avg": 78.0,
#         "weight_std": 10.0
#     },
#     {
#         "id": 4,
#         "name": "Little Bites Blueberry",
#         "price": 2.1,
#         "quantity": 1,
#         "thumb_img": "http://placehold.jp/150x150.png",
#         "upc": "072030013398",
#         "vision_class": "",
#         "weight_avg": 47.0,
#         "weight_std": 10.0
#     },
#     {
#         "id": 5,
#         "name": "Pepsi Wild Cherry 12 Pack",
#         "price": 8.8,
#         "quantity": 1,
#         "thumb_img": "http://placehold.jp/150x150.png",
#         "upc": "012000809996",
#         "vision_class": "",
#         "weight_avg": 4082.33,
#         "weight_std": 20.0
#     }
# ]

MOCK_USERS = {
    # 1: User(1, "Tag 1", "258427912599", 20.00, "imagine", "", ""),
    1: User(1, "User1", "", 10.00, 'imagine', "test@ema.il", "1234567")

}

MOCK_NFC = {
    1: NFC(1, 1, "MIFARE")
}

# Use mock data if USE_MOCK_DATA environment variable is set to 'true'. If it
# isn't set to 'true' (including not being set at all), it this defaults to
# False.
USE_MOCK_DB_DATA = os.getenv("USE_MOCK_DB_DATA", 'false').lower() == 'true'

REQUEST_HEADERS = {"Authorization": AUTHORIZATION_KEY}

# Store a cached list of all items
cached_items = None
# Store a cached dictionary of items, accessible by ID
cached_items_by_id = None

def is_reachable() -> bool:
    """
    Check if the database is reachable
    :return: True if the database is reachable, False otherwise
    """
    if USE_MOCK_DB_DATA:
        return True
    else:
        print("Check If Reachable (GET)")
        try:
            requests.get(API_ENDPOINT, headers=REQUEST_HEADERS)
            return True
        except requests.RequestException:
            print(f"\tExperienced Request Exception")
            return False


def get_items() -> List[Item]:
    """
    Get all items
    :return: A List of Item. If there is an error, an empty list is returned
    """
    global cached_items, cached_items_by_id

    print("GET /items")
    if USE_MOCK_DB_DATA:
        return list(MOCK_ITEMS.values())
    else:
        # Fetch data only if there is no cache
        if cached_items is None:
            url = API_ENDPOINT + "/items"
            # Make request
            response = requests.get(url, headers={"Authorization": AUTHORIZATION_KEY})
            # Check response code
            if response.status_code == 200:
                # Create list of items
                result = list()
                for item_raw in response.json():
                    result.append(Item(
                        item_raw['id'],
                        item_raw['name'],
                        item_raw['upc'],
                        item_raw['price'],
                        item_raw['quantity'],
                        item_raw['weight_avg'],
                        item_raw['weight_std'],
                        item_raw['thumb_img'],
                        item_raw['vision_class']
                    ))
                # Cache the items list
                cached_items = result
                # Cache items by ID
                cached_items_by_id = dict()
                for item in result:
                    cached_items_by_id[item.id] = item
                return result
            else:
                # Something went wrong so print info and return empty list
                print(f"\tReceived response {response.status_code}:")
                print(f"\t{response.content}")
                return list()
        else:
            return cached_items


def get_item(item_id: int) -> Item | None:
    """
    Get an item from its ID
    :return: An Item or None if the item does not exist
    """
    global cached_items_by_id
    print(f"GET /items/{item_id}")
    if USE_MOCK_DB_DATA:
        if item_id in MOCK_ITEMS:
            return MOCK_ITEMS[item_id]
        else:
            return None
    else:
        if cached_items_by_id is None:
            url = API_ENDPOINT + f"/items/{item_id}"
            # Make request
            response = requests.get(url, headers=REQUEST_HEADERS)
            # Check response code
            if response.status_code == 200:
                item = response.json()
                return Item(
                    item['id'],
                    item['name'],
                    item['upc'],
                    item['price'],
                    item['units'],
                    item['avg_weight'],
                    item['std_weight'],
                    item['thumbnail'],
                    item['vision_class']
                )
            else:
                # Something went wrong so print info and return None
                print(f"\tReceived response {response.status_code}:")
                print(f"\t{response.content}")
                return None
        else:
            return cached_items_by_id[item_id]



def get_user(user_id=None, nfc_id=None) -> User | None:
    """
    Get user from either the user id or token
    :param user_id: Optional User ID
    :param user_token: Optional User Token
    :return: A User or None if the User does not exist or no identifier (ID or
    token) was provided
    """
    if USE_MOCK_DB_DATA:
        # Check if nfc id should be used
        if nfc_id is not None:
            # Get user from nfc id
            print(f"MOCK GET /nfc/{nfc_id}")
            for nfc in MOCK_NFC:
                if MOCK_USERS.get(nfc) != None:
                    return MOCK_USERS[nfc]
            return None
        # Check if user id should be used
        elif user_id is not None:
            # Get user from ID
            print(f"MOCK GET /users/{user_id}")
            if user_id in MOCK_USERS:
                return MOCK_USERS[user_id]
            else:
                return None
        # Can't use token or ID so return None
        else:
            return None
    else:
        # Determine whether URL should query based on nfc ID or user ID
        url = ""
        if nfc_id is not None:
            # Query based on nfc id
            print(f"GET /nfc/{nfc_id}")
            url = API_ENDPOINT + f"/nfc/{nfc_id}"
        elif user_id is not None:
            # Query based on user id
            print(f"GET /users/{user_id}")
            url = API_ENDPOINT + f"/users/{user_id}"
        else:
            # Neither so return None
            return None

        # Make query determined above
        response = requests.get(url, headers=REQUEST_HEADERS)
        # Check response code
        if response.status_code == 200:
            if nfc_id is not None:
                UID = response.json()['assigned_user']
                print(f"GET /users/{UID}")
                url = API_ENDPOINT + f"/users/{UID}"
                response = requests.get(url, headers=REQUEST_HEADERS)
                user = response.json()
                return User(
                    user['id'],
                    user['name'],
                    user['thumb_img'],
                    user['balance'],
                    user['email'],
                    user['phone']
                )
                    
            if user_id is not None:
                user = response.json()
                return User(
                    user['id'],
                    user['name'],
                    user['thumb_img'],
                    user['balance'],
                    user['email'],
                    user['phone']
                )
        else:
            # Something went wrong so print info and return None
            print(f"\tReceived response {response.status_code}")
            print(f"\t{response.content}")
            return None


def update_user(user: User) -> User | None:
    """
    Update a User
    :param user: Updated User
    :return: The new User if the update was successful, otherwise None
    """
    print(f"PUT /users/{user.uid}")
    if USE_MOCK_DB_DATA:
        if user.uid in MOCK_USERS:
            MOCK_USERS[user.uid] = user
            return user
        else:
            return None
    else:
        url = API_ENDPOINT + f"/users/{user.uid}"
        params = {
            'id': user.uid,
            'name': user.name,
            'thumb_img': user.thumb_img,
            'balance': user.balance,
            'email': user.email,
            'phone': user.phone
        }
        response = requests.put(url, params=params, headers=REQUEST_HEADERS)
        if response == 200:
            return user
        else:
            print(f"\tReceived response {response.status_code}")
            print(f"\t{response.content}")
            return None
