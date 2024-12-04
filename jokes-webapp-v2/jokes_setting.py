# jokes_setting.py (Frontend)
from flask import render_template, jsonify, request, Blueprint
from flask_cors import CORS
from datetime import datetime, timezone
from dotenv import load_dotenv
import requests
import json
import time
import os

# Define the blueprint
setting_blueprint = Blueprint('setting', __name__)
CORS(setting_blueprint) # This will enable CORS for all routes

load_dotenv()
api_url = os.getenv('API_URL')

@setting_blueprint.route('/')
def index():
    return render_template('mgmt.html')

@setting_blueprint.route('/api/jokes', methods=['GET'])
def api_jokes():
    # print("python launch activate", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    
    body = {
         "resource": "/jokes",
         "httpMethod": "GET"
     }
    
    response = requests.get(api_url, json=body)
    data = json.loads(response.text)
    jokes_data = json.loads(data['body'])
    return jsonify(jokes_data)

@setting_blueprint.route('/api/jokes', methods=['POST'])
def create_joke():
    # print("python create activate", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))

    unique_number = int(time.time() * 1000)
    current_time = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    
    # Check if the request contains JSON data
    data = request.get_json()
    
    # Ensure the 'Jokes' key exists in the JSON payload
    if 'Jokes' not in data:
        return 'Error: No joke data received', 400
    
    joke = data['Jokes']
    
    # Print the joke to the console
    # print('Joke:', joke)
    
    inner_body = {
        "Id": unique_number,
        "Jokes": joke,
        "DateCreation": current_time,
        "TotalLikes": 0
    }
    
    formatted_inner_body = json.dumps(inner_body, indent=2)
        
    body = {
         "httpMethod": "POST",
         "path": "/jokes",
         "body": formatted_inner_body
    }

    # print('Formatted Body:', body)
    response = requests.post(api_url, json=body)
    
    if response.status_code == 200:
        return jsonify({"message": f'New joke added: {joke}'}), 200
    else:
        return jsonify({"error": "Failed to add joke", "details": response.text}), 500
    
@setting_blueprint.route('/api/jokes/<int:joke_id>', methods=['PUT'])
def update_joke(joke_id):
    # print("python update activate", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    
    data = request.get_json()
    # print("Data : ", data)
    # print("Date creation : ", data['DateCreation'])
    
    # Ensure the 'Jokes' key exists in the JSON payload
    # if 'Jokes' not in data:
    #     return 'Error: No joke data received', 400
    
    joke = data['Jokes']
    # print('Joke:', joke)
        
    inner_body = {
        "Id": joke_id,
        "Jokes": joke,
        "DateCreation": data['DateCreation'],
        "TotalLikes": data['TotalLikes']
    }

    # print("Inner body :", inner_body) 
    
    converted_data = {
        "httpMethod": "PUT",
        "path": f"/jokes/{joke_id}",
        "body": json.dumps(inner_body)  
    }
    
    response = requests.put(f"{api_url}/{joke_id}", json=converted_data)
    
    if response.status_code == 200:
        return jsonify({"message": f'Joke updated: {joke_id}'}), 200
    else:
        return jsonify({"error": "Failed to update joke", "details": response.text}), 404

@setting_blueprint.route('/api/jokes/<int:joke_id>', methods=['DELETE'])
def delete_joke(joke_id):
    # print("python delete activate", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    
    inner_body = {
        "httpMethod": "DELETE",
        "path": f"/jokes/{joke_id}",
        "body": f"{{\"Id\": {joke_id}}}"
        }
    
    # print('Converted data : ', json.dumps(inner_body, indent=2))
    
    response = requests.delete(f"{api_url}/{joke_id}", json=inner_body)
    
    if response.status_code == 200:
        return jsonify({"message": f'Joke {joke_id} deleted, successfully!'}), 200
    else:
        return jsonify({"error": "Failed to delete joke", "details": response.text}), 404
