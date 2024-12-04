from flask import Flask, render_template
from jokes_webapp import webapp_blueprint  # Import the blueprint from jokes_webapp.py
from jokes_setting import setting_blueprint  # Import the blueprint from jokes_setting.py
import os
# from flask_wtf.csrf import CSRFProtect  # Import CSRFProtect here

# sonar-ignore:start

# app = Flask(__name__)
app = Flask(__name__, template_folder=os.path.join(os.path.dirname(__file__), 'templates'))

# Enable CSRF protection for the main app
# csrf = CSRFProtect(app)

# Register blueprints
app.register_blueprint(webapp_blueprint, url_prefix='/webapp')
app.register_blueprint(setting_blueprint, url_prefix='/settings')

@app.route('/')
def index():
    return render_template('index.html')  # Or whatever you want to show on the root URL

if __name__ == "__main__":
    app.run(debug=True)
# sonar-ignore:end