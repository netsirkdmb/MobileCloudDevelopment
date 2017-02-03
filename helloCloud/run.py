###############################################################################################
# Kristen Dhuse                                                                               #
# CS496 - Hello Cloud Assignment                                                              #
# Description: This website is hosted on Amazon Web Services.  The homepage for this site     #
#              gives the current date and time for the US/Pacific timezone.  The "Current     #
#              Weather" link on this website gives a description of the current weather in    #
#              Seatle, WA, USA as well at the current temperature in Fahrenheit.  Below that, #
#              it provides a short description of the forecast for the next 5 days (including #
#              the current day).                                                              #
# References:                                                                                 #
# - for help with open weather API for Python                                                 #
#       https://github.com/csparpa/pyowm/wiki/Usage-examples                                  #
# - for help with Flask                                                                       #
#       http://flask.pocoo.org/                                                               #
# - for help with Arrow                                                                       #
#       http://crsmithdev.com/arrow/                                                          #
# - for help with Jinja2                                                                      #
#       https://realpython.com/blog/python/primer-on-jinja-templating/                        #
# - for help with degrees Fahrenheit symbol                                                   #
#       http://www.w3schools.com/charsets/ref_utf_letterlike.asp                              #
# - for help with Bootstrap tables                                                            #
#       http://getbootstrap.com/css/#tables                                                   #
###############################################################################################


from pyowm import OWM
from flask import Flask, render_template
import arrow


app = Flask(__name__)


# default route - displays current time in US/Pacific timezone
@app.route("/")
def currTime():
    timeZone = "US/Pacific"
    # get current date and time in specified time zone
    local = arrow.now(timeZone)

    return render_template('templateTime.html', theDate=local.format('dddd, MMMM D, YYYY'),
                           theTime=local.format('h:mm:ssa'), timezone=timeZone, title="Home")


# route to get current weather
@app.route("/weather")
def weather():
    # create OWM object
    API_key = '3ca51794f7789141f0525a05d80a43b9'
    owm = OWM(API_key)

    theCity = "Seattle"
    theState = "WA"
    weatherCityState = theCity + ", " + theState
    weatherLocation = theCity + ",US"

    # get currently observed weather for Seattle, WA, US
    obs = owm.weather_at_place(weatherLocation)

    # get weather object for current Seattle weather
    w = obs.get_weather()

    # get current weather status and temperature in fahrenheit
    currStatus = w.get_detailed_status()
    tempF = w.get_temperature('fahrenheit')["temp"]

    # query the daily forcast for Seattle, WA, US, for the next 5 days
    fc = owm.daily_forecast('Seattle,US', limit=5)

    # get a forcaster object
    f = fc.get_forecast()

    return render_template('templateWeather.html', theLocation=weatherCityState, currStatus=currStatus, theTemp=tempF, forecast=f,
                           title="Weather", arrow=arrow)


if __name__ == "__main__":
    app.run(debug=False, host='0.0.0.0')
