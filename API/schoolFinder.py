###############################################################################################
# Kristen Dhuse                                                                               #
# CS496 - API Assignment                                                                      #
# Description: This API is hosted on Amazon Web Services and allows people to find a list of  #
#              schools and also to find which schools and parents are associated with a       #
#              student or which students are associated with a parent.                        #
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
# - for help with Flask-restful                                                               #
#       http://flask-restful-cn.readthedocs.io/en/0.3.4/quickstart.html                       #
# - for help with Flask basic HTTP authorization                                              #
#       https://github.com/miguelgrinberg/Flask-HTTPAuth                                      #
###############################################################################################


from flask import Flask, request
from flask_restful import Resource, Api, reqparse, inputs
from pymongo import MongoClient
from bson.objectid import ObjectId
from flask_httpauth import HTTPBasicAuth
import bson
import json

app = Flask(__name__)
api = Api(app)
auth = HTTPBasicAuth()

@app.after_request
def after_request(response):
    response.headers.add('Access-Control-Allow-Origin', '*')
    response.headers.add('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE')
    return response

@auth.get_password
def get_password(username):
    query = {"username": username}
    result = app.db.users.find_one(query)
    if result:
        return result["password"]
    return None

@app.route('/')
def root():
    return app.send_static_file('schoolFinderApp.html')

# request parsers to validate input
# parser for creating account
accountParser = reqparse.RequestParser(bundle_errors=True)
accountParser.add_argument("username", required=True)
accountParser.add_argument("password", required=True)

# parser for get schools request
pageParser = reqparse.RequestParser(bundle_errors=True)
pageParser.add_argument("offset", type=inputs.natural)
pageParser.add_argument("limit", type=inputs.positive)

# parser for post and put schools requests
schoolParser = reqparse.RequestParser(bundle_errors=True)
schoolParser.add_argument("schoolName", required=True)
schoolParser.add_argument("typeOfSchool", required=True, action='append',
                          choices=["Daycare", "Preschool", "Elementary School (K-5)", "Middle School (6-8)", "High School (9-12)"])
schoolParser.add_argument("pubOrPri", required=True, choices=["Public", "Private"])
schoolParser.add_argument("location", required=True, type=inputs.regex("^[0-9]{5}$"), help="Please enter a valid 5-digit zip code.")
schoolParser.add_argument("foreignLanguagesTaught", action='append', choices=["Spanish", "French", "German", "Japanese", "Mandarin"], default=[])
schoolParser.add_argument("rating", required=True, type=inputs.int_range(1, 10))

