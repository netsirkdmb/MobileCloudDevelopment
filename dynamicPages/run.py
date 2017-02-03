###############################################################################################
# Kristen Dhuse                                                                               #
# CS496 - Dyanmic Pages Assignment                                                            #
# Description: This website is hosted on Amazon Web Services.  The homepage for this site     #
#              gives a table with all of the schools in the database.  Each school has a      #
#              button to edit and a button to delete its data.  There is also a link at the   #
#              top of the homepage to allow the user to add another school.                   #
# References:                                                                                 #
# - for help with Flask                                                                       #
#       http://flask.pocoo.org/                                                               #
# - for help with Jinja2                                                                      #
#       https://realpython.com/blog/python/primer-on-jinja-templating/                        #
# - for help with Bootstrap tables                                                            #
#       http://getbootstrap.com/css/#tables                                                   #
# - for help setting up virtual environment on AWS                                            #
#       http://docs.python-guide.org/en/latest/dev/virtualenvs/                               #
# - for help setting up mongoDB on AWS                                                        #
#       https://www.youtube.com/watch?v=VlYg3OwnSs0                                           #
###############################################################################################


from flask import Flask, render_template, request, redirect, url_for
from pymongo import MongoClient
from bson.objectid import ObjectId


app = Flask(__name__)


client = MongoClient()
app.db = client.schoolFinder


# default route - displays a table of all of the schools in the database
@app.route("/")
def listSchools():
    cursor = app.db.schools.find()

    return render_template('listTemplate.html', schools=list(cursor))


# route to add a new school to the database
@app.route("/add", methods=['POST', 'GET'])
def addSchool():
    if request.method == 'GET':
        return render_template('addEditTemplate.html', title="Add a School", submit="Add School", school={})
    elif request.method == 'POST':
        # validate input
        school = createSchool(request)
        if duplicateFormInput(school):
            return render_template('addEditTemplate.html', title="Add a School", submit="Add School", school=school,
                                   error="Error: School not added to database.  The combination of the school name, public/private status, and location must be unique.")
        # add to database
        app.db.schools.insert_one(school)

        # redirect to "/" route
        return redirect("/")


# route to edit a school in the database
@app.route("/edit/<school_id>", methods=['POST', 'GET'])
def editSchool(school_id):
    query = {"_id": ObjectId(school_id)}
    if request.method == 'GET':
        school = app.db.schools.find_one(query)
        print(school)
        return render_template('addEditTemplate.html', title="Edit School", submit="Save School", school=school)
    elif request.method == 'POST':
        # validate input
        school = createSchool(request)
        if duplicateFormInput(school, query["_id"]):
            school = app.db.schools.find_one(query)
            return render_template('addEditTemplate.html', title="Edit School", submit="Save School", school=school,
                                   error="Error: School not updated in database.  The combination of the school name, public/private status, and location must be unique.")
        # update database
        app.db.schools.update_one(query, {"$set": school})

        # redirect to "/" route
        return redirect("/")


# route to delete a school in the database
@app.route("/delete/<school_id>")
def deleteSchool(school_id):
    query = {"_id": ObjectId(school_id)}
    app.db.schools.delete_one(query)
    # redirect to "/" route
    return redirect("/")


# make a dictionary with the school data from the form
def createSchool(request):
    return {
        "schoolName": request.form["schoolName"],
        "typeOfSchool": request.form.getlist("typeOfSchool"),
        "pubOrPri": request.form["pubOrPri"],
        "location": request.form["location"],
        "foreignLanguagesTaught": request.form.getlist("foreignLanguagesTaught"),
        "rating": request.form["rating"]
    }


# validate form input to make sure it is valid and also not a duplicate entry
def duplicateFormInput(school, id = None):
    query = {"schoolName": school["schoolName"], "pubOrPri": school["pubOrPri"], "location": school["location"]}
    if id:
        query["_id"] = {"$ne": id}
    cursor = app.db.schools.find(query)
    return len(list(cursor)) > 0


if __name__ == "__main__":
    app.run(debug=False, port=5500, host='0.0.0.0')
