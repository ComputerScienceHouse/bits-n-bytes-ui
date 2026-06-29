import 'package:bits_n_bytes_ui/database/models/item.dart';
import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Container(
          width: screenWidth - 32,
          margin: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            // Flat border instead of a blurred BoxShadow: blur forces an
            // offscreen saveLayer per card on every rebuild (cart rebuilds on
            // each Jetson packet) — the single most expensive op on the Pi GPU.
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
              width: 1,
            ),
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Image.network(
                  widget.item.imgUrl, // <--- Use your dynamic data here
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                        "\$${widget.item.price.toStringAsFixed(2)}",
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "${widget.item.quantity}",
                  style: TextStyle(
                    fontSize: 50,
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
