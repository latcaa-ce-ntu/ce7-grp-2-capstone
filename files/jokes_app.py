from flask import Flask, jsonify, render_template
from flask_wtf.csrf import CSRFProtect
import csv
import random
import os
import secrets  

# Set the template and static folder to empty, all files in root folder.
app = Flask(__name__, template_folder='', static_folder='')

# Enable CSRF protection
csrf = CSRFProtect(app)  

# Initial Jokes database (csv)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
JOKES_FILE = os.path.join(BASE_DIR, 'jokesbank.csv')

# Loading all jokes from database
def load_jokes():
    with open(JOKES_FILE, 'r') as file:
        reader = csv.reader(file)
        jokes = [row[0].replace(',', '&#44;') for row in reader]
    return jokes

jokes = load_jokes()

# python main function
@app.route('/')
def home():
    return render_template('index.html')

# get jokes function
@app.route('/get-joke')
def get_joke():
    # joke = random.choice(jokes).replace('\\n','<br>')  # Convert "\b " to "<br>"" for HTML
    joke = secrets.choice(jokes).replace('\\n','<br>')  # Convert "\b " to "<br>"" for HTML
    return jsonify(joke=joke)

if __name__ == '__main__':
     app.run(debug=False)