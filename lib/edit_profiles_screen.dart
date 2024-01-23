import 'package:flutter/material.dart';
import 'package:mathproblemsgenerator/Widgets/custom_dialog.dart';

class EditProfilesScreen extends StatefulWidget {
  final List<String> profileNames;
  final String currentProfile;
  final Function(String) createProfile;
  final Function(int, String) editProfile;
  final Function(int) selectProfile;
  final Function(int) removeProfile;

  const EditProfilesScreen(
      {super.key,
      required this.profileNames,
      required this.currentProfile,
      required this.createProfile,
      required this.editProfile,
      required this.selectProfile,
      required this.removeProfile});

  @override
  State<EditProfilesScreen> createState() => _EditProfilesScreenState();
}

class _EditProfilesScreenState extends State<EditProfilesScreen> {
  List<String> profiles = [];

  final GlobalKey<AnimatedListState> listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    setState(() {
      profiles = widget.profileNames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          TextEditingController controller = TextEditingController();
          FocusNode node = FocusNode();
          CustomDialog(
              context: context,
              title: "Add profile",
              controller: controller,
              node: node,
              profiles: profiles,
              onSubmit: (String value) {
                setState(() {
                  profiles.add(value);
                });
                listKey.currentState!.insertItem(profiles.length - 1);
                widget.createProfile(value);
              }).dialog();
        },
        child: const Icon(Icons.add),
      ),
      appBar: AppBar(
        title: const Text("MPG"),
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (profiles.isEmpty) const Text("No profiles added"),
          AnimatedList(
              key: listKey,
              initialItemCount: profiles.length,
              itemBuilder: (context, index, animation) {
                return _buildItem(profiles[index], index, animation);
              }),
        ],
      ),
    );
  }

  SizeTransition _buildItem(
      String profile, int index, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ListTile(
        title: Text(profile),
        trailing: Wrap(children: [
          // Edit button
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              TextEditingController controller =
                  TextEditingController(text: profile);
              FocusNode node = FocusNode();
              CustomDialog(
                  context: context,
                  title: "Edit profile",
                  controller: controller,
                  node: node,
                  profiles: profiles,
                  onSubmit: (String value) {
                    setState(() {
                      profiles[index] = value;
                    });
                    widget.editProfile(index + 1, value);
                  }).dialog();

              // Select all text
              controller.selection = controller.selection.copyWith(
                  baseOffset: 0, extentOffset: controller.text.length);
            },
          ),

          // Delete button
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                if (profiles.contains(profile)) {
                  // If the profile is the current profile, select the default profile
                  if (profile == widget.currentProfile) {
                    widget.selectProfile(0);
                  }
                  widget.removeProfile(index + 1);
                  setState(() {
                    profiles.remove(profile);
                  });
                  listKey.currentState!.removeItem(index, (context, animation) {
                    return _buildItem(profile, index, animation);
                  });
                }
              }),
        ]),
      ),
    );
  }
}
