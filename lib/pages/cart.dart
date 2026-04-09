import 'dart:convert';
import 'dart:async';
import 'package:bits_n_bytes_ui/services/log_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:bits_n_bytes_ui/components/app_bar.dart';
import 'package:bits_n_bytes_ui/components/cart_item.dart';
import 'package:bits_n_bytes_ui/database/models/item.dart';
import 'package:bits_n_bytes_ui/database/models/user.dart';
import 'package:bits_n_bytes_ui/pages/door_closed.dart';
import 'package:bits_n_bytes_ui/pages/welcome.dart';
import '../services/serial_service.dart';

class CartPage extends StatefulWidget {
  final User user;
  const CartPage({super.key, required this.user});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Item> cart = [];
  
  // Guard to prevent multiple navigation triggers
  bool _isNavigating = false;

  User get user => widget.user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initPorts(); // Your function that calls SerialService().startListening()
    });
  }

  void _initPorts() async {
    // Init Cart Listener
    SerialService().jetsonState.addListener(() {
      Map<String, dynamic>? json = SerialService().jetsonState.value;
      if (json == null) {
        LogService.logEvent("cart: jetson state null");
        return;
      }

      if (json.containsKey('id') && json.containsKey('quantity')) {
        LogService.logEvent("CART EVENT: Updating...");
        _handleCartUpdate(json['id'] as int, json['quantity'] as int);
      }
    });

    // Init Door Listener
    SerialService().espState.addListener(() {
      Map<String, dynamic>? json = SerialService().espState.value;
      if (json == null) {
        LogService.logEvent("cart: esp state null");
        return;
      }

      if (json["doors"] == true && !_isNavigating) {
        LogService.logEvent("DOOR EVENT: Closing detected. Transitioning page...");
        _navigateToDoorClosed();
      }
    });
  }

  void _navigateToDoorClosed() {
    _isNavigating = true;
    
    // Ensure navigation happens on the next frame to avoid context issues
    Future.microtask(() {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => DoorClosedPage(cart: cart, user: user),
        ),
      );
    });
  }

  Future<void> _handleCartUpdate(int id, int quantityDelta) async {
    int existingIndex = cart.indexWhere((item) => item.id == id);

    if (existingIndex != -1) {
      final existingItem = cart[existingIndex];
      int newQuantity = existingItem.quantity + quantityDelta;
      
      setState(() {
        if (newQuantity <= 0) {
          cart.removeAt(existingIndex);
          LogService.logEvent("Item $id removed from cart.");
        } else {
          cart[existingIndex] = Item(
            id: existingItem.id,
            name: existingItem.name,
            imgUrl: existingItem.imgUrl,
            price: existingItem.price,
            quantity: newQuantity,
          );
          LogService.logEvent("Item $id quantity updated to $newQuantity.");
        }
      });
    } else if (quantityDelta > 0) {
      LogService.logEvent("New item $id detected. Fetching details...");
      final url = Uri.parse('${dotenv.env['API_URL']}items/$id');

      try {
        final response = await http.get(
          url,
          headers: {"Authorization": "${dotenv.env['API_AUTH_KEY']}"},
        );

        if (response.statusCode == 200) {
          final Map<String, dynamic> itemData = jsonDecode(response.body);
          final newItem = Item(
            id: itemData['id'],
            name: itemData['name'],
            imgUrl: itemData['thumb_img'],
            price: itemData['price'],
            quantity: quantityDelta,
          );

          setState(() {
            cart.add(newItem);
          });
        }
      } catch (e) {
        LogService.logEvent("Error fetching item $id: $e");
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // UI logic remains the same
    return Scaffold(
      body: Row(
        children: [
          // Main Cart View
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BnBAppBar(
                  title: "Cart",
                  children: [
                    IconButton(
                      icon: const Icon(LucideIcons.arrowRight),
                      onPressed: _navigateToDoorClosed,
                    ),
                  ],
                ),
                Expanded(
                  child: cart.isEmpty
                      ? Center(
                          child: Text(
                            "Welcome ${user.name}\nYour cart is empty, please grab your snacks\nfrom the cabinet to start.\nWe'll do the rest",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) {
                            return CartItem(
                              key: ValueKey(cart[index].id),
                              item: cart[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          
          // Sidebar
          Container(
            width: MediaQuery.sizeOf(context).width / 3,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.1)),
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Cancel Transaction
                TextButton.icon(
                  onPressed: () => Navigator.pushReplacement(
                    context, 
                    MaterialPageRoute(builder: (context) => const WelcomePage())
                  ),
                  icon: const Icon(LucideIcons.circleX, size: 20),
                  label: const Text('Cancel Transaction'),
                  style: TextButton.styleFrom(
                    minimumSize: const Size(300, 50),
                    backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                  ),
                ),
                
                // User Info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Logged in as:"),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(LucideIcons.squarePen, size: 14),
                            label: const Text('Edit', style: TextStyle(fontSize: 14)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text("Payment Method:"),
                      const Text("Dining Dollars", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      
                      const SizedBox(height: 20),
                      // Door Instruction Box
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          color: Theme.of(context).colorScheme.onSurfaceVariant.withAlpha(40),
                        ),
                        child: const Row(
                          children: [
                            Icon(LucideIcons.doorClosed),
                            SizedBox(width: 20),
                            Expanded(child: Text("Finished? Close the doors to complete your transaction.")),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      Center(
                        child: SvgPicture.asset(
                          'assets/images/lockup.svg',
                          width: 275,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}