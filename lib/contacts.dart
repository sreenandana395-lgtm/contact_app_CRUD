import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {
  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
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
                      ElevatedButton(
                        onPressed: () {},
                        child: Text("ADD"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                        ),
                        
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
        ],
      ),
    );
  }
}
