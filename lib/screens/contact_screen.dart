import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';
import '../models/contact_model.dart';
import '../widgets/custom_snackbar.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  bool _isFavoriteInput = false;

  //database helper
  final DatabaseHelper _db = DatabaseHelper();

  Future<void> addContact() async {
    if (_nameController.text.isEmpty) {
      showCustomSnackBar(context, "Name is required!");
      return;
    } else if (_phoneNumberController.text.isEmpty) {
      showCustomSnackBar(context, "Phone Number is required!");
      return;
    } else if (_emailController.text.isEmpty) {
      showCustomSnackBar(context, "Email is required!");
      return;
    } else if (_addressController.text.isEmpty) {
      showCustomSnackBar(context, "Address is required!");
      return;
    } else {
      final contact = ContactModel(
        name: _nameController.text,
        phoneNumber: _phoneNumberController.text,
        email: _emailController.text,
        address: _addressController.text,
        isFavourite: _isFavoriteInput,
      );

      await _db.insertContact(contact);
      showCustomSnackBar(
        context,
        "Contact added successfully!",
        isError: false,
      );

      _nameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _addressController.clear();
    }
  }// end method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Management App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [IconButton(icon: const Icon(Icons.search), onPressed: () {})],
      ),

      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Name',
                        label: Text('Name'),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _phoneNumberController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Phone Number',
                        label: Text('Phone Number'),
                      ),
                    ),
                    const SizedBox(height: 14),

                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Email',
                        label: Text('Email'),
                      ),
                    ),

                    SizedBox(height: 10),

                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Address',
                        label: Text('Address'),
                      ),
                    ),

                    SizedBox(height: 10),

                    SwitchListTile(
                      title: const Text('Add to Favorites?'),
                      subtitle: const Text(
                        'Mark this contact as a favorite immediately',
                      ),
                      value: _isFavoriteInput,
                      activeThumbColor: Colors.red,
                      secondary: Icon(
                        _isFavoriteInput
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: _isFavoriteInput ? Colors.red : Colors.grey,
                      ),
                      onChanged: (bool value) {
                        setState(() {
                          _isFavoriteInput = value;
                        });
                      },
                    ),

                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: () {
                          addContact();
                        },
                        child: Text("ADD"),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Divider(thickness: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.only(left: 14.0),
              child: Text(
                'Contact List',
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
            ),
            Divider(),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 10,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    leading: const CircleAvatar(
                      radius: 20,
                      child: Icon(Icons.person, color: Colors.blue),
                    ),
                    title: Text('Contact $index'),
                    subtitle: Text("+880 123456789"),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.favorite_border, color: Colors.red),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(Icons.delete, color: Colors.red),
                        ),
                      ],
                    ),
                    onTap: () {},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
