// lib/screens/favorite_contact_screen.dart

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/contact_model.dart';
import '../widgets/custom_snackbar.dart';

class FavoriteContactScreen extends StatefulWidget {
  const FavoriteContactScreen({super.key});

  @override
  State<FavoriteContactScreen> createState() => _FavoriteContactScreenState();
}

class _FavoriteContactScreenState extends State<FavoriteContactScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  List<ContactModel> _favContacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final data = await _db.getFavoriteContacts();
    setState(() {
      _favContacts = data;
      _isLoading = false;
    });
  }

  Future<void> _toggleFavorite(ContactModel contact) async {
    final updatedContact = ContactModel(
      id: contact.id,
      name: contact.name,
      phoneNumber: contact.phoneNumber,
      email: contact.email,
      address: contact.address,
      isFavourite: false,
    );

    await _db.updateContact(updatedContact);

    setState(() {
      _favContacts.removeWhere((element) => element.id == contact.id);
    });

    if (mounted) {
      showCustomSnackBar(context, "${contact.name} removed from favorites");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Favorite Contacts",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _favContacts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border_rounded,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "No favorites added yet!",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              itemCount: _favContacts.length,
              itemBuilder: (context, index) {
                final contact = _favContacts[index];

                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 25,
                        backgroundColor: Colors.teal.withValues(alpha: 0.1),
                        child: Text(
                          contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
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
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(contact.phoneNumber),
                              ],
                            ),
                            if (contact.email.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.email,
                                    size: 14,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      contact.email,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: 28,
                        ),
                        onPressed: () => _toggleFavorite(contact),
                        tooltip: "Remove from favorites",
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
