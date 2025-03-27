import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connexion Equihorizon',
      theme: ThemeData(
        primaryColor: Color(0xFFA67C52),
        scaffoldBackgroundColor: Color(0xFFF5F5DC),
        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
      ),
      home: LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<bool> _callYourApi(String username, String password) async {
    final response = await http.post(
Uri.parse('http://192.168.37.45/equihorizon/nouveau/api.php'),
      body: {
        'username': username,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] == true;
    } else {
      return false;
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      bool isValid = await _callYourApi(
        _usernameController.text,
        _passwordController.text,
      );

      setState(() {
        _isLoading = false;
      });

      if (isValid) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomePage()),
        );
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Erreur'),
            content: Text('Identifiants incorrects'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24.0),
            margin: EdgeInsets.symmetric(horizontal: 24.0),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 20,
                  spreadRadius: 1,
                  offset: Offset(4, 4),
                ),
              ],
              border: Border.all(
                color: Color(0xFFA67C52).withOpacity(0.3),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'EQUIHORIZON',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D2D2D),
                    letterSpacing: 1.5,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Bienvenue sur votre espace de gestion cavalier',
                  style: GoogleFonts.montserrat(
                    fontSize: 16,
                    color: Color(0xFF707070),
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildTextField(
                        controller: _usernameController,
                        label: 'Nom d\'utilisateur',
                        icon: Icons.person,
                      ),
                      SizedBox(height: 16),
                      _buildTextField(
                        controller: _passwordController,
                        label: 'Mot de passe',
                        icon: Icons.lock,
                        isPassword: true,
                      ),
                      SizedBox(height: 32),
                      _isLoading
                          ? CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFA67C52),
                                padding: EdgeInsets.symmetric(
                                  vertical: 14.0,
                                  horizontal: 64.0,
                                ),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              ),
                              child: Text(
                                'Connexion',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Color(0xFFA67C52)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.95),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Color(0xFFA67C52)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide(color: Color(0xFF3A5A40), width: 2.0),
        ),
      ),
      validator: (value) =>
          value == null || value.isEmpty ? 'Ce champ est obligatoire' : null,
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  static const List<Widget> _pages = <Widget>[
    ProfilePage(),
    CoursesPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Cours',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xFFA67C52),
        onTap: _onItemTapped,
      ),
    );
  }
}

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  void _logout(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Profil du cavalier', style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _logout(context),
            icon: Icon(Icons.logout),
            label: Text('Déconnexion'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFA67C52),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Cours {
  final String id;
  final String libelle;
  final String heureDebut;
  final String heureFin;
  final String jour;

  Cours({
    required this.id,
    required this.libelle,
    required this.heureDebut,
    required this.heureFin,
    required this.jour,
  });

  factory Cours.fromJson(Map<String, dynamic> json) {
    return Cours(
      id: json['idcours'].toString(),
      libelle: json['libcours'],
      heureDebut: json['hdebut'],
      heureFin: json['hfin'],
      jour: json['jour'],
    );
  }
}

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  _CoursesPageState createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  late Future<List<Cours>> _coursList;

  @override
  void initState() {
    super.initState();
    _coursList = fetchCours();
  }

  Future<List<Cours>> fetchCours() async {
    final response = await http.get(
      Uri.parse('http://192.168.37.45/equihorizon/nouveau/get_cours.php'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Cours.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des cours');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des cours'),
        backgroundColor: Color(0xFFA67C52),
      ),
      body: FutureBuilder<List<Cours>>(
        future: _coursList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun cours trouvé'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final cours = snapshot.data![index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(cours.libelle),
                    subtitle: Text(
                      'Jour : ${cours.jour}\nDe ${cours.heureDebut} à ${cours.heureFin}',
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
