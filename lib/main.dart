import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'edit_profiles_screen.dart';
import 'generate_problems_screen.dart';
import 'Widgets/number_selector.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: const HomePage(),
    theme: ThemeData.dark(useMaterial3: true),
  ));
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const List format = [
    {
      "title": "Addition",
      "body": ["No. of problems", "No. of digits"]
    },
    {
      "title": "Subtraction",
      "body": ["No. of problems", "No. of digits"]
    },
    {
      "title": "Multiplication",
      "body": [
        "No. of problems",
        "No. of digits (multiplier)",
        "No. of digits (multiplicand)"
      ]
    },
    {
      "title": "Division",
      "body": [
        "No. of problems",
        "No. of digits (dividend)",
        "No. of digits (divisor)"
      ]
    }
  ];

  List<Map<String, dynamic>> profiles = [];
  /*
  - Profiles (list)
	  - Profile (map)
		  - name: Name
      - numberOfToggled: No. of toggled
      - operations: Operations (list)
        - Operation (map)
          - toggle: Toggle
          - body: Body (list)
            - No. of problems
            - No. of digits
  */

  List<Panel> panels = [];
  int selectedProfileIndex = 0;

  List<String> profilesMenu = ["Edit..."];
  String selectedProfileMenu = "Edit...";
  bool toggleAllState = false;

  @override
  void initState() {
    super.initState();
    initializeProfiles();
  }

  void initializeProfiles() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    if (prefs.getString("profiles") == null) {
      createProfile("Default");
    } else {
      profiles = List<Map<String, dynamic>>.from(
          jsonDecode(prefs.getString("profiles")!));
      for (Map<String, dynamic> profile in profiles) {
        profilesMenu.add(profile["name"]);
      }
    }
    selectProfile(0);
  }

  void toggleAll(bool toggleState) {
    setState(() {
      toggleAllState = toggleState;

      for (var i = 0; i < panels.length; i++) {
        var panel = panels[i];
        panel.toggle = toggleState;
        panel.controller.value = toggleState;
        profiles[selectedProfileIndex]["operations"][i]["toggle"] = toggleState;
      }
      profiles[selectedProfileIndex]["numberOfToggled"] =
          toggleState ? format.length : 0;
    });
    saveProfilesToLocalStorage();
  }

  void createProfile(String name) {
    setState(() {
      profilesMenu.add(name);
      Map<String, dynamic> profile = {"name": name};
      profile["operations"] = [];
      for (var operation in format) {
        profile["operations"].add({
          "toggle": false,
          "body": List.filled(operation["body"].length, 5)
        });
      }
      profile["numberOfToggled"] = 0;
      profiles.add(profile);
    });
    saveProfilesToLocalStorage();
  }

  void editProfile(int index, String value) {
    setState(() {
      if (index == selectedProfileIndex) {
        selectedProfileMenu = value;
      }
      profilesMenu[index + 1] = value;
      profiles[index]["name"] = value;
    });
    saveProfilesToLocalStorage();
  }

  void selectProfile(int index) {
    setState(() {
      selectedProfileMenu = profilesMenu[index + 1];
      selectedProfileIndex = index;
      panels = format.map((operation) {
        List<List<dynamic>> body = [];
        for (var i = 0; i < operation["body"].length; i++) {
          body.add([
            operation["body"][i],
            profiles[selectedProfileIndex]["operations"]
                [format.indexOf(operation)]["body"][i]
          ]);
        }
        return Panel(
          title: operation["title"],
          body: body,
          controller: ExpandableController(),
          toggle: profiles[selectedProfileIndex]["operations"]
              [format.indexOf(operation)]["toggle"],
        );
      }).toList();

      // If all toggled/untoggled, change toggleAllState
      toggleAllState = (profiles[index]["numberOfToggled"] == format.length);
    });
  }

  void removeProfile(int index) {
    setState(() {
      profiles.removeAt(index);
      profilesMenu.removeAt(index + 1);
    });
    saveProfilesToLocalStorage();
  }

  void saveProfilesToLocalStorage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("profiles", jsonEncode(profiles));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        label: const Text("Generate", style: TextStyle(fontSize: 20)),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => GenerateProblemsScreen(
                      profile: profiles[selectedProfileIndex])));
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      appBar: AppBar(
        title: const Text("ProblemsPal"),
        actions: [
          IconButton(
            icon: toggleAllState
                ? const Icon(Icons.toggle_on_outlined)
                : const Icon(Icons.toggle_off_outlined),
            onPressed: () {
              setState(() {
                toggleAllState = !toggleAllState;
              });
              toggleAll(toggleAllState);
            },
          ),

          // Profiles Dropdown
          DropdownButton(
              value: selectedProfileMenu,
              items: profilesMenu.map((profile) {
                return DropdownMenuItem(
                    value: profile,
                    child: Text(
                      profile,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                    ));
              }).toList(),
              onChanged: (value) {
                if (value == "Edit...") {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditProfilesScreen(
                              profileNames: profilesMenu.sublist(2),
                              currentProfile: selectedProfileMenu,
                              createProfile: createProfile,
                              editProfile: editProfile,
                              selectProfile: selectProfile,
                              removeProfile: removeProfile)));
                } else {
                  setState(() {
                    selectedProfileMenu = value!;
                  });
                  selectProfile(profilesMenu.indexOf(value!) - 1);
                }
              })
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: panels.length,
        itemBuilder: (BuildContext context, int index) {
          return ExpandablePanel(
              controller: panels[index].controller,
              collapsed: panelColumn(index, false),
              expanded: panelColumn(index, true));
        },
      ),
    );
  }

  Column panelColumn(int index, bool expanded) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    panels[index].title,
                    style: const TextStyle(fontSize: 24),
                  ),
                  Builder(builder: (context) {
                    // Toggle
                    return Switch(
                        value: panels[index].toggle,
                        onChanged: (value) {
                          setState(() {
                            panels[index].toggle = value;
                            profiles[selectedProfileIndex]["operations"][index]
                                ["toggle"] = value;
                            panels[index].controller.toggle();

                            // If toggled, increment/decrement numberOfToggled
                            profiles[selectedProfileIndex]["numberOfToggled"] +=
                                value ? 1 : -1;

                            // If all toggled/untoggled, change toggleAllState
                            if (profiles[selectedProfileIndex]
                                    ["numberOfToggled"] ==
                                format.length) {
                              toggleAllState = value;
                            }
                          });
                          saveProfilesToLocalStorage();
                        });
                  })
                ],
              ),
              if (expanded)
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: panels[index].body.length,
                    itemBuilder: (BuildContext context, int bodyIndex) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(panels[index].body[bodyIndex][0]),
                          ElevatedButton(
                            child: Text("${panels[index].body[bodyIndex][1]}"),
                            onPressed: () {
                              final FixedExtentScrollController
                                  scrollController =
                                  FixedExtentScrollController(
                                      initialItem:
                                          panels[index].body[bodyIndex][1] - 1);
                              NumberSelector(
                                  scrollController: scrollController,
                                  context: context,
                                  title: format[index]["body"][bodyIndex],
                                  extent: 10,
                                  onSubmit: (int value) {
                                    setState(() {
                                      panels[index].body[bodyIndex][1] = value;
                                      profiles[selectedProfileIndex]
                                              ["operations"][index]["body"]
                                          [bodyIndex] = value;
                                    });
                                    saveProfilesToLocalStorage();
                                  }).dialog();
                            },
                          )
                        ],
                      );
                    }),
            ],
          ),
        ),
        const Divider()
      ],
    );
  }
}

class Panel {
  String title;
  List<List> body;
  bool toggle;
  ExpandableController controller;

  Panel(
      {required this.title,
      required this.body,
      required this.controller,
      this.toggle = false}) {
    controller.value = toggle;
  }
}
