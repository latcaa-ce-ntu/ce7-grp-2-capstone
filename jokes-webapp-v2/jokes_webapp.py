from flask import jsonify, render_template, Blueprint
from flask_cors import CORS
from dotenv import load_dotenv
from datetime import datetime, timezone  # Add necessary imports
import secrets  
import json
import requests
import os

# Define the blueprint
webapp_blueprint = Blueprint('webapp', __name__)
CORS(webapp_blueprint)  # Enable CORS for all routes

load_dotenv()
api_url = os.getenv('API_URL')

# Function to retrieve a joke
def load_jokes():
    
    # print("load_jokes activate", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    
    body = {
         "resource": "/jokes",
         "httpMethod": "GET"
     }
        
    response = requests.get(api_url, json=body)

    if response.status_code == 200:
        try:
            # Parse the 'body' field, which is a JSON string representing the list of jokes
            response_data = json.loads(response.text)
            jokes = json.loads(response_data['body'])  # Now this should be a list of jokes
            
            # print("Jokes received:", jokes)  # Debugging: print the jokes

            # Check if jokes is a list and not empty
            if isinstance(jokes, list) and len(jokes) > 0:
                # Extract the joke text from the 'Jokes' field
                joke = secrets.choice(jokes)['Jokes'].replace('\n', '<br>')  # pick a random joke
                return jsonify(joke=joke)
            else:
                return jsonify(error="No jokes found in the response body"), 500
        except (json.JSONDecodeError, KeyError) as e:
            return jsonify(error="Failed to parse jokes response: {}".format(str(e))), 500
    else:
        return jsonify(error="Failed to fetch joke from API"), 500

# python main function
@webapp_blueprint.route('/index')
def home():
    return render_template('index.html')

# get jokes function
@webapp_blueprint.route('/get-joke')
def get_joke():
    # print("get_joke activate", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    return load_jokes()
