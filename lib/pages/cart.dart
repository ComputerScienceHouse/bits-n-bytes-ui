import 'dart:convert';
import 'dart:async';
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
import 'package:bits_n_bytes_ui/services/log_service.dart';
import '../services/serial_service.dart';

class CartPage extends StatefulWidget {
  final User user;
  const CartPage({super.key, required this.user});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Item> cart = [];
  bool _isNavigating = false;

  User get user => widget.user;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initHardware();
    });
  }

  void _initHardware() async {
    // Start ESP (Doors)
    await SerialService().startListeningESP();
    SerialService().espState.addListener(_doorListener);

    // Start Jetson (Cart Items)
    await SerialService().startListeningJetson();
    SerialService().jetsonState.addListener(_itemChangeListener);
    
    LogService.logEvent("CartPage: Hardware listeners active.");
  }

  // --- SERIAL LOGIC (DOORS) ---
  void _doorListener() {
    final json = SerialService().espState.value;
    if (json != null && json["doors"] == true && !_isNavigating) {
      LogService.logEvent("SERIAL EVENT: Door closed. Transitioning...");
      _navigateToDoorClosed();
    }
  }

  // --- SERIAL LOGIC (ITEMS) ---
void _itemChangeListener() {
  final json = SerialService().jetsonState.value;
  if (json == null) return; // Exit if null

  _handleCartUpdate(
    (json['id'] as num).toInt(),
    (json['quantity'] as num).toInt(),
  );

  SerialService().jetsonState.value = null; 
}

  // --- CART LOGIC ---
Future<void> _handleCartUpdate(int id, int quantityDelta) async {
  // 1. Find the item
  int existingIndex = cart.indexWhere((item) => item.id == id);
  
  LogService.logEvent("HandleUpdate: ID $id, Delta $quantityDelta, Found at Index $existingIndex");

  if (existingIndex != -1) {
    // ITEM EXISTS - UPDATE OR REMOVE
    final existingItem = cart[existingIndex];
    int newQuantity = existingItem.quantity + quantityDelta;
    
    LogService.logEvent("Updating Item: ${existingItem.name}. Old Qty: ${existingItem.quantity}, New Qty: $newQuantity");

    setState(() {
      if (newQuantity <= 0) {
        LogService.logEvent("Removing item ${existingItem.name} from cart.");
        cart.removeAt(existingIndex);
      } else {
        cart[existingIndex] = Item(
          id: existingItem.id,
          name: existingItem.name,
          imgUrl: existingItem.imgUrl,
          price: existingItem.price,
          quantity: newQuantity,
        );
      }
      // Re-assign the list to ensure the UI notices the change
      cart = List.from(cart);
    });
  } else {
    // ITEM NOT IN CART
    if (quantityDelta > 0) {
      LogService.logEvent("New item detected. Fetching from API...");
      _fetchAndAddItem(id, quantityDelta);
    } else {
      LogService.logEvent("Removal ignored: Item $id not in cart.");
    }
  }
}

  Future<void> _fetchAndAddItem(int id, int quantity) async {
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
          quantity: quantity,
        );
        if (mounted) setState(() => cart.add(newItem));
      }
    } catch (e) {
      LogService.logEvent("Error fetching item $id: $e");
    }
  }

  void _navigateToDoorClosed() {
    if (_isNavigating) return;
    _isNavigating = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DoorClosedPage(cart: cart, user: user),
      ),
    );
  }

  @override
  void dispose() {
    SerialService().espState.removeListener(_doorListener);
    SerialService().jetsonState.removeListener(_itemChangeListener);
    super.dispose();
  }

@override
  Widget build(BuildContext context) {
    // UI remains identical to your design
    return Scaffold(
      body: Row(
        children: [
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
                            "Welcome ${user.name}\nYour cart is empty...",
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 20),
                          ),
                        )
                      : ListView.builder(
                          itemCount: cart.length,
                          itemBuilder: (context, index) => CartItem(
                            key: ValueKey(cart[index].id),
                            item: cart[index],
                          ),
                        ),
                ),
              ],
            ),
          ),
          _buildSidebar(context),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width / 3,
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: Theme.of(context).colorScheme.outline, width: 0.1)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          TextButton.icon(
            onPressed: () => Navigator.pushReplacement(
              context, 
              MaterialPageRoute(builder: (context) => const WelcomePage())
            ),
            icon: const Icon(LucideIcons.circleX),
            label: const Text('Cancel Transaction'),
            style: TextButton.styleFrom(
              minimumSize: const Size(300, 50),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Logged in as:"),
                Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 40),
                Center(child: SvgPicture.asset('assets/images/lockup.svg', width: 275)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}