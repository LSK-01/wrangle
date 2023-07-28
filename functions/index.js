const admin = require('firebase-admin');
const { firebaseConfig } = require('firebase-functions');
admin.initializeApp();

const functions = require('firebase-functions');


const firestore = admin.firestore();
const settings = {/* your settings... */ timestampsInSnapshots: true };
firestore.settings(settings);
const FieldValue = require('firebase-admin').firestore.FieldValue;

//query the database for going public dates daily
exports.makeArgumentsPublic = functions.pubsub.topic('hourly-tick').onPublish((event) => {

    var timeCurrent = Date.now() / 3600000;
    var startOfLastHourInHours = Math.floor(timeCurrent);
    var startOfLastHourInSecs = startOfLastHourInHours * 3600;
    console.log("FLAG: " + startOfLastHourInSecs)

    let query = firestore.collection('arguments').where('goingPublicAt', '==', startOfLastHourInSecs).get()

    let promise = query.then(snapshot => {
        if (!snapshot.empty) {
            const promises = []
            var archiving = false
            snapshot.forEach(arg => {

                let document = arg.data()

                if (document.latestMessage == null) {
                    archiving = true
                    var topicTitle = document.topicTitle
                    var argumentID = arg.id

                    let userFor = admin.firestore().doc('users/' + document.uids.for)
                    let updateUser = userFor.update({
                        "topics": FieldValue.increment(-1)
                    })

                    let userAgainst = firestore.doc('users/' + document.uids.against)
                    let updateLoser = userAgainst.update({
                        "topics": FieldValue.increment(-1)
                    })

                    let fieldNameUsersFor = "usersFor." + document.uids.for
                    let fieldNameUsersAgainst = "usersAgainst." + document.uids.against
                    var data = {}
                    data[fieldNameUsersFor] = FieldValue.delete()
                    data[fieldNameUsersAgainst] = FieldValue.delete()
                    data["numUsersForTotal"] = FieldValue.increment(-1)
                    data["numUsersAgainstTotal"] = FieldValue.increment(-1)
                    let updateTopic = admin.firestore().doc('topics/' + topicTitle).update(data)

                    data = {}
                    data["uidsForQuerying"] = {
                        [document.uids.for]: false,
                        [document.uids.against]: false
                    }

                    let archiveArg = admin.firestore().doc('arguments/' + argumentID).update(data)

                    promises.push(updateUser)
                    promises.push(updateTopic)
                    promises.push(archiveArg)
                    promises.push(updateLoser)
                }
                else {
                    firestore.doc('arguments/' + arg.id).update({
                        "isPublic": true,
                        "upvotesFor": 0,
                        "upvotesAgainst": 0,
                        "for": [],
                        "against": [],
                        "totalUpvotes": 0,
                        "endingAt": startOfLastHourInSecs + (24 * 3600)
                    }
                    )
                }
            })

            if (archiving) {
                return Promise.all(promises)
            }
            else {
                return promise
            }

        }
        else {
            return promise
        }

    }).catch(err => {
        console.log("error")
        console.log(err)
        return err
    })
})

//query the database for going public dates daily
//now only needs to be one query - we can increment in an update a field
//+ increment wins and arguments fields
exports.giveWrangles = functions.pubsub.topic('hourly-tick').onPublish((event) => {
    var timeCurrent = Date.now() / 3600000;
    var startOfLastHourInHours = Math.floor(timeCurrent);
    var startOfLastHourInSecs = startOfLastHourInHours * 3600;

    let promise = firestore.collection('arguments').where('endingAt', '==', startOfLastHourInSecs).get()
        .then(snapshot => {

            if (!snapshot.empty) {
                const promises = []


                snapshot.forEach(arg => {
                    let document = arg.data()

                    //deincrement usersFor and against on topic
                    var topicTitle = document.topicTitle
                    var argumentID = arg.id

                    if (document.upvotesAgainst < document.upvotesFor) {
                        var winningUser = document.uids.for
                        var loser = document.uids.against

                    }
                    else {
                        var winningUser = document.uids.against
                        var loser = document.uids.for
                    }

                    let userDocRef = admin.firestore().doc('users/' + winningUser)
                    let updateUser = userDocRef.update({
                        "wins": FieldValue.increment(1)
                    })

                    let fieldNameUsersFor = "usersFor." + document.uids.for
                    let fieldNameUsersAgainst = "usersAgainst." + document.uids.against
                    var data = {}
                    data[fieldNameUsersFor] = FieldValue.delete()
                    data[fieldNameUsersAgainst] = FieldValue.delete()
                    data["numUsersForTotal"] = FieldValue.increment(-1)
                    data["numUsersAgainstTotal"] = FieldValue.increment(-1)
                    let updateTopic = admin.firestore().doc('topics/' + topicTitle).update(data)

                    data = {}
                    data["winner"] = document[winningUser]["username"]
                    data["uidsForQuerying"] = {
                        [document.uids.for]: true,
                        [document.uids.against]: true
                    }

                    let archiveArg = admin.firestore().doc('arguments/' + argumentID).update(data)

                    promises.push(updateUser)
                    promises.push(updateTopic)
                    promises.push(archiveArg)
                    promises.push(updateLoser)
                    console.log("POOP: " + startOfLastHourInSecs + document.endingAt)

                })
                return Promise.all(promises)
            }
            else {
                return (promise)
            }

        }).catch(err => {
            console.log("error")
            console.log(err)
            return (promise)
        })
})


