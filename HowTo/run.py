###############################################################################################
# Kristen Dhuse                                                                               #
# CS496 - How To Assignment                                                                   #
# Description: This website is a guide for learning how to make a website with Flask using    #
#              Jinja2 templating.                                                             #
# References:                                                                                 #
# - for help with Flask                                                                       #
#       http://flask.pocoo.org/                                                               #
# - for help with Jinja2                                                                      #
#       https://realpython.com/blog/python/primer-on-jinja-templating/                        #
# - for help setting up virtual environment on AWS                                            #
#       http://docs.python-guide.org/en/latest/dev/virtualenvs/                               #
###############################################################################################


from flask import Flask, render_template


app = Flask(__name__)


# default route - displays a table of all of the schools in the database
@app.route("/")
def background():
    return render_template('backgroundTemplate.html')


@app.route("/installTNSwifty")
def installTNSwifty():
    return render_template('installTNSwiftyTemplate.html')


@app.route("/getStarted")
def getStarted():
    return render_template('getStartedTemplate.html')


@app.route("/checkboxViewController")
def checkboxViewController():
    return render_template('checkboxViewControllerTemplate.html')


@app.route("/makeStoryboard")
def makeStoryboard():
    return render_template('makeStoryboardTemplate.html')


@app.route("/navigationOutlets")
def navigationOutlets():
    return render_template('navigationOutletsTemplate.html')


@app.route("/moreNavigation")
def moreNavigation():
    return render_template('moreNavigationTemplate.html')


@app.route("/conclusion")
def conclusion():
    return render_template('conclusionTemplate.html')


if __name__ == "__main__":
    app.run(debug=False, port=5700, host='0.0.0.0')