# parser for post and put students requests
studentParser = reqparse.RequestParser(bundle_errors=True)
studentParser.add_argument("studentName", required=True)
studentParser.add_argument("grade", required=True,
                           choices=["Daycare", "Preschool", "K", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12"])
studentParser.add_argument("currentSchoolST", required=True)
studentParser.add_argument("pastSchoolsST", required=True, action='append')

# parser for post and put parents requests
parentParser = reqparse.RequestParser(bundle_errors=True)
parentParser.add_argument("parentName", required=True)

# parser for linking students and parents
linkStudentToParentParser = reqparse.RequestParser(bundle_errors=True)
linkStudentToParentParser.add_argument("student_id", required=True)
linkStudentToParentParser.add_argument("parent_id", required=True)

app.client = MongoClient()
app.db = app.client.schoolFinder


class AuthenticatedResource(Resource):
    method_decorators = [auth.login_required]


class CreateAccount(Resource):
    def post(self):
        user = accountParser.parse_args()
        query = {"username": user.username}
        result = app.db.users.find_one(query)
        if result:
            return {"message": "Account already exists with this username."}
        query = {"username": user.username, "password": user.password}
        app.db.users.insert_one(query)
        return {"message": "Account successfully created."}


class SchoolsList(AuthenticatedResource):
    # get list of all schools in the database
    def get(self):
        args = pageParser.parse_args()
        query = {"username": auth.username()}
        cursor = app.db.schools.find(query)
        if args["offset"]:
            cursor = cursor.skip(args["offset"])
        if args["limit"]:
            cursor = cursor.limit(args["limit"])
        schools = list(cursor)
        for school in schools:
            school["_id"] = str(school["_id"])
        return schools

    # insert a new school into the database, errors if the school is not unique
    def post(self):	
        school = schoolParser.parse_args()
        school["username"] = auth.username()
        if duplicateSchoolInput(school):
            return {"message": "School not added to database.  The combination of the school name, public/private status, and location must be unique."}, 400
        # add to database
        app.db.schools.insert_one(school)
        return {"message": "School successfully added to database."}, 200

    # delete all of the schools in the database
    def delete(self):
        query = {"username": auth.username()}
        app.db.schools.delete_many(query)
        app.db.students.update_many(query, {"$set": {"currentSchoolST": "", "pastSchoolsST": []}})
        return {"message": "All schools have been removed from the database."}, 200


class School(AuthenticatedResource):
    # get school with matching school_id if it exists
    def get(self, school_id):
        try:
            query = {"_id": ObjectId(school_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid school_id."}, 400
        query["username"] = auth.username()
        school = app.db.schools.find_one(query)
        if not school:
            return {"message": "No school with this ID exists in the database."}, 404
        school["_id"] = str(school["_id"])
        return school

    # insert school with school_id error
    def post(self, school_id):
        return {"message": "You are not allowed to choose the ID for the school that you are creating."}, 400

    # update school in database, errors if the school_id is not valid, if the school is not unique, or if the school does not exist in the database
    def put(self, school_id):
        school = schoolParser.parse_args()
        school["username"] = auth.username()
        try:
            query = {"_id": ObjectId(school_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid school_id."}, 400
        if duplicateSchoolInput(school, query["_id"]):
            return {"message": "School not updated in database.  The combination of the school name, public/private status, and location must be unique."}, 400
        if not validateSchoolIDexists(query["_id"]):
            return {"message": "School not updated in database.  No school with this ID exists in the database."}, 404
        # update database
        query["username"] = auth.username()
        app.db.schools.update_one(query, {"$set": school})
        return {"message": "School successfully updated in database."}, 200

    # delete a school from the database, errors if the school_id is not valid or if the school does not exist in the database
    def delete(self, school_id):
        try:
            query = {"_id": ObjectId(school_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid school_id."}, 400
        query["username"] = auth.username()
        result = app.db.schools.delete_one(query)
        if result.deleted_count == 0:
            return {"message": "School not deleted from database.  No school with this ID exists in the database."}, 404
        else:
            query = {"currentSchoolST": school_id, "username": auth.username()}
            app.db.students.update_many(query, {"$set": {"currentSchoolST": ""}})
            query = {"pastSchoolsST": {"$in": [school_id]}, "username": auth.username()}
            app.db.students.update_many(query, {"$pull": {"pastSchoolsST": school_id}})
            return {"message": "The school with school_id: " + school_id + " has been removed from the database."}, 200

class StudentsList(AuthenticatedResource):
    # get list of all students in the database
    def get(self):
        args = pageParser.parse_args()
        query = {"username": auth.username()}
        cursor = app.db.students.find(query)
        if args["offset"]:
            cursor = cursor.skip(args["offset"])
        if args["limit"]:
            cursor = cursor.limit(args["limit"])
        students = list(cursor)
        for student in students:
            student["_id"] = str(student["_id"])
            stringParentIDs = []

            # Track the Ids of all parents and schools linked in this record
            allParents = set()
            allSchools = set()
            for parent in student["parentID"]:
                allParents.add(parent)
                stringParentIDs.append(str(parent))
            if student["currentSchoolST"]:
                allSchools.add(ObjectId(student["currentSchoolST"]))
            for school in student["pastSchoolsST"]:
                allSchools.add(ObjectId(school))

            # Query for the names of all the parent ids
            query = {"_id": {"$in": list(allParents)}, "username": auth.username()}
            cursor = app.db.parents.find(query)
            parentLookup = {}
            for parent in cursor:
                parentLookup[parent["_id"]] = parent["parentName"]

            # Query for the names of all the school ids
            query = {"_id": {"$in": list(allSchools)}, "username": auth.username()}
            cursor = app.db.schools.find(query)
            schoolLookup = {}
            for school in cursor:
                schoolLookup[school['_id']] = school['schoolName']

            student["parentNameST"] = []
            for parent in student["parentID"]:
                student["parentNameST"].append(parentLookup[parent])
            
            student["currentSchoolDict"] = {}
            if student["currentSchoolST"]:
                student["currentSchoolName"] = schoolLookup.get(ObjectId(student["currentSchoolST"]), "")
                student["currentSchoolDict"][student["currentSchoolName"]] = student["currentSchoolST"]
            else:
                student["currentSchoolName"] = ""
            
            student["pastSchoolsName"] = []
            student["pastSchoolsDict"] = {}
            for school in student["pastSchoolsST"]:
                student["pastSchoolsName"].append(schoolLookup[ObjectId(school)])
                student["pastSchoolsDict"][schoolLookup[ObjectId(school)]] = school

            student["parentID"] = stringParentIDs

        return students

    # insert a new student into the database
    def post(self):
        student = studentParser.parse_args()
        student["parentID"] = []
        student["username"] = auth.username()
        if not validateSchoolIDexists(student["currentSchoolST"]):
            return {"message": "currentSchool is not a valid school in the database."}
        for pastSchool in student["pastSchoolsST"]:
            if not validateSchoolIDexists(pastSchool):
                return {"message": "pastSchool is not a valid school in the database."}
        # add to database
        result = app.db.students.insert_one(student)
        return {"message": "Student successfully added to database.", "_id": str(result.inserted_id)}, 200

    # delete all of the students in the database
    def delete(self):
        query = {"username": auth.username()}
        app.db.students.delete_many({})
        app.db.parents.update_many({}, {"$set": {"studentID": []}})
        return {"message": "All students have been removed from the database."}, 200

class Student(AuthenticatedResource):
    # get student with matching student_id if it exists
    def get(self, student_id):
        try:
            query = {"_id": ObjectId(student_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid student_id."}, 400
        query["username"] = auth.username()
        student = app.db.students.find_one(query)
        if not student:
            return {"message": "No student with this ID exists in the database."}, 404
        student["_id"] = str(student["_id"])
        stringParentIDs = []
        for parent in student["parentID"]:
            stringParentIDs.append(str(parent))
        student["parentID"] = stringParentIDs
        return student

    # insert student with student_id error
    def post(self, student_id):
        return {"message": "You are not allowed to choose the ID for the student that you are creating."}, 400

    # update student in database, errors if the student_id is not valid or if the student does not exist in the database
    def put(self, student_id):
        student = studentParser.parse_args()
        try:
            query = {"_id": ObjectId(student_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid student_id."}, 400
        if not validateStudentIDexists(query["_id"]):
            return {"message": "Student not updated in database.  No student with this ID exists in the database."}, 404
        if not validateSchoolIDexists(student["currentSchoolST"]):
            return {"message": "currentSchool is not a valid school in the database."}
        for pastSchool in student["pastSchoolsST"]:
            if not validateSchoolIDexists(pastSchool):
                return {"message": "pastSchool is not a valid school in the database."}
        # update database
        query["username"] = auth.username()
        app.db.students.update_one(query, {"$set": student})
        return {"message": "Student successfully updated in database."}, 200

    # delete a student from the database, errors if the student_id is not valid or if the student does not exist in the database
    def delete(self, student_id):
        try:
            query = {"_id": ObjectId(student_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid student_id."}, 400
        query["username"] = auth.username()
        student = app.db.students.find_one(query)
        if not student:
            return {"message": "Student not deleted from database.  No student with this ID exists in the database."}, 404
        app.db.students.delete_one(query)
        app.db.parents.update_many({"studentID": {"$in": [ObjectId(student_id)]}, "username": auth.username()}, {"$pull": {"studentID": ObjectId(student_id)}})
        return {"message": "The school with student_id: " + student_id + " has been removed from the database."}, 200

class ParentsList(AuthenticatedResource):
    # get list of all parents in the database
    def get(self):
        args = pageParser.parse_args()
        query = {"username": auth.username()}
        cursor = app.db.parents.find(query)
        if args["offset"]:
            cursor = cursor.skip(args["offset"])
        if args["limit"]:
            cursor = cursor.limit(args["limit"])
        parents = list(cursor)
        for parent in parents:
            parent["_id"] = str(parent["_id"])
            stringStudentIDs = []

            # Track the Ids of all students linked in this record
            allStudents = set()
            for student in parent["studentID"]:
                allStudents.add(student)
                stringStudentIDs.append(str(student))

            # Query for the names of all the student ids
            query = {"_id": {"$in": list(allStudents)}, "username": auth.username()}
            cursor = app.db.students.find(query)
            studentLookup = {}
            for student in cursor:
                studentLookup[student["_id"]] = student["studentName"]

            parent["studentNamePT"] = []
            for student in parent["studentID"]:
                parent["studentNamePT"].append(studentLookup[student])

            parent["studentID"] = stringStudentIDs

        return parents

    # insert a new parent into the database
    def post(self):
        parent = parentParser.parse_args()
        parent["studentID"] = []
        parent["username"] = auth.username()
        # add to database
        result = app.db.parents.insert_one(parent)
        return {"message": "Parent successfully added to database.", "_id": str(result.inserted_id)}, 200

    # delete all of the parents in the database
    def delete(self):
        query = {"username": auth.username()}
        app.db.parents.delete_many(query)
        app.db.students.update_many(query, {"$set": {"parentID": []}})
        return {"message": "All parents have been removed from the database."}, 200

class Parent(AuthenticatedResource):
    # get parent with matching parent_id if it exists
    def get(self, parent_id):
        try:
            query = {"_id": ObjectId(parent_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid parent_id."}, 400
        query["username"] = auth.username()
        parent = app.db.parents.find_one(query)
        if not parent:
            return {"message": "No parent with this ID exists in the database."}, 404
        parent["_id"] = str(parent["_id"])
        stringStudentIDs = []
        for student in parent["studentID"]:
            stringStudentIDs.append(str(student))
        parent["studentID"] = stringStudentIDs
        return parent

    # insert parent with parent_id error
    def post(self, parent_id):
        return {"message": "You are not allowed to choose the ID for the parent that you are creating."}, 400

    # update parent in database, errors if the parent_id is not valid or if the parent does not exist in the database
    def put(self, parent_id):
        parent = parentParser.parse_args()
        try:
            query = {"_id": ObjectId(parent_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid parent_id."}, 400
        if not validateParentIDexists(query["_id"]):
            return {"message": "Parent not updated in database.  No parent with this ID exists in the database."}, 404
        # update database
        query["username"] = auth.username()
        app.db.parents.update_one(query, {"$set": parent})
        return {"message": "Parent successfully updated in database."}, 200

    # delete a parent from the database, errors if the parent_id is not valid or if the parent does not exist in the database
    def delete(self, parent_id):
        try:
            query = {"_id": ObjectId(parent_id)}
        except bson.errors.InvalidId:
            return {"message": "Invalid parent_id."}, 400
        query["username"] = auth.username()
        result = app.db.parents.delete_one(query)
        if result.deleted_count == 0:
            return {"message": "Parent not deleted from database.  No parent with this ID exists in the database."}, 404
        else:
            app.db.students.update_many({"parentID": {"$in": [ObjectId(parent_id)]}, "username": auth.username()}, {"$pull": {"parentID": ObjectId(parent_id)}})
            return {"message": "The school with parent_id: " + parent_id + " has been removed from the database."}, 200

class StudentParentLink(AuthenticatedResource):
    def post(self):
        error, queryParent, queryStudent = self.validateIDs()
        if error:
            return error, 400
        queryStudent["username"] = auth.username()
        queryParent["username"] = auth.username()
        studentResult = app.db.students.update_one(queryStudent, {"$addToSet": {"parentID": queryParent["_id"]}})
        if studentResult.modified_count == 0:
            return {"message": "Student not updated in database.  No student with this ID exists in the database."}, 404
        parentResult = app.db.parents.update_one(queryParent, {"$addToSet": {"studentID": queryStudent["_id"]}})
        if parentResult.modified_count == 0:
            return {"message": "Parent not updated in database.  No parent with this ID exists in the database."}, 404
        return {"message": "The student with student_id: " + str(queryStudent["_id"]) + " and the parent with parent_id: " + str(queryParent["_id"]) + " were successfully linked."}, 200

    def delete(self):
        error, queryParent, queryStudent = self.validateIDs()
        if error:
            return error, 400
        queryStudent["username"] = auth.username()
        queryParent["username"] = auth.username()
        studentResult = app.db.students.update_one(queryStudent, {"$pull": {"parentID": queryParent["_id"]}})
        if studentResult.modified_count == 0 and not validateStudentIDexists(queryStudent["_id"]):
            return {"message": "Student not updated in database.  No student with this ID exists in the database."}, 404
        parentResult = app.db.parents.update_one(queryParent, {"$pull": {"studentID": queryStudent["_id"]}})
        if parentResult.modified_count == 0 and not validateParentIDexists(queryParent["_id"]):
            return {"message": "Parent not updated in database.  No parent with this ID exists in the database."}, 404
        return {"message": "The student with student_id: " + str(queryStudent["_id"]) + " and the parent with parent_id: " + str(queryParent["_id"]) + " were successfully un-linked."}, 200

    def validateIDs(self):
        ids = linkStudentToParentParser.parse_args()
        try:
            queryParent = {"_id": ObjectId(ids["parent_id"])}
        except bson.errors.InvalidId:
            return {"message": "Invalid parent_id."}, None, None
        try:
            queryStudent = {"_id": ObjectId(ids["student_id"])}
        except bson.errors.InvalidId:
            return {"message": "Invalid student_id."}, None, None
        return None, queryParent, queryStudent


# validate input to make sure it is valid and also not a duplicate entry
def duplicateSchoolInput(school, ID = None):
    query = {"schoolName": school["schoolName"], "pubOrPri": school["pubOrPri"], "location": school["location"], "username": school["username"]}
    # if the ID is provided, search for schools that do not have the provided ID
    if ID:
        query["_id"] = {"$ne": ID}
    cursor = app.db.schools.find(query)
    return len(list(cursor)) > 0


# returns true if school_id exists in database
def validateSchoolIDexists(school_id):
    try:
        query = {"_id": ObjectId(school_id)}
    except bson.errors.InvalidId:
        return False
    query["username"] = auth.username()
    cursor = app.db.schools.find(query)
    return len(list(cursor)) == 1


# returns true if student_id exists in database
def validateStudentIDexists(student_id):
    query = {"_id": ObjectId(student_id), "username": auth.username()}
    cursor = app.db.students.find(query)
    return len(list(cursor)) == 1


# returns true if parent_id exists in database
def validateParentIDexists(parent_id):
    query = {"_id": ObjectId(parent_id), "username": auth.username()}
    cursor = app.db.parents.find(query)
    return len(list(cursor)) == 1


# create routes for API
api.add_resource(CreateAccount, '/createAccount')
api.add_resource(SchoolsList, '/schools')
api.add_resource(School, '/schools/<string:school_id>')
api.add_resource(StudentsList, '/students')
api.add_resource(Student, '/students/<string:student_id>')
api.add_resource(ParentsList, '/parents')
api.add_resource(Parent, '/parents/<string:parent_id>')
api.add_resource(StudentParentLink, '/linkStudentToParent')


if __name__ == "__main__":
    app.run(debug=False, port=5600, host='0.0.0.0')
