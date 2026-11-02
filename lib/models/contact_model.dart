class ContactModel {
  final int? id;
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final bool isFavourite;

  ContactModel({
      this.id,
      required this.name,
      required this.phoneNumber,
      required this.email,
      required this.address,
      required this.isFavourite,
  });

  // sent data to database
  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'address': address,
      'isFavourite': isFavourite ? 1 : 0,
    };
  }//end method

  factory ContactModel.fromMap(Map<String, dynamic> map){
    return ContactModel(
      id: map['id'],
      name: map['name'],
      phoneNumber: map['phoneNumber'],
      email: map['email'],
      address: map['address'],
      isFavourite: map['isFavourite'] == 1,
    );
  }
}