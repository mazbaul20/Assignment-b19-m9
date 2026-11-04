import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../database/database_helper.dart';
import '../models/contact_model.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/search_contact_widget.dart';
import 'favorite_contact_screen.dart';

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

  List<ContactModel> _contacts = [];
  ContactModel? _selectedContact;

  @override
  void initState() {
    super.initState();
    _readContact();
  }

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
      setState(() {
        _isFavoriteInput = false;
      });
      await _readContact();
    }
  } // end method

  Future<void> _readContact() async {
    final contacts = await _db.getAllContacts();
    setState(() {
      _contacts = contacts;
    });
  } //end method

  Future<void> _deleteContact(int id) async {
    await _db.deleteContact(id);
    if (!mounted) return;
    showCustomSnackBar(
      context,
      "Contact deleted successfully!",
      isError: false,
    );
    await _readContact();
  } //end method

  void _editContact(ContactModel contact) {
    setState(() {
      _selectedContact = contact;
      _nameController.text = contact.name;
      _phoneNumberController.text = contact.phoneNumber;
      _emailController.text = contact.email;
      _addressController.text = contact.address;
      _isFavoriteInput = contact.isFavourite;
    });
  } //end method

  Future<void> _updateContact() async {
    if (_selectedContact == null) return;

    if (_nameController.text.isEmpty) {
      showCustomSnackBar(context, "Name is required!");
      return;
    }
    if (_phoneNumberController.text.isEmpty) {
      showCustomSnackBar(context, "Phone Number is required!");
      return;
    }
    if (_emailController.text.isEmpty) {
      showCustomSnackBar(context, "Email is required!");
      return;
    }
    if (_addressController.text.isEmpty) {
      showCustomSnackBar(context, "Address is required!");
      return;
    }

    final contact = ContactModel(
      id: _selectedContact!.id,
      name: _nameController.text,
      phoneNumber: _phoneNumberController.text,
      email: _emailController.text,
      address: _addressController.text,
      isFavourite: _isFavoriteInput,
    );

    await _db.updateContact(contact);

    showCustomSnackBar(context, "Contact Updated successful!", isError: false);

    setState(() {
      _selectedContact = null;
      _nameController.clear();
      _phoneNumberController.clear();
      _emailController.clear();
      _addressController.clear();
      _isFavoriteInput = false;
    });

    await _readContact();
  }

  //toggle favorite
  Future<void> _toggleFavorite(int index) async {
    setState(() {
      _contacts[index].isFavourite = !(_contacts[index].isFavourite);
    });

    await _db.updateFavoriteStatus(
      _contacts[index].id!,
      _contacts[index].isFavourite,
    );
    showCustomSnackBar(
      context,
      "Favorite status updated successfully!",
      isError: false,
    );
  } // end method

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Management App'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FavoriteContactScreen(),
                ),
              );
              _readContact();
            },
          ),
          IconButton(
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (BuildContext context) {
                  return SearchContactBottomSheet(
                    onSearchChanged: (query) async {
                      final searchResult = await _db.searchContacts(query);
                      setState(() {
                        _contacts = searchResult;
                      });
                    },
                    onClear: () async {
                      await _readContact();
                    },
                  );
                },
              );
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          await _readContact();
        },
        child: SafeArea(
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
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
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
                          onPressed: () async {
                            if (_selectedContact != null) {
                              await _updateContact();
                            } else {
                              await addContact();
                            }
                          },
                          child: Text(
                            _selectedContact == null ? 'ADD' : 'UPDATE',
                          ),
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

              _contacts.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_off_rounded,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No contacts saved yet!",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        itemCount: _contacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          final contact = _contacts[index];

                          return Card(
                            elevation: 1,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 6.0,
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 25,
                                  backgroundColor: Colors.blue.withAlpha(25),
                                  child: Text(
                                    contact.name.isNotEmpty
                                        ? contact.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  contact.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Column(
                                    crossAxisAlignment: .start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.phone,
                                            size: 14,
                                            color: Colors.blue,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "+88 ${contact.phoneNumber}",
                                            style: TextStyle(
                                              color: Colors.blue[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (contact.email.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            const Icon(
                                              Icons.email,
                                              size: 14,
                                              color: Colors.blue,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              contact.email,
                                              style: TextStyle(
                                                color: Colors.blue[600],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      onPressed: () {
                                        _toggleFavorite(index);
                                      },
                                      icon: Icon(
                                        contact.isFavourite == true
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: Colors.red,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await _deleteContact(contact.id!);
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  _editContact(contact);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
