import 'dart:convert';

import 'package:bits_n_bytes_ui/components/app_bar.dart';
import 'package:bits_n_bytes_ui/components/cart_item.dart';
import 'package:bits_n_bytes_ui/database/models/item.dart';
import 'package:bits_n_bytes_ui/database/models/user.dart';
import 'package:bits_n_bytes_ui/pages/door_closed.dart';
import 'package:bits_n_bytes_ui/pages/welcome.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/uart.dart';
import 'dart:async';
import 'dart:developer';

class CartPage extends StatefulWidget {
  final User user;

  const CartPage({super.key, required this.user});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<Item> cart = [];
  StreamSubscription<SerialDataPacket>? _doorSubscription;
  StreamSubscription<SerialDataPacket>? _cartSubscription;
  User get user => widget.user;

  @override
  void initState() {
    super.initState();
    _initPorts();
  }

  void _initPorts() async {
    bool success = await SerialService().startListening(
      SerialService.portJetson,
      protocol: SerialProtocol.json,
    );

    if (!success) {
      log("CartPage: FAILED to start listening on $SerialService.portJetson");
    }

    _cartSubscription = SerialService().dataStream
        .where(
          (packet) =>
              packet.portName == SerialService.portJetson &&
              packet.protocol == SerialProtocol.json,
        )
        .listen((packet) {
          log(packet.toString());
          log("CART LISTENER received: ${packet.data}");
          final Map<String, dynamic> jsonData =
              packet.data as Map<String, dynamic>;

          if (jsonData.containsKey('id') && jsonData.containsKey('quantity')) {
            _handleCartUpdate(
              jsonData['id'] as int,
              jsonData['quantity'] as int,
            );
          }
        });

    bool espSuccess = await SerialService().startListening(
      SerialService.portESP,
      protocol: SerialProtocol.json,
    );

    if (!espSuccess) {
      log("CartPage: FAILED to start listening on $SerialService.portESP");
      return;
    }

    _doorSubscription = SerialService().dataStream
        .where(
          (packet) =>
              packet.portName == SerialService.portESP &&
              packet.protocol == SerialProtocol.json,
        )
        .listen((packet) {
          log("CART PAGE received data: $packet");

          if (packet.protocol == SerialProtocol.json) {
            final Map<String, dynamic> jsonData =
                packet.data as Map<String, dynamic>;
            // Doors are now closed
            if (jsonData.containsKey('doors')) {
              if (jsonData['doors'] == true) {
                // If we get the event, navigate
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DoorClosedPage(cart: cart, user: user),
                  ),
                );
              }
            }
          }
        });
  }

  Future<void> _handleCartUpdate(int id, int quantityDelta) async {
    // Check if the item is already in the cart
    int existingIndex = cart.indexWhere((item) => item.id == id);

    if (existingIndex != -1) {
      final existingItem = cart[existingIndex];
      int newQuantity = existingItem.quantity + quantityDelta;
      if (newQuantity == 0) {
        setState(() {
          cart.removeAt(existingIndex);
        });
        log("Item $id removed from cart.");
      } else {
        // Quantity has changed, update it
        cart[existingIndex] = Item(
          id: existingItem.id,
          name: existingItem.name,
          imgUrl: existingItem.imgUrl,
          price: existingItem.price,
          quantity: newQuantity,
        );
        setState(() {}); // Update UI
        log("Item $id quantity updated to $newQuantity.");
      }
    } else if (quantityDelta > 0) {
      // --- NEW ITEM TO ADD (and quantity > 0) ---
      log("New item $id detected. Fetching details...");

      // !!! IMPORTANT !!!
      // Replace 'https://your-api.com/items/' with your actual API endpoint
      final url = Uri.parse('${dotenv.env['API_URL']}items/$id');

      try {
        final response = await http.get(
          url,
          headers: {"Authorization": "${dotenv.env['API_AUTH_KEY']}"},
        );

        if (response.statusCode == 200) {
          // API call was successful
          final Map<String, dynamic> itemData = jsonDecode(response.body);

          // Create the new item using API data + packet quantity
          final newItem = Item(
            id: itemData['id'], // Assumes API returns 'id'
            name: itemData['name'], // Assumes API returns 'name'
            imgUrl: itemData['thumb_img'], // Assumes API returns 'imgUrl'
            price: itemData['price'], // Assumes API returns 'price'
            quantity: quantityDelta, // Use the quantity from the packet
          );

          setState(() {
            cart.add(newItem);
          });
          log("Item $id added to cart.");
        } else {
          log("Failed to fetch item $id. Status: ${response.statusCode}");
        }
      } catch (e) {
        log("Error fetching item $id: $e");
      }
    }
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    _doorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 4. MOVED BnBAppBar here
                BnBAppBar(
                  title: "Cart",
                  children: [
                    IconButton(
                      icon: Icon(LucideIcons.arrowRight),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute<void>(
                            builder: (context) =>
                                DoorClosedPage(cart: cart, user: user),
                          ),
                        );
                      },
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
                              // Use UniqueKey to ensure Flutter rebuilds correctly if order changes
                              key: ValueKey(cart[index]),
                              item: cart[index],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
          Container(
            width: MediaQuery.sizeOf(context).width / 3,
            alignment: Alignment.centerRight,
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: Theme.of(context).colorScheme.outline,
                  width: 0.1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withAlpha(50),
                  spreadRadius: 2,
                  blurRadius: 2,
                  offset: Offset(0, 3),
                ),
              ],
              color: Theme.of(context).colorScheme.surface,
            ),
            child: Container(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const WelcomePage(),
                        ),
                      );
                    },
                    icon: SizedBox.square(
                      dimension: 20,
                      child: Icon(LucideIcons.circleX),
                    ),
                    style: TextButton.styleFrom(
                      minimumSize: Size(300, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadiusGeometry.circular(10),
                      ),
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.secondaryContainer,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onSecondary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 0,
                        vertical: 0,
                      ),
                    ),
                    label: Text('Cancel Transaction'),
                  ),
                  Container(
                    margin: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Logged in as:"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.name,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton.icon(
                              onPressed: () => {},
                              icon: Icon(LucideIcons.squarePen, size: 14),
                              style: TextButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadiusGeometry.circular(
                                    10,
                                  ),
                                ),
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.onPrimaryContainer.withAlpha(60),
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                                padding: EdgeInsets.symmetric(
                                  vertical: 0,
                                  horizontal: 0,
                                ),
                              ),
                              label: Text(
                                'Edit',
                                style: TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Payment Method:"),
                              Text(
                                "Dining Dollars",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 20),
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            border: Border(
                              left: BorderSide(
                                color: Theme.of(context).colorScheme.outline,
                                width: 0.1,
                              ),
                            ),
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant.withAlpha(40),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              SizedBox(width: 10),
                              Icon(LucideIcons.doorClosed),
                              SizedBox(width: 20),
                              Flexible(
                                child: Text(
                                  "Finished? Close the doors to complete your transaction.",
                                  textAlign: TextAlign.left,
                                ),
                              ),
                              SizedBox(width: 10),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 199),
                          alignment: AlignmentDirectional.center,
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
          ),
        ],
      ),
    );
  }
}
