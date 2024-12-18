// profile_edit_modal.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Profile Controller
class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> updateProfile({
    required BuildContext context,
    required String displayName,
    String? photoURL,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw 'No authenticated user found';
      }

      // Update Firebase Authentication profile
      await currentUser.updateProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      // Update Firestore user document (optional, depending on your data structure)
      await _firestore.collection('users').doc(currentUser.uid).update({
        'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
      });

      // Reload user to get updated information
      await currentUser.reload();

      // Navigate back
      Navigator.of(context).pop();

      // Show bottom snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Profile updated successfully'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

// Profile Edit Modal
class ProfileEditModal extends StatefulWidget {
  const ProfileEditModal({Key? key}) : super(key: key);

  @override
  _ProfileEditModalState createState() => _ProfileEditModalState();
}

class _ProfileEditModalState extends State<ProfileEditModal> {
  final ProfileController _profileController = Get.put(ProfileController());
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _photoUrlController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Populate initial values
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      _nameController.text = currentUser.displayName ?? '';
      _photoUrlController.text = currentUser.photoURL ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _photoUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      title: const Text(
        'Edit Profile',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Profile Picture Preview
              if (_photoUrlController.text.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(_photoUrlController.text),
                    onBackgroundImageError: (_, __) {
                      // Fallback if image fails to load
                      setState(() {
                        _photoUrlController.text = '';
                      });
                    },
                  ),
                ),

              // Display Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Profile Photo URL Field
              TextFormField(
                controller: _photoUrlController,
                decoration: InputDecoration(
                  labelText: 'Profile Photo URL (Optional)',
                  prefixIcon: const Icon(Icons.link),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    // Basic URL validation
                    Uri? uri = Uri.tryParse(value);
                    if (uri == null || !uri.hasAbsolutePath) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel Button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
        ),

        // Save Changes Button
        Obx(() => ElevatedButton(
              onPressed: _profileController.isLoading.value
                  ? null
                  : () {
                      if (_formKey.currentState!.validate()) {
                        _profileController.updateProfile(
                          context: context,
                          displayName: _nameController.text.trim(),
                          photoURL: _photoUrlController.text.trim().isNotEmpty
                              ? _photoUrlController.text.trim()
                              : null,
                        );
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: _profileController.isLoading.value
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Changes'),
            )),
      ],
    );
  }
}
