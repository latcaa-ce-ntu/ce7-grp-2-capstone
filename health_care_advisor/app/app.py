from flask import Flask, jsonify, render_template
from flask_cors import CORS
from dotenv import load_dotenv
from datetime import datetime, timezone  
import requests
import os
import json

app = Flask(__name__)
CORS(app)  

# # Content data
# content_data = [
#     {"Id": 1,  "type" : "Chronic Disease",      "name": "Blood Pressure",               "description": "Tips for managing blood pressure.",                                                                                                                  "content": ["Monitor your blood pressure daily.", "Reduce salt intake.", "Exercise regularly."]},
#     {"Id": 2,  "type" : "Chronic Disease",      "name": "Diabetes",                     "description": "Guidelines for maintaining sugar levels.",                                                                                                           "content": ["Avoid sugary foods.", "Exercise 30 minutes daily.", "Monitor your sugar levels."]},
#     {"Id": 3,  "type" : "Chronic Disease",      "name": "Heart Health",                 "description": "Advice for a healthy heart.",                                                                                                                        "content": ["Eat heart-friendly foods.", "Maintain healthy cholesterol levels.", "Stay active."]},
#     {"Id": 4,  "type" : "Physical Activities",  "name": "Walking",                      "description": "A brisk 30-minute walk can improve cardiovascular health, boost mood, and enhance overall fitness.",                                                 "content": ""},
#     {"Id": 5,  "type" : "Physical Activities",  "name": "Jogging or Running",           "description": " Great for improving endurance, cardiovascular fitness, and maintaining a healthy weight.",                                                          "content": ""},
#     {"Id": 6,  "type" : "Physical Activities",  "name": "Cycling",                      "description": "Whether outdoor cycling or using a stationary bike, it strengthens legs, improves cardiovascular health, and is low-impact on joints.",              "content": ""},
#     {"Id": 7,  "type" : "Physical Activities",  "name": "Strength Training",            "description": "Bodyweight exercises like squats, lunges, push-ups, or weightlifting to build muscle mass, improve bone health, and boost metabolism.",              "content": ""},
#     {"Id": 8,  "type" : "Physical Activities",  "name": "Yoga",                         "description": "Enhances flexibility, reduces stress, improves balance, and increases strength.",                                                                    "content": ""},
#     {"Id": 9,  "type" : "Physical Activities",  "name": "Stretching",                   "description": "Daily stretching helps improve flexibility, prevent injuries, and promote muscle relaxation.",                                                       "content": ""},
#     {"Id": 10, "type" : "Physical Activities",  "name": "Swimming",                     "description": "A full-body workout that’s easy on the joints and enhances cardiovascular health, strength, and endurance.",                                         "content": ""},
#     {"Id": 11, "type" : "Physical Activities",  "name": "Dancing ",                     "description": "An enjoyable way to burn calories, improve coordination, and boost mood.",                                                                           "content": ""},
#     {"Id": 12, "type" : "Physical Activities",  "name": "Climbing Stairs",              "description": "A simple, effective way to build leg strength and improve cardiovascular",                                                                           "content": ""},
#     {"Id": 13, "type" : "Physical Activities",  "name": "Pilates",                      "description": "Focuses on core strength, flexibility, and overall body control, while also helping to improve posture.",                                            "content": ""},
#     {"Id": 14, "type" : "Diet Tips",            "name": "Eat a Variety of Whole Foods", "description": "Incorporate a wide range of fruits, vegetables, whole grains, lean proteins, and healthy fats to ensure a balanced intake of nutrients.",            "content": ""},
#     {"Id": 15, "type" : "Diet Tips",            "name": "Stay Hydrated ",               "description": "Drink plenty of water throughout the day to support digestion, energy levels, and overall body function.",                                           "content": ""},
#     {"Id": 16, "type" : "Diet Tips",            "name": "Control Portion Sizes ",       "description": "Be mindful of portion sizes to prevent overeating, and use smaller plates to help with portion control.",                                            "content": ""},
#     {"Id": 17, "type" : "Diet Tips",            "name": "Limit Added Sugars",           "description": "Minimize the consumption of sugary snacks, drinks, and processed foods to help regulate blood sugar levels and reduce the risk of chronic diseases.","content": ""},
#     {"Id": 18, "type" : "Diet Tips",            "name": "Include Lean Proteins",        "description": "Choose lean protein sources like chicken, fish, beans, and legumes to help build and repair muscles and maintain a healthy metabolism.",             "content": ""},
#     {"Id": 19, "type" : "Diet Tips",            "name": "Eat Healthy Fats",             "description": "Opt for sources of healthy fats like avocados, nuts, seeds, and olive oil, which can support brain function and heart health.",                      "content": ""},
#     {"Id": 20, "type" : "Diet Tips",            "name": "Minimize Processed Foods ",    "description": "Reduce intake of processed and packaged foods that are high in unhealthy fats, sugars, and sodium.",                                                 "content": ""},
#     {"Id": 21, "type" : "Diet Tips",            "name": "Snack Smart",                  "description": "Choose healthy snacks like fruits, vegetables, yogurt, or nuts instead of processed or high-sugar options.",                                         "content": ""},
#     {"Id": 22, "type" : "Diet Tips",            "name": "Plan Your Meals",              "description": "Plan your meals ahead of time to avoid reaching for unhealthy options when you're hungry. Include nutrient-dense foods in each meal.",               "content": ""},
#     {"Id": 23, "type" : "Diet Tips",            "name": "Practice Mindful Eating",      "description": "Pay attention to what you're eating, eat slowly, and enjoy each bite. This helps with digestion and prevents overeating.",                           "content": ""},
# ]

load_dotenv()
api_url = os.getenv('API_URL')
# print("===> api_url : ",api_url)

# Initialize content_data
content_data = []

# Function to retrieve a hca
def load_hca():
    global content_data  
    print("===> load_hca activate : ", datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"))
    
    body = {
         "resource": "/hca",
         "httpMethod": "GET"
     }
        
    try:
        response = requests.get(api_url, json=body)
        response.raise_for_status()  
        content_data = json.loads(response.json()['body'])  
        # print("===> Data successfully fetched and loaded : ", content_data)
        
    except requests.exceptions.RequestException as e:
        print(f"===>  Error fetching data : {e}")
        content_data = []  

@app.route("/")
def index():
    title_name = "Health Care Advisor"  
    return render_template('index.html', title_name=title_name)

@app.route("/api/chronic_disease")
def get_chronic_disease():

    filtered_content  =  [item for item in content_data if item["type"] == "Chronic Disease"]
    print("===> Chronic Disease : ", filtered_content)
    return jsonify(filtered_content)

@app.route("/api/physical_activity")
def get_physical_activity():
    
    filtered_content  =  [item for item in content_data if item["type"] == "Physical Activities"]
    return jsonify(filtered_content)

@app.route("/api/diet_tips")
def get_diet_tips():
    
    filtered_content  =  [item for item in content_data if item["type"] == "Diet Tips"]
    return jsonify(filtered_content)

if __name__ == "__main__":
    with app.app_context():
        load_hca()
    app.run(host="0.0.0.0", port=5000, debug=True)
