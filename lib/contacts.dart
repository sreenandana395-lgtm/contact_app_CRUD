import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:contact_app/serives.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// Modern slate palette color constants
class AppColors {
  static const Color slate50 = Color(0xFFF8FAFC);
  static const Color slate100 = Color(0xFFF1F5F9);
  static const Color slate200 = Color(0xFFE2E8F0);
  static const Color slate300 = Color(0xFFCBD5E1);
  static const Color slate400 = Color(0xFF94A3B8);
  static const Color slate500 = Color(0xFF64748B);
  static const Color slate600 = Color(0xFF475569);
  static const Color slate700 = Color(0xFF334155);
  static const Color slate800 = Color(0xFF1E293B);
  static const Color slate900 = Color(0xFF0F172A);
  
  static const Color primary = Color(0xFF6366F1); // Indigo 500
  static const Color primaryDark = Color(0xFF4F46E5); // Indigo 600
  static const Color teal = Color(0xFF14B8A6); // Teal 500
  static const Color emerald = Color(0xFF10B981); // Emerald 500
  static const Color red = Color(0xFFEF4444); // Red 500
}

class Contacts extends StatefulWidget {
  const Contacts({super.key});

  @override
  State<Contacts> createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController numbercontroller = TextEditingController();
  final TextEditingController searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    searchController.addListener(() {
      setState(() {
        _searchQuery = searchController.text;
      });
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    namecontroller.dispose();
    numbercontroller.dispose();
    super.dispose();
  }

  // Generate deterministic gradient for contact profile avatar based on name hash
  LinearGradient _getAvatarGradient(String name) {
    final List<List<Color>> gradients = [
      [Color(0xFF8B5CF6), Color(0xFFEC4899)], // Purple to Pink
      [Color(0xFF3B82F6), Color(0xFF06B6D4)], // Blue to Cyan
      [Color(0xFF10B981), Color(0xFF059669)], // Emerald to Green
      [Color(0xFFF59E0B), Color(0xFFEF4444)], // Amber to Red
      [Color(0xFF6366F1), Color(0xFF8B5CF6)], // Indigo to Purple
      [Color(0xFFEC4899), Color(0xFFF43F5E)], // Pink to Rose
    ];
    if (name.trim().isEmpty) {
      return const LinearGradient(colors: [AppColors.slate600, AppColors.slate800]);
    }
    int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    int index = hash % gradients.length;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: gradients[index],
    );
  }

