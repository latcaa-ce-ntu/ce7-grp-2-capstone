from flask import Flask, render_template
from jokes_webapp import webapp_blueprint  #NOSONAR
from jokes_setting import setting_blueprint  #NOSONAR
import os

# app = Flask(__name__)
app = Flask(__name__, template_folder=os.path.join(os.path.dirname(__file__), 'templates'))  #NOSONAR

# Register blueprints
app.register_blueprint(webapp_blueprint, url_prefix='/webapp')  #NOSONAR
app.register_blueprint(setting_blueprint, url_prefix='/settings') #NOSONAR

@app.route('/')
def index():
    return render_template('index.html')  

if __name__ == "__main__":
    app.run(debug=True)
