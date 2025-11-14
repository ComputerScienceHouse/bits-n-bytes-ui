import 'package:bits_n_bytes_ui/database/models/item.dart';
import 'package:flutter/material.dart';
import 'dart:developer';

class CartItem extends StatefulWidget {
  final Item item;

  const CartItem({super.key, required this.item});

  @override
  State<CartItem> createState() => _CartItemState();
}

class _CartItemState extends State<CartItem> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = 2 * MediaQuery.sizeOf(context).width / 3;
    final double availableWidth = screenWidth - 32 - 32;

    return Row(
      children: [
        Container(
          width: screenWidth - 32,
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            // border: Border.all(color: Theme.of(context).colorScheme.outline, width: 0.1),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha(30),
                spreadRadius: 2,
                blurRadius: 2,
                offset: Offset(0, 3),
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network("http://placehold.jp/150x150.png"),
                Column(
                  children: [
                    Text(
                      widget.item.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      "Item Calories, description",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      "\$$widget.item.price",
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  "$widget.item.quantity",
                  style: TextStyle(
                    fontSize: 30,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