exports.testingFuncGiveWrangles = functions.https.onRequest((req, res) => {

    let promise = firestore.collection('arguments').where('endingAt', '==', 0).get()
        .then(snapshot => {

            if (!snapshot.empty) {
                const promises = []


                snapshot.forEach(arg => {
                    let document = arg.data()

                    //deincrement usersFor and against on topic
                    var topicTitle = document.topicTitle
                    var argumentID = arg.id

                    if (document.upvotesAgainst < document.upvotesFor) {
                        var winningUser = document.uids.for
                        var loser = document.uids.against

                    }
                    else {
                        var winningUser = document.uids.against
                        var loser = document.uids.for
                    }

                    let userDocRef = admin.firestore().doc('users/' + winningUser)
                    let updateUser = userDocRef.update({
                        "wins": FieldValue.increment(1),
                        "topics": FieldValue.increment(-1)
                    })

                    let userLoser = firestore.doc('users/' + loser)
                    let updateLoser = userLoser.update({
                        "topics": FieldValue.increment(-1)
                    })

                    let fieldNameUsersFor = "usersFor." + document.uids.for
                    let fieldNameUsersAgainst = "usersAgainst." + document.uids.against
                    var data = {}
                    data[fieldNameUsersFor] = FieldValue.delete()
                    data[fieldNameUsersAgainst] = FieldValue.delete()
                    data["numUsersForTotal"] = FieldValue.increment(-1)
                    data["numUsersAgainstTotal"] = FieldValue.increment(-1)
                    let updateTopic = admin.firestore().doc('topics/' + topicTitle).update(data)

                    data = {}
                    data["winner"] = document[winningUser]["username"]
                    data["uidsForQuerying"] = {
                        [document.uids.for]: true,
                        [document.uids.against]: true
                    }

                    let archiveArg = admin.firestore().doc('arguments/' + argumentID).update(data)

                    promises.push(updateUser)
                    promises.push(updateTopic)
                    promises.push(archiveArg)
                    promises.push(updateLoser)
                    console.log("POOP: " + startOfLastHourInSecs + document.endingAt)

                })
                return Promise.all(promises)
            }
            else {
                return (promise)
            }

        }).catch(err => {
            console.log("error")
            console.log(err)
            res.send(promise)
        })
})

exports.testingFuncMakePublic = functions.https.onRequest((req, res) => {
    var timeCurrent = Date.now() / 3600000;
    var startOfLastHourInHours = Math.floor(timeCurrent);
    var startOfLastHourInSecs = startOfLastHourInHours * 3600;

    let query = firestore.collection('arguments').where('goingPublicAt', '==', 0).get()

    let promise = query.then(snapshot => {
        if (!snapshot.empty) {
            const promises = []
            var archiving = false
            snapshot.forEach(arg => {
                let document = arg.data()

                console.log("found argument to make public: " + document.topicTitle + arg.id)


                if (document.latestMessage == null) {
                    archiving = true
                    var topicTitle = document.topicTitle
                    var argumentID = arg.id

                    let userFor = admin.firestore().doc('users/' + document.uids.for)
                    let updateUser = userFor.update({
                        "topics": FieldValue.increment(-1)
                    })

                    let userAgainst = firestore.doc('users/' + document.uids.against)
                    let updateLoser = userAgainst.update({
                        "topics": FieldValue.increment(-1)
                    })

                    let fieldNameUsersFor = "usersFor." + document.uids.for
                    let fieldNameUsersAgainst = "usersAgainst." + document.uids.against
                    var data = {}
                    data[fieldNameUsersFor] = FieldValue.delete()
                    data[fieldNameUsersAgainst] = FieldValue.delete()
                    data["numUsersForTotal"] = FieldValue.increment(-1)
                    data["numUsersAgainstTotal"] = FieldValue.increment(-1)
                    let updateTopic = admin.firestore().doc('topics/' + topicTitle).update(data)

                    data = {}
                    data["uidsForQuerying"] = {
                        [document.uids.for]: true,
                        [document.uids.against]: true
                    }

                    let archiveArg = admin.firestore().doc('arguments/' + argumentID).update(data)

                    promises.push(updateUser)
                    promises.push(updateTopic)
                    promises.push(archiveArg)
                    promises.push(updateLoser)
                }
                else {
                    firestore.doc('arguments/' + arg.id).update({
                        "isPublic": true,
                        "upvotesFor": 0,
                        "upvotesAgainst": 0,
                        "for": [],
                        "against": [],
                        "totalUpvotes": 0,
                        "endingAt": startOfLastHourInSecs + (1 * 3600)
                    }
                    )
                }
            })

            if (archiving) {
                return Promise.all(promises)
            }
            else {
                return promise
            }

        }
        else {
            return promise
        }

    }).catch(err => {
        console.log("error")
        console.log(err)
        res.send(err)
    })
}
)