  // Get initials of contact name (up to 2 letters)
  String _getInitials(String name) {
    if (name.trim().isEmpty) return "?";
    List<String> parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return (parts[0][0] + parts[1][0]).toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  // Keep the original editbox function name and logical signature
  void editbox(DocumentSnapshot doc) {
    namecontroller.text = doc["name"] ?? "";
    numbercontroller.text = doc["number"] ?? "";
    _showContactBottomSheet(context: context, doc: doc);
  }

  // Beautiful Bottom Sheet for Add and Edit actions
  void _showContactBottomSheet({required BuildContext context, DocumentSnapshot? doc}) {
    final isEditing = doc != null;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.slate800,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 20,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Drag indicator
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    isEditing ? "EDIT CONTACT" : "NEW CONTACT",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Name field
                  TextFormField(
                    controller: namecontroller,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    validator: (val) => (val == null || val.trim().isEmpty) ? "Please enter a name" : null,
                    decoration: InputDecoration(
                      labelText: "Full Name",
                      labelStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
                      hintText: "Enter contact name",
                      hintStyle: const TextStyle(color: AppColors.slate600, fontSize: 14),
                      prefixIcon: const Icon(Icons.person_outline, color: AppColors.slate400),
                      filled: true,
                      fillColor: AppColors.slate900.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Number field
                  TextFormField(
                    controller: numbercontroller,
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    keyboardType: TextInputType.phone,
                    validator: (val) => (val == null || val.trim().isEmpty) ? "Please enter a phone number" : null,
                    decoration: InputDecoration(
                      labelText: "Phone Number",
                      labelStyle: const TextStyle(color: AppColors.slate400, fontSize: 14),
                      hintText: "Enter number",
                      hintStyle: const TextStyle(color: AppColors.slate600, fontSize: 14),
                      prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.slate400),
                      filled: true,
                      fillColor: AppColors.slate900.withOpacity(0.4),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Actions row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withOpacity(0.2)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text(
                            "CANCEL",
                            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            gradient: const LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                if (isEditing) {
                                  await updatecontact(
                                    doc.id,
                                    namecontroller.text.trim(),
                                    numbercontroller.text.trim(),
                                    context,
                                  );
                                } else {
                                  await addcontact(
                                    namecontroller.text.trim(),
                                    numbercontroller.text.trim(),
                                    context,
                                  );
                                }
                                if (context.mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              isEditing ? "UPDATE" : "ADD",
                              style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Elegant Detail Panel Modal Sheet
  void _showContactDetailsSheet(DocumentSnapshot doc) {
    final name = doc["name"] ?? "";
    final number = doc["number"] ?? "";

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppColors.slate900,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.5),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Pull Bar
              Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 25),
              // Gradient Initials Avatar
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: _getAvatarGradient(name),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    )
                  ],
                ),
                child: Center(
                  child: Text(
                    _getInitials(name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Contact Name Text
              Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Contact Number Text
              Text(
                number,
                style: const TextStyle(
                  color: AppColors.slate400,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 35),
              // Quick action options row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionCircle(
                    icon: Icons.phone_rounded,
                    label: "Call",
                    color: AppColors.emerald,
                    onTap: () {
                      Navigator.pop(context);
                      makecall(number);
                    },
                  ),
                  _buildActionCircle(
                    icon: Icons.edit_rounded,
                    label: "Edit",
                    color: AppColors.primary,
                    onTap: () {
                      Navigator.pop(context);
                      editbox(doc);
                    },
                  ),
                  _buildActionCircle(
                    icon: Icons.delete_outline_rounded,
                    label: "Delete",
                    color: AppColors.red,
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(doc);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  // Delete Alert Dialog
  void _showDeleteConfirmation(DocumentSnapshot doc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.slate800,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.08)),
          ),
          title: const Text(
            "Delete Contact?",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to delete ${doc["name"]}? This action cannot be undone.",
            style: const TextStyle(color: AppColors.slate300),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "CANCEL",
                style: TextStyle(color: AppColors.slate400, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deletecontact(doc.id, context);
              },
              child: const Text(
                "DELETE",
                style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // Quick Action Builder for Detail Modal
  Widget _buildActionCircle({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
              border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.slate400,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // Keep original signature for makecall
  Future<void> makecall(String number) async {
    final Uri launchUri = Uri(scheme: 'tel', path: number);
    try {
      await launchUrl(launchUri);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Could not launch dialer for $number")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.slate900,
              AppColors.slate800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dynamic & Elegant Dashboard Title Bar
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "CONTACTS",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 28,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Secure Cloud Address Book",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    // Synced indicator
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.cloud_done_rounded, color: AppColors.teal, size: 16),
                          SizedBox(width: 6),
                          Text(
                            "Synced",
                            style: TextStyle(
                              color: AppColors.slate300,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Search Area
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.slate800.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.08), width: 1.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: "Search contacts...",
                      hintStyle: const TextStyle(color: AppColors.slate500, fontSize: 15),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppColors.slate400),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, color: AppColors.slate400),
                              onPressed: () {
                                searchController.clear();
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),

              // "My Card" Profile Widget (Preserved & Styled from original Nandana ListTile)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.white.withOpacity(0.07),
                        Colors.white.withOpacity(0.03),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.primary, width: 2),
                      ),
                      child: const CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.slate700,
                        backgroundImage: NetworkImage(
                          "https://www.shutterstock.com/image-illustration/cute-cartoon-girl-glasses-short-260nw-2651272727.jpg",
                        ),
                      ),
                    ),
                    title: const Text(
                      "Nandana",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: const Text(
                      "My Card",
                      style: TextStyle(
                        color: AppColors.slate400,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // StreamBuilder for contacts
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: getcontactdata(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                            SizedBox(height: 16),
                            Text(
                              "Syncing contacts...",
                              style: TextStyle(color: AppColors.slate400, fontSize: 14),
                            ),
                          ],
                        ),
                      );
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return _buildEmptyState(
                        icon: Icons.people_outline_rounded,
                        title: "No contacts yet",
                        subtitle: "Start building your book by clicking the '+' button below.",
                      );
                    }

                    final contactdata = snapshot.data!.docs;
                    
                    // Filter list dynamically based on search query input
                    final filteredContacts = contactdata.where((doc) {
                      final name = (doc["name"] ?? "").toString().toLowerCase();
                      final number = (doc["number"] ?? "").toString().toLowerCase();
                      final query = _searchQuery.toLowerCase();
                      return name.contains(query) || number.contains(query);
                    }).toList();

                    if (filteredContacts.isEmpty) {
                      return _buildEmptyState(
                        icon: Icons.search_off_rounded,
                        title: "No matches found",
                        subtitle: "We couldn't find any contacts matching \"$_searchQuery\".",
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 80),
                      itemCount: filteredContacts.length,
                      itemBuilder: (context, index) {
                        final doc = filteredContacts[index];
                        final name = doc["name"] ?? "";
                        final number = doc["number"] ?? "";

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: InkWell(
                            onTap: () => _showContactDetailsSheet(doc),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.slate800.withOpacity(0.4),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.05),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  // Colored Avatar Badge
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: _getAvatarGradient(name),
                                    ),
                                    child: Center(
                                      child: Text(
                                        _getInitials(name),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  // Detail Labels
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          number,
                                          style: const TextStyle(
                                            color: AppColors.slate400,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Inline Action Controls
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Quick Call Button
                                      IconButton(
                                        icon: const Icon(Icons.phone_outlined, color: AppColors.teal),
                                        onPressed: () => makecall(number),
                                        tooltip: "Call Contact",
                                      ),
                                      // Popup Menu Action List (Preserved structure, customized style)
                                      PopupMenuButton<String>(
                                        icon: const Icon(Icons.more_vert_rounded, color: AppColors.slate400),
                                        color: AppColors.slate800,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          side: BorderSide(color: Colors.white.withOpacity(0.08)),
                                        ),
                                        onSelected: (value) {
                                          if (value == "Delete") {
                                            _showDeleteConfirmation(doc);
                                          } else if (value == "Edit") {
                                            editbox(doc);
                                          } else if (value == "Call") {
                                            makecall(number);
                                          }
                                        },
                                        itemBuilder: (context) => [
                                          const PopupMenuItem(
                                            value: "Call",
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone_rounded, color: AppColors.slate400, size: 18),
                                                SizedBox(width: 10),
                                                Text("Call", style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          const PopupMenuItem(
                                            value: "Edit",
                                            child: Row(
                                              children: [
                                                Icon(Icons.edit_rounded, color: AppColors.slate400, size: 18),
                                                SizedBox(width: 10),
                                                Text("Edit", style: TextStyle(color: Colors.white)),
                                              ],
                                            ),
                                          ),
                                          PopupMenuItem(
                                            value: "Delete",
                                            child: Row(
                                              children: [
                                                Icon(Icons.delete_rounded, color: Colors.redAccent.shade100, size: 18),
                                                SizedBox(width: 10),
                                                Text("Delete", style: TextStyle(color: Colors.redAccent.shade100)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          namecontroller.clear();
          numbercontroller.clear();
          _showContactBottomSheet(context: context);
        },
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 26),
        ),
      ),
    );
  }

  // Placeholder widget for empty list states
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.03),
              ),
              child: Icon(
                icon,
                size: 64,
                color: AppColors.slate600,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.slate400,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
