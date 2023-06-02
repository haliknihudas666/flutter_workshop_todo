import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'ToDo List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _textFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('todos')
              .orderBy('createdAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData &&
                snapshot.connectionState == ConnectionState.waiting) {
              return const Text('Loading...');
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (snapshot.data!.docs.isEmpty) {
              return const Text('No todo. You may rest for a while.');
            } else {
              return ListView.separated(
                itemBuilder: (context, index) {
                  return ListTile(
                    onTap: () {
                      _textFieldController.text =
                          snapshot.data!.docs[index]['title']!;
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Edit Todo'),
                            content: TextField(
                              controller: _textFieldController,
                              decoration: const InputDecoration(
                                hintText: "What do you want to do?",
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  _textFieldController.clear();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  var title = _textFieldController.text;
                                  Navigator.of(context).pop();
                                  _textFieldController.clear();

                                  await FirebaseFirestore.instance
                                      .collection('todos')
                                      .doc(snapshot.data!.docs[index].id)
                                      .set({
                                    'title': title,
                                  }, SetOptions(merge: true));
                                },
                                child: const Text('Add'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                    title: Text(snapshot.data!.docs[index]['title']!),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('todos')
                            .doc(snapshot.data!.docs[index].id)
                            .delete();
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) => const Divider(),
                itemCount: snapshot.data!.docs.length,
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Todo'),
                content: TextField(
                  controller: _textFieldController,
                  decoration: const InputDecoration(
                    hintText: "What do you want to do?",
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _textFieldController.clear();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      var title = _textFieldController.text;
                      Navigator.of(context).pop();
                      _textFieldController.clear();

                      await FirebaseFirestore.instance.collection('todos').add({
                        'title': title,
                        'createdAt': DateTime.now().millisecondsSinceEpoch,
                      });
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        tooltip: 'Add Todo',
        child: const Icon(Icons.add),
      ),
    );
  }
}
