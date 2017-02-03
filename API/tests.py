###############################################################################################
# Kristen Dhuse                                                                               #
# CS496 - API Assignment                                                                      #
# Description: This API is hosted on Amazon Web Services and allows people to find a list of  #
#              schools and also to find which schools and parents are associated with a       #
#              student or which students are associated with a parent.  This program runs     #
#              tests on the API.                                                              #
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
###############################################################################################

import unittest
import schoolFinder
import json
from bson.objectid import ObjectId

exampleSchool = {
    "foreignLanguagesTaught": [
        "Spanish",
        "French",
        "German",
        "Japanese",
        "Mandarin"
    ],
    "location": "12345",
    "name": "Test School",
    "typeOfSchool": [
        "Daycare",
        "Preschool",
        "Elementary School (K-5)",
        "Middle School (6-8)",
        "High School (9-12)"
    ],
    "pubOrPri": "Private",
    "rating": 5
}

exampleStudent = {
    "name": "Test Student",
    "grade": "6",
    "parentID": []
}

exampleParent = {
    "name": "Test Parent",
    "studentID": []
}

class SchoolsTests(unittest.TestCase):

    def setUp(self):
        schoolFinder.app.config["TESTING"] = True
        self.app = schoolFinder.app.test_client()
        schoolFinder.app.db = schoolFinder.app.client.testSchoolFinder

    def tearDown(self):
        schoolFinder.app.client.testSchoolFinder.schools.drop()
        schoolFinder.app.client.testSchoolFinder.students.drop()
        schoolFinder.app.client.testSchoolFinder.parents.drop()

    def addTenItems(self, example, db, item):
        tempItem = dict(example)
        # add 10 items to the list
        for i in range(1, 11):
            tempItem["name"] = "Test " + item + " " + str(i)
            self.app.post('/' + db, data=tempItem)

    def addTenStudents(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        currentSchoolID = jsonResult[0]["_id"]
        pastSchoolIDs = [x["_id"] for x in jsonResult]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = currentSchoolID
        tempStudent["pastSchools"] = pastSchoolIDs
        # add 10 students to the list
        for i in range(1, 11):
            tempStudent["name"] = "Test Student " + str(i)
            self.app.post('/students', data=tempStudent)

    # tests reading empty school list
    def test_read_empty_schoolList(self):
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert jsonResult == []

    # tests reading a school from the list
    def test_read_schoolList(self):
        self.app.post('/schools', data=exampleSchool)
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        del jsonResult[0]["_id"]
        self.assertEqual(jsonResult, [exampleSchool])

    # test reading with offset
    def test_read_offset_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools?offset=5')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 5

    # test reading with offset and limit
    def test_read_offset_limit_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools?offset=5&limit=3')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 3

    # test reading with limit
    def test_read_limit_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools?limit=7')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 7

    # test reading school with school_id from the list
    def test_read_id_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        ID = jsonResult[4]["_id"]
        school = jsonResult[4]
        result = self.app.get('/schools/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        self.assertDictEqual(jsonResult, school)

    # test reading school with school_id not in the list
    def test_read_id_not_in_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        ID = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.get('/schools/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "No school with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test reading school with invalid school_id
    def test_read_invalid_id_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools/x')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid school_id."}
        self.assertDictEqual(jsonResult, error)

    # tests adding 10 schools to the list
    def test_add_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        cursor = schoolFinder.app.db.schools.find()
        assert len(list(cursor)) == 10

    # test adding duplicate school to the list
    def test_add_duplicate_schoolList(self):
        self.app.post('/schools', data=exampleSchool)
        result = self.app.post('/schools', data=exampleSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "School not added to database.  The combination of the school name, public/private status, and location must be unique."}
        self.assertEqual(jsonResult, error)

    # test adding school with no name to the list
    def test_add_no_name_schoolList(self):
        tempSchool = dict(exampleSchool)
        tempSchool["name"] = None
        result = self.app.post('/schools', data=tempSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'name': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test adding school with no type to the list
    def test_add_no_type_schoolList(self):
        tempSchool = dict(exampleSchool)
        tempSchool["typeOfSchool"] = []
        result = self.app.post('/schools', data=tempSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'typeOfSchool': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test adding school with invalid type to the list
    def test_add_invalid_type_schoolList(self):
        tempSchool = dict(exampleSchool)
        tempSchool["typeOfSchool"] = ["bad school"]
        result = self.app.post('/schools', data=tempSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'typeOfSchool': 'bad school is not a valid choice'}}
        self.assertEqual(jsonResult, error)

    # test adding school with one type to the list
    def test_add_one_type_schoolList(self):
        tempSchool = dict(exampleSchool)
        tempSchool["typeOfSchool"] = ["Daycare"]
        result = self.app.post('/schools', data=tempSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": 'School successfully added to database.'}
        self.assertEqual(jsonResult, message)

    # test adding school with missing or invalid pubOrPri to the list
    def test_add_invalid_pubOrPri_schoolList(self):
        tempSchool = dict(exampleSchool)
        pubOrPriOptions = ["", "invalid"]
        for pubOrPriOption in pubOrPriOptions:
            tempSchool["pubOrPri"] = pubOrPriOption
            result = self.app.post('/schools', data=tempSchool)
            jsonResult = json.loads(result.get_data().decode('utf-8'))
            error = {"message": {'pubOrPri': pubOrPriOption + ' is not a valid choice'}}
            self.assertEqual(jsonResult, error)

    # test adding school with missing or invalid location to the list
    def test_add_invalid_location_schoolList(self):
        tempSchool = dict(exampleSchool)
        locations = ["", "1234", "123456", "1234a", "123.5"]
        for location in locations:
            tempSchool["location"] = location
            result = self.app.post('/schools', data=tempSchool)
            jsonResult = json.loads(result.get_data().decode('utf-8'))
            error = {"message": {'location': 'Please enter a valid 5-digit zip code.'}}
            self.assertEqual(jsonResult, error)

    # test adding school with no foreignLanguageTaught to the list
    def test_add_no_fLanguage_schoolList(self):
        tempSchool = dict(exampleSchool)
        tempSchool["foreignLanguagesTaught"] = []
        result = self.app.post('/schools', data=tempSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "School successfully added to database."}
        self.assertEqual(jsonResult, message)

    # test adding school with one foreignLanguageTaught to the list
    def test_add_one_fLanguage_schoolList(self):
        tempSchool = dict(exampleSchool)
        tempSchool["foreignLanguagesTaught"] = ["Spanish"]
        result = self.app.post('/schools', data=tempSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "School successfully added to database."}
        self.assertEqual(jsonResult, message)

    # test adding school with invalid foreignLanguageTaught to the list
    def test_add_invalid_fLanguage_schoolList(self):
        tempSchool = dict(exampleSchool)
        tempSchool["foreignLanguagesTaught"] = ["Invalid"]
        result = self.app.post('/schools', data=tempSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'foreignLanguagesTaught': 'Invalid is not a valid choice'}}
        self.assertEqual(jsonResult, error)

    # test adding school with invalid range rating to the list
    def test_add_invalid_range_rating_schoolList(self):
        tempSchool = dict(exampleSchool)
        ratings = [0, 11]
        for rating in ratings:
            tempSchool["rating"] = rating
            result = self.app.post('/schools', data=tempSchool)
            jsonResult = json.loads(result.get_data().decode('utf-8'))
            error = {"message": {'rating': 'Invalid argument: ' + str(rating) + '. argument must be within the range 1 - 10'}}
            self.assertEqual(jsonResult, error)

    # test adding school with missing or invalid int rating to the list
    def test_add_invalid_int_rating_schoolList(self):
        tempSchool = dict(exampleSchool)
        ratings = ["", "a", 1.2]
        for rating in ratings:
            tempSchool["rating"] = rating
            result = self.app.post('/schools', data=tempSchool)
            jsonResult = json.loads(result.get_data().decode('utf-8'))
            error = {"message": {
                'rating': str(rating) + ' is not a valid integer'}}
            self.assertEqual(jsonResult, error)

    # test add school with ID to list
    def test_add_id_schoolList(self):
        ID = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.post('/schools/' + str(ID), data=exampleSchool)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "You are not allowed to choose the ID for the school that you are creating."}
        self.assertEqual(jsonResult, error)

    # tests deleting all schools from the list
    def test_delete_all_schoolList(self):
        self.addTenStudents()
        cursor = schoolFinder.app.db.schools.find()
        assert len(list(cursor)) == 10
        self.app.delete('/schools')
        cursor = schoolFinder.app.db.schools.find()
        assert len(list(cursor)) == 0
        student = schoolFinder.app.db.students.find_one()
        self.assertEqual(student["currentSchool"], "")
        self.assertEqual(student["pastSchools"], [])

    # test deleting school with school_id not in the list
    def test_delete_id_not_in_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        ID = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.delete('/schools/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "School not deleted from database.  No school with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test deleting school with invalid school_id
    def test_delete_invalid_id_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.delete('/schools/x')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid school_id."}
        self.assertDictEqual(jsonResult, error)

    # test deleting school with school_id from the list
    def test_delete_id_schoolList(self):
        self.addTenStudents()
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        ID = jsonResult[0]["_id"]
        studentCurrSchool = schoolFinder.app.db.students.find_one({"currentSchool": ID})
        studentPastSchool = schoolFinder.app.db.students.find_one({"pastSchools": {"$in": [ID]}})
        self.app.delete('/schools/' + str(ID))
        cursor = schoolFinder.app.db.schools.find({"_id": ID})
        assert len(list(cursor)) == 0
        student = schoolFinder.app.db.students.find_one({"_id": studentCurrSchool["_id"]})
        self.assertEqual(student["currentSchool"], "")
        student = schoolFinder.app.db.students.find_one({"_id": studentPastSchool["_id"]})
        self.assertNotIn(studentPastSchool["_id"], student["pastSchools"])


    # test updating school with school_id from the list
    def test_update_id_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[2]
        ID = school["_id"]
        school["name"] = "Updated School"
        self.app.put('/schools/' + str(ID), data=school)
        dbSchool = schoolFinder.app.db.schools.find_one({"_id": ObjectId(ID)})
        dbSchool["_id"] = str(dbSchool["_id"])
        self.assertDictEqual(school, dbSchool)

    # test updating school with invalid school_id
    def test_update_invalid_id_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[3]
        ID = "x"
        school["name"] = "Updated School"
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid school_id."}
        self.assertDictEqual(jsonResult, error)

    # test updating school with school_id not in the list
    def test_update_id_not_in_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        ID = ObjectId('5789e15718b14b44be1b53b5')
        school = dict(exampleSchool)
        school["name"] = "Updated School"
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "School not updated in database.  No school with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test updating duplicate school in the list
    def test_update_duplicate_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        school["name"] = "Test School 1"
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "School not updated in database.  The combination of the school name, public/private status, and location must be unique."}
        self.assertDictEqual(jsonResult, error)

    # test updating school with no name
    def test_update_no_name_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        school["name"] = None
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'name': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertDictEqual(jsonResult, error)

    # test updating school with no type
    def test_update_no_type_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        school["typeOfSchool"] = []
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'typeOfSchool': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertDictEqual(jsonResult, error)

    # test updating school with invalid type
    def test_update_invalid_type_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        school["typeOfSchool"] = ["bad school"]
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'typeOfSchool': 'bad school is not a valid choice'}}
        self.assertDictEqual(jsonResult, error)

    # test updating school with one type to the list
    def test_update_one_type_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        school["typeOfSchool"] = ["Daycare"]
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": 'School successfully updated in database.'}
        self.assertDictEqual(jsonResult, message)

    # test updating school with missing or invalid pubOrPri
    def test_update_invalid_pubOrPri_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        pubOrPriOptions = ["", "invalid"]
        for pubOrPriOption in pubOrPriOptions:
            school["pubOrPri"] = pubOrPriOption
            result = self.app.put('/schools/' + str(ID), data=school)
            jsonResult = json.loads(result.get_data().decode('utf-8'))
            error = {"message": {'pubOrPri': pubOrPriOption + ' is not a valid choice'}}
            self.assertDictEqual(jsonResult, error)

    # test updating school with missing or invalid location
    def test_update_invalid_location_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        locations = ["", "1234", "123456", "1234a", "123.5"]
        for location in locations:
            school["location"] = location
            result = self.app.put('/schools/' + str(ID), data=school)
            jsonResult = json.loads(result.get_data().decode('utf-8'))
            error = {"message": {'location': 'Please enter a valid 5-digit zip code.'}}
            self.assertDictEqual(jsonResult, error)

    # test updating school with no foreignLanguageTaught
    def test_update_no_fLanguage_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        school["foreignLanguagesTaught"] = []
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "School successfully updated in database."}
        self.assertDictEqual(jsonResult, message)

    # test updating school with one foreignLanguageTaught
    def test_update_one_fLanguage_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        school["foreignLanguagesTaught"] = ["Spanish"]
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "School successfully updated in database."}
        self.assertDictEqual(jsonResult, message)

    # test updating school with invalid foreignLanguageTaught
    def test_update_invalid_fLanguage_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        school["foreignLanguagesTaught"] = ["Invalid"]
        result = self.app.put('/schools/' + str(ID), data=school)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'foreignLanguagesTaught': 'Invalid is not a valid choice'}}
        self.assertDictEqual(jsonResult, error)

    # test updating school with invalid range rating
    def test_update_invalid_range_rating_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        ratings = [0, 11]
        for rating in ratings:
            school["rating"] = rating
            result = self.app.put('/schools/' + str(ID), data=school)
            jsonResult = json.loads(result.get_data().decode('utf-8'))
            error = {"message": {'rating': 'Invalid argument: ' + str(rating) + '. argument must be within the range 1 - 10'}}
            self.assertDictEqual(jsonResult, error)

    # test updating school with missing or invalid int rating
    def test_update_invalid_int_rating_schoolList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        ID = school["_id"]
        ratings = ["", "a", 1.2]
        for rating in ratings:
            school["rating"] = rating
            result = self.app.put('/schools/' + str(ID), data=school)
            jsonResult = json.loads(result.get_data().decode('utf-8'))
            error = {"message": {'rating': str(rating) + ' is not a valid integer'}}
            self.assertDictEqual(jsonResult, error)

    # tests reading empty student list
    def test_read_empty_studentList(self):
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert jsonResult == []

    # tests reading a student from the list
    def test_read_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        self.app.post('/students', data=tempStudent)
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        del jsonResult[0]["_id"]
        self.assertEqual(jsonResult[0], tempStudent)

    # test reading student with offset
    def test_read_offset_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students?offset=5')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 5

    # test reading student with offset and limit
    def test_read_offset_limit_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students?offset=5&limit=3')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 3

    # test reading student with limit
    def test_read_limit_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students?limit=7')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 7

    # test reading student with student_id from the list
    def test_read_id_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        ID = jsonResult[4]["_id"]
        student = jsonResult[4]
        result = self.app.get('/students/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        self.assertDictEqual(jsonResult, student)

    # test reading student with student_id not in the list
    def test_read_id_not_in_studentList(self):
        self.addTenStudents()
        ID = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.get('/students/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "No student with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test reading student with invalid student_id
    def test_read_invalid_id_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students/x')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid student_id."}
        self.assertDictEqual(jsonResult, error)

    # tests adding 10 students to the list
    def test_add_studentList(self):
        self.addTenStudents()
        cursor = schoolFinder.app.db.students.find()
        assert len(list(cursor)) == 10

    # test adding duplicate student to the list
    def test_add_duplicate_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        self.app.post('/students', data=tempStudent)
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "Student successfully added to database."}
        self.assertEqual(jsonResult, message)

    # test adding student with no name to the list
    def test_add_no_name_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent["name"] = None
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'name': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test adding student with no grade to the list
    def test_add_no_grade_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent['grade'] = None
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'grade': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test adding student with invalid grade to the list
    def test_add_invalid_grade_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent['grade'] = ['bad grade']
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'grade': 'bad grade is not a valid choice'}}
        self.assertEqual(jsonResult, error)

    # test adding student with no currentSchool to the list
    def test_add_no_currentSchool_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = None
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'currentSchool': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test adding student with invalid currentSchool to the list
    def test_add_invalid_currentSchool_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = "x"
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "currentSchool is not a valid school in the database."}
        self.assertEqual(jsonResult, error)

    # test adding student with currentSchool not in schools to the list
    def test_add_invalid_id_currentSchool_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = "5789e15718b14b44be1b53b5"
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "currentSchool is not a valid school in the database."}
        self.assertEqual(jsonResult, error)

    # test adding student with no pastSchools to the list
    def test_add_no_pastSchools_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = None
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {
            'pastSchools': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test adding student with invalid pastSchools to the list
    def test_add_invalid_pastSchools_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = ["x", "y"]
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "pastSchool is not a valid school in the database."}
        self.assertEqual(jsonResult, error)

    # test adding student with pastSchools not in schools to the list
    def test_add_invalid_id_pastSchools_studentList(self):
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = ["5789e15718b14b44be1b53b5", "578b550d42458f56e1e5a203"]
        result = self.app.post('/students', data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "pastSchool is not a valid school in the database."}
        self.assertEqual(jsonResult, error)

    # test add student with ID to list
    def test_add_id_studentList(self):
        ID = ObjectId('5789e15718b14b44be1b53b5')
        self.addTenItems(exampleSchool, "schools", "School")
        result = self.app.get('/schools')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        school = jsonResult[1]
        pastSchool1 = jsonResult[2]
        pastSchool2 = jsonResult[2]
        tempStudent = dict(exampleStudent)
        tempStudent["currentSchool"] = school["_id"]
        tempStudent["pastSchools"] = [pastSchool1["_id"], pastSchool2["_id"]]
        result = self.app.post('/students/' + str(ID), data=tempStudent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "You are not allowed to choose the ID for the student that you are creating."}
        self.assertEqual(jsonResult, error)

    # tests deleting all students from the list
    def test_delete_studentList(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        cursor = schoolFinder.app.db.students.find()
        assert len(list(cursor)) == 10
        self.app.delete('/students')
        cursor = schoolFinder.app.db.students.find()
        assert len(list(cursor)) == 0
        parent = schoolFinder.app.db.parents.find_one({"_id": ObjectId(parent_id)})
        self.assertEqual(parent["studentID"], [])

    # test deleting student with student_id not in the list
    def test_delete_id_not_in_studentList(self):
        self.addTenStudents()
        ID = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.delete('/students/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Student not deleted from database.  No student with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test deleting student with invalid student_id
    def test_delete_invalid_id_studentList(self):
        self.addTenStudents()
        result = self.app.delete('/students/x')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid student_id."}
        self.assertDictEqual(jsonResult, error)

    # test deleting student with student_id from the list
    def test_delete_id_studentList(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        self.app.delete('/students/' + str(student_id))
        cursor = schoolFinder.app.db.students.find({"_id": ObjectId(student_id)})
        assert len(list(cursor)) == 0
        parent = schoolFinder.app.db.parents.find_one({"_id": ObjectId(parent_id)})
        self.assertEqual(parent["studentID"], [])

    # test updating student to the list
    def test_update_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "Student successfully updated in database."}
        self.assertEqual(jsonResult, message)

    # test updating with invalid student_id to the list
    def test_update_invalid_id_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = "x"
        student["name"] = "Updated Student"
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "Invalid student_id."}
        self.assertEqual(jsonResult, message)

    # test updating with student_id not in the list
    def test_update_id_not_in_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = ObjectId('5789e15718b14b44be1b53b5')
        student["name"] = "Updated Student"
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "Student not updated in database.  No student with this ID exists in the database."}
        self.assertEqual(jsonResult, message)

    # test updating duplicate student to the list
    def test_update_duplicate_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        self.app.put('/students/' + str(ID), data=student)
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "Student successfully updated in database."}
        self.assertEqual(jsonResult, message)

    # test updating student with no name to the list
    def test_update_no_name_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = None
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'name': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test updating student with no grade to the list
    def test_update_no_grade_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        student['grade'] = None
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'grade': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test updating student with invalid grade to the list
    def test_update_invalid_grade_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        student['grade'] = ['bad grade']
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'grade': 'bad grade is not a valid choice'}}
        self.assertEqual(jsonResult, error)

    # test updating student with no currentSchool to the list
    def test_update_no_currentSchool_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        student["currentSchool"] = None
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'currentSchool': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test updating student with invalid currentSchool to the list
    def test_update_invalid_currentSchool_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        student["currentSchool"] = "x"
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "currentSchool is not a valid school in the database."}
        self.assertEqual(jsonResult, error)

    # test updating student with currentSchool not in schools to the list
    def test_update_invalid_id_currentSchool_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        student["currentSchool"] = "5789e15718b14b44be1b53b5"
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "currentSchool is not a valid school in the database."}
        self.assertEqual(jsonResult, error)

    # test updating student with no pastSchools to the list
    def test_update_no_pastSchools_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        student["pastSchools"] = None
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'pastSchools': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test updating student with invalid pastSchools to the list
    def test_update_invalid_pastSchools_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        student["pastSchools"] = ["x", "y"]
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "pastSchool is not a valid school in the database."}
        self.assertEqual(jsonResult, error)

    # test updating student with pastSchools not in schools to the list
    def test_update_invalid_id_pastSchools_studentList(self):
        self.addTenStudents()
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[2]
        ID = student["_id"]
        student["name"] = "Updated Student"
        student["pastSchools"] = ["5789e15718b14b44be1b53b5", "578b550d42458f56e1e5a203"]
        result = self.app.put('/students/' + str(ID), data=student)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "pastSchool is not a valid school in the database."}
        self.assertEqual(jsonResult, error)

    # tests reading empty parent list
    def test_read_empty_parentList(self):
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert jsonResult == []

    # tests reading a parent from the list
    def test_read_parentList(self):
        self.app.post('/parents', data=exampleParent)
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        del jsonResult[0]["_id"]
        self.assertEqual(jsonResult, [exampleParent])

    # test reading parents with offset
    def test_read_offset_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents?offset=5')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 5

    # test reading parents with offset and limit
    def test_read_offset_limit_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents?offset=5&limit=3')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 3

    # test reading parents with limit
    def test_read_limit_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents?limit=7')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        assert len(jsonResult) == 7

    # test reading parent with parent_id from the list
    def test_read_id_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        ID = jsonResult[4]["_id"]
        parent = jsonResult[4]
        result = self.app.get('/parents/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        self.assertDictEqual(jsonResult, parent)

    # test reading parent with parent_id not in the list
    def test_read_id_not_in_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        ID = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.get('/parents/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "No parent with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test reading parent with invalid parent_id
    def test_read_invalid_id_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents/x')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid parent_id."}
        self.assertDictEqual(jsonResult, error)

    # tests adding 10 parents to the list
    def test_add_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        cursor = schoolFinder.app.db.parents.find()
        assert len(list(cursor)) == 10

    # test adding duplicate parent to the list
    def test_add_duplicate_parentList(self):
        self.app.post('/parents', data=exampleParent)
        result = self.app.post('/parents', data=exampleParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "Parent successfully added to database."}
        self.assertEqual(jsonResult, message)

    # test adding parent with no name to the list
    def test_add_no_name_parentList(self):
        tempParent = dict(exampleParent)
        tempParent["name"] = None
        result = self.app.post('/parents', data=tempParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'name': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertEqual(jsonResult, error)

    # test add parent with ID to list
    def test_add_id_parentList(self):
        ID = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.post('/parents/' + str(ID), data=exampleParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "You are not allowed to choose the ID for the parent that you are creating."}
        self.assertEqual(jsonResult, error)

    # tests deleting all parents from the list
    def test_delete_all_parentList(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        cursor = schoolFinder.app.db.parents.find()
        assert len(list(cursor)) == 10
        self.app.delete('/parents')
        cursor = schoolFinder.app.db.parents.find()
        assert len(list(cursor)) == 0
        student = schoolFinder.app.db.students.find_one({"_id": ObjectId(student_id)})
        self.assertEqual(student["parentID"], [])

    # test deleting parent with parent_id not in the list
    def test_delete_id_not_in_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        ID = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.delete('/parents/' + str(ID))
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Parent not deleted from database.  No parent with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test deleting parent with invalid parent_id
    def test_delete_invalid_id_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.delete('/parents/x')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid parent_id."}
        self.assertDictEqual(jsonResult, error)

    # test deleting parent with parent_id from the list
    def test_delete_id_parentList(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        self.app.delete('/parents/' + str(parent_id))
        cursor = schoolFinder.app.db.parents.find({"_id": ObjectId(parent_id)})
        assert len(list(cursor)) == 0
        student = schoolFinder.app.db.students.find_one({"_id": ObjectId(student_id)})
        self.assertEqual(student["parentID"], [])

    # test updating parent with parent_id from the list
    def test_update_id_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[2]
        ID = parent["_id"]
        parent["name"] = "Updated Parent"
        self.app.put('/parents/' + str(ID), data=parent)
        dbParent = schoolFinder.app.db.parents.find_one({"_id": ObjectId(ID)})
        dbParent["_id"] = str(dbParent["_id"])
        self.assertDictEqual(parent, dbParent)

    # test updating parent with invalid parent_id
    def test_update_invalid_id_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[3]
        ID = "x"
        parent["name"] = "Updated Parent"
        result = self.app.put('/parents/' + str(ID), data=parent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid parent_id."}
        self.assertDictEqual(jsonResult, error)

    # test updating parent with parent_id not in the list
    def test_update_id_not_in_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        ID = ObjectId('5789e15718b14b44be1b53b5')
        parent = dict(exampleParent)
        parent["name"] = "Updated Parent"
        result = self.app.put('/parents/' + str(ID), data=parent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Parent not updated in database.  No parent with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test updating duplicate parent in the list
    def test_update_duplicate_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        ID = parent["_id"]
        parent["name"] = "Test Parent 1"
        result = self.app.put('/parents/' + str(ID), data=parent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Parent successfully updated in database."}
        self.assertDictEqual(jsonResult, error)

    # test updating parent with no name
    def test_update_no_name_parentList(self):
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        ID = parent["_id"]
        parent["name"] = None
        result = self.app.put('/parents/' + str(ID), data=parent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'name': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertDictEqual(jsonResult, error)

    # test linking student to parent
    def test_link_student_to_parent(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        result = self.app.post('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "The student with student_id: " + str(student_id) + " and the parent with parent_id: " + str(parent_id) + " were successfully linked."}
        self.assertDictEqual(jsonResult, message)

    # test linking already linked student to parent
    def test_link_already_linked_student_to_parent(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        studentResult = self.app.get('/students/' + str(student_id))
        jsonResult = json.loads(studentResult.get_data().decode('utf-8'))
        studentLinkedParents = jsonResult['parentID']
        parentResult = self.app.get('/parents/' + str(parent_id))
        jsonResult = json.loads(parentResult.get_data().decode('utf-8'))
        parentLinkedStudents = jsonResult['studentID']
        dbLinks = [studentLinkedParents, parentLinkedStudents]
        links = [[str(parent_id)], [str(student_id)]]
        self.assertListEqual(links, dbLinks)

    # test linking student to parent with no parent_id
    def test_link_student_to_parent_no_parent_id(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = None
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        result = self.app.post('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'parent_id': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertDictEqual(jsonResult, error)

    # test linking student to parent with invalid parent_id
    def test_link_student_to_parent_invalid_parent_id(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = ["x"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        result = self.app.post('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid parent_id."}
        self.assertDictEqual(jsonResult, error)

    # test linking student to parent with parent_id not in list
    def test_link_student_to_parent_parent_id_not_in_list(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = ObjectId('5789e15718b14b44be1b53b5')
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        result = self.app.post('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Parent not updated in database.  No parent with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test linking student to parent with no student_id
    def test_link_student_to_parent_no_student_id(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = None
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        result = self.app.post('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'student_id': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertDictEqual(jsonResult, error)

    # test linking student to parent with invalid student_id
    def test_link_student_to_parent_invalid_student_id(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = ["x"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        result = self.app.post('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid student_id."}
        self.assertDictEqual(jsonResult, error)

    # test linking student to parent with student_id not in list
    def test_link_student_to_parent_student_id_not_in_list(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        result = self.app.post('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Student not updated in database.  No student with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test deleting student to parent link
    def test_delete_link_student_to_parent(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        result = self.app.delete('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "The student with student_id: " + str(student_id) + " and the parent with parent_id: " + str(parent_id) + " were successfully un-linked."}
        self.assertDictEqual(jsonResult, message)

    # test deleting student to parent link not already linked
    def test_delete_link_student_to_parent_not_linked(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        not_student_id = jsonResult[4]["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        not_parent_id = jsonResult[4]["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        notLinkedStudentParent = {"student_id": not_student_id, "parent_id": not_parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        result = self.app.delete('/linkStudentToParent', data=notLinkedStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        message = {"message": "The student with student_id: " + str(not_student_id) + " and the parent with parent_id: " + str(not_parent_id) + " were successfully un-linked."}
        self.assertDictEqual(jsonResult, message)

    # test deleting student to parent link with no parent_id
    def test_delete_link_student_to_parent_no_parent_id(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = None
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        result = self.app.delete('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'parent_id': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertDictEqual(jsonResult, error)

    # test deleting student to parent link with invalid parent_id
    def test_delete_link_student_to_parent_invalid_parent_id(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = ["x"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        result = self.app.delete('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid parent_id."}
        self.assertDictEqual(jsonResult, error)

    # test deleting student to parent link with parent_id not in list
    def test_delete_link_student_to_parent_parent_id_not_in_list(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = student["_id"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = ObjectId('5789e15718b14b44be1b53b5')
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        result = self.app.delete('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Parent not updated in database.  No parent with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)

    # test deleting student to parent link with no student_id
    def test_delete_link_student_to_parent_no_student_id(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = None
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        result = self.app.delete('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": {'student_id': 'Missing required parameter in the JSON body or the post body or the query string'}}
        self.assertDictEqual(jsonResult, error)

    # test deleting student to parent link with invalid student_id
    def test_delete_link_student_to_parent_invalid_student_id(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = ["x"]
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        result = self.app.delete('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Invalid student_id."}
        self.assertDictEqual(jsonResult, error)

    # test deleting student to parent link with student_id not in list
    def test_delete_link_student_to_parent_student_id_not_in_list(self):
        self.addTenStudents()
        self.addTenItems(exampleParent, "parents", "Parent")
        result = self.app.get('/students')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        student = jsonResult[1]
        student_id = ObjectId('5789e15718b14b44be1b53b5')
        result = self.app.get('/parents')
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        parent = jsonResult[1]
        parent_id = parent["_id"]
        linkStudentParent = {"student_id": student_id, "parent_id": parent_id}
        self.app.post('/linkStudentToParent', data=linkStudentParent)
        result = self.app.delete('/linkStudentToParent', data=linkStudentParent)
        jsonResult = json.loads(result.get_data().decode('utf-8'))
        error = {"message": "Student not updated in database.  No student with this ID exists in the database."}
        self.assertDictEqual(jsonResult, error)


if __name__ == '__main__':
    unittest.main()