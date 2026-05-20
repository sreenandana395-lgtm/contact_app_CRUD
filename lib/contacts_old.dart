import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_app/serives.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Contacts extends StatefulWidget {
  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController numbercontroller = TextEditingController();

  void editbox(DocumentSnapshot doc) {
    namecontroller.text = doc["name"];
    numbercontroller.text = doc["number"];
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            color: Colors.black,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "NEW CONTACT",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                TextField(
                  controller: namecontroller,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "enter name",
                    hintStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Color.fromARGB(255, 245, 242, 242),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: numbercontroller,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    hintText: "enter number",
                    hintStyle: TextStyle(color: Colors.black),
                    filled: true,
                    fillColor: Color.fromARGB(255, 250, 248, 248),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      child: Text("CANCEL"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        updatecontact(
                          doc.id,
                          namecontroller.text,
                          numbercontroller.text,
                          context,
                        );
                      },
                      child: Text("Update"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> makecall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    launchUrl(launchUri);
  }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: const Color.fromARGB(255, 29, 28, 28),
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "CONTACTS",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          child: Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                  content: Container(
                    color: Colors.black,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "NEW CONTACT",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: namecontroller,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "enter name",
                            hintStyle: TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Color.fromARGB(255, 245, 242, 242),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: numbercontroller,
                          style: TextStyle(color: Colors.black),
                          decoration: InputDecoration(
                            hintText: "enter number",
                            hintStyle: TextStyle(color: Colors.black),
                            filled: true,
                            fillColor: Color.fromARGB(255, 250, 248, 248),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                        ),
                        SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {},
                              child: Text("CANCEL"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                addcontact(
                                  namecontroller.text,
                                  numbercontroller.text,
                                  context,
                                );
                              },
                              child: Text("ADD"),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
        body: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: TextField(
                style: TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "search contacts",
                  hintStyle: TextStyle(color: Colors.black),
                  prefixIcon: Icon(Icons.search, color: Colors.black),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.vertical(),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              leading: CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(
                  "https://www.shutterstock.com/image-illustration/cute-cartoon-girl-glasses-short-260nw-2651272727.jpg",
                ),
              ),

              title: Text(
                "Nandana",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            StreamBuilder(
              stream: getcontactdata(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 10),
                        Text("Loading contact"),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 20, color: Colors.white),
                        SizedBox(height: 10),
                        Text(
                          "no contact found",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                }
                final contactdata = snapshot.data!.docs;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: contactdata.length,
                  itemBuilder: (context, index) {
                    final Contact = contactdata[index];
                    return ListTile(
                      trailing: PopupMenuButton(
                        iconColor: Colors.white,
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: "Edit",
                            child: Text(
                              "Edit",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),

                          PopupMenuItem(
                            value: "Delete",
                            child: Text(
                              "Delete",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          PopupMenuItem(
                            value: "Call",
                            child: Text(
                              "Call",
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],

                        onSelected: (value) {
                          if (value == "Delete") {
                            deletecontact(contactdata[index].id, context);
                          }
                          if (value == "Edit") {
                            editbox(contactdata[index]);
                          }
                          if(value == "Call") {
                            makecall(numbercontroller.text);
                          }
                        },
                      ),
                      title: Text(
                        Contact["name"],
                        style: TextStyle(color: Colors.white),
                      ),
                      subtitle: Text(
                        Contact["number"],
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      );
    }
  }
