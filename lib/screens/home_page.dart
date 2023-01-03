import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:weight_tracker/screens/login_screen.dart';
import 'package:weight_tracker/shared/providers/user_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _editingController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          children: [
            const SizedBox(height: 32),
            Form(
              key: _formKey,
              child: TextFormField(
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(),
                validator: (val) {
                  if (val!.isEmpty) {
                    return 'Please type your weight';
                  } else if (double.parse(val) <= 0.0) {
                    return 'Please type your weight correctly';
                  }
                  return null;
                },
                decoration: const InputDecoration(
                  label: Text('weight'),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      EdgeInsets.only(left: 24, right: 24, top: 10, bottom: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.black,
                  ),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                  side: MaterialStateProperty.all(const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  )),
                  elevation: MaterialStateProperty.all(8),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all(
                    const Size(200, 50),
                  )),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  print(_weightController);
                  context.read<UserProvider>().addWeightToFirebaseCollection(
                      weight: double.parse(_weightController.text));
                  _weightController.text = '';
                }
              },
              child: const FittedBox(
                child: Text(
                  'add weight',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            StreamBuilder<dynamic>(
                // listening to the user document in firebase.
                stream: FirebaseFirestore.instance
                    .collection("weight_collection")
                    .doc(context.read<UserProvider>().id)
                    .snapshots(),
                builder: (BuildContext context, snapshot) {
                  switch (snapshot.connectionState) {
                    case ConnectionState.none:
                    case ConnectionState.waiting:
                      return const Center(
                        child: CircularProgressIndicator.adaptive(),
                      );
                    case ConnectionState.active:
                    case ConnectionState.done:
                      if (snapshot.hasError) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      } else if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator.adaptive());
                      } else if (snapshot.data?.data() != null) {
                        List<dynamic> data = snapshot.data?.data()['weight'];
                        return Expanded(
                            child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: data.length,
                          itemBuilder: (context, i) => Container(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Card(
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8)),
                                child: ListTile(
                                  title: Text('${data[i]['weight']} KG'),
                                  subtitle: Text(DateFormat('dd-MM-yy hh:mm a')
                                      .format(DateTime.parse(data[i]['date']))),
                                  trailing: SizedBox(
                                    width: 60,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        GestureDetector(
                                            onTap: () async {
                                              return showDialog<void>(
                                                context: context,
                                                barrierDismissible:
                                                    false, // user must tap button!
                                                builder: (context) {
                                                  return AlertDialog(
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              16),
                                                    ),
                                                    title: const Text(
                                                      "edit weight",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 16),
                                                    ),
                                                    content: TextFormField(
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .digitsOnly
                                                      ],
                                                      controller:
                                                          _editingController,
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(),
                                                      validator: (val) {
                                                        if (val!.isEmpty) {
                                                          return 'Please type your weight';
                                                        } else if (double.parse(
                                                                val) <=
                                                            0.0) {
                                                          return 'Please type your weight correctly';
                                                        }
                                                        return null;
                                                      },
                                                      decoration:
                                                          const InputDecoration(
                                                        label: Text('weight'),
                                                        filled: true,
                                                        fillColor: Colors.white,
                                                        contentPadding:
                                                            EdgeInsets.only(
                                                                left: 24,
                                                                right: 24,
                                                                top: 10,
                                                                bottom: 10),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                            Radius.circular(8),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    actions: <Widget>[
                                                      TextButton(
                                                        child: const Text(
                                                          'Confirm',
                                                        ),
                                                        onPressed: () async {
                                                          data[i]['weight'] =
                                                              double.parse(
                                                                  _editingController
                                                                      .text);
                                                          await context
                                                              .read<
                                                                  UserProvider>()
                                                              .editSpecificWeight(
                                                                  data: data);
                                                          _editingController
                                                              .text = '';
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text(
                                                          'Cancel',
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            child: const Icon(
                                              Icons.edit,
                                              size: 25,
                                            )),
                                        GestureDetector(
                                          onTap: () async {
                                            data.removeAt(i);
                                            print('object');
                                            await context
                                                .read<UserProvider>()
                                                .editSpecificWeight(data: data);
                                          },
                                          child: const Icon(
                                            Icons.delete,
                                            size: 25,
                                            color: Colors.red,
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ));
                      }
                  }
                  return const Expanded(
                      child: Text(
                    'No weights added! ,please add some',
                    style: TextStyle(fontSize: 20),
                  ));
                }),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.black,
                  ),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
                  side: MaterialStateProperty.all(const BorderSide(
                    color: Colors.transparent,
                    width: 1,
                  )),
                  elevation: MaterialStateProperty.all(8),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  fixedSize: MaterialStateProperty.all(
                    const Size(200, 50),
                  )),
              onPressed: () async {
                try {
                  await context.read<UserProvider>().logout();
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) => const LoginScreen()),
                      (route) => false);
                } catch (e) {
                  print(e);
                }
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.logout),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'logout',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
