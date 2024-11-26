from flask import Flask, jsonify, render_template
import csv
import random
import os

app = Flask(__name__)

# Initial Jokes database (csv)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
JOKES_FILE = os.path.join(BASE_DIR, 'data', 'jokesbank.csv')

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
    joke = random.choice(jokes).replace('\\n','<br>')  # Convert "\b " to "<br>"" for HTML
    return jsonify(joke=joke)

if __name__ == '__main__':
    app.run(debug=True)