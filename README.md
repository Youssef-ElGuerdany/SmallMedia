# fluttershare 
// to add a new important mehtod :

=> Get users by id
// getUsersById() async {
  //   const String userID = 'BwoqR0NN2du7U4VAEI1c';
  //   final DocumentSnapshot doc = await usersRef.doc(userID).get();
  //   print(doc.id);
  //   //  then((DocumentSnapshot doc) {
  //   //   print(doc.data());
  //   //   print(doc.id);
  //   //   print(doc.exists);
  //   // });
  // }

  => get all users :
  getUsers() async {
    // Get users by query selector Where() , and we can also take multupl Where().where.where()...
    // final QuerySnapshot snapshot = await usersRef.get();
    // limit(1) Query => return one user
    // .where('postCount', isGreaterThan: 10)
    // .where('userName', isEqualTo: 'youssef')
    // .orderBy("postCount", descending: true)
    // .get();

    // setState(() {
    //   users = snapshot.docs;
    // });
  }