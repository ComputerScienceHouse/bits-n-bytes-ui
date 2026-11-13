import 'package:bits_n_bytes_ui/components/app_bar.dart';
import 'package:bits_n_bytes_ui/viewmodel/receipt.dart';
import 'package:bits_n_bytes_ui/widgets/torn_paper_clipper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

/// Thin View. All receipt state (countdown, SMS send) lives in
/// [ReceiptViewModel], supplied by the route-scoped ChangeNotifierProvider.
class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  late final ReceiptViewModel _vm = context.read<ReceiptViewModel>();
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _vm.addListener(_onVmChanged);
  }

  void _onVmChanged() {
    // if (_vm.timedOut) _goHome();
  }

  // TODO: hey, we need to create the transaction here with all the data send from other screens
  // aka we need to get the receiptSmsTime and receiptEmailTime

  void _goHome() {
    if (_leaving) return;
    _leaving = true;
    _vm.createTransaction();
    _vm.clearCart();
    context.go('/');
  }

  @override
  void dispose() {
    _vm.removeListener(_onVmChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _vm,
      builder: (context, _) {
        final user = _vm.user;
        final cart = _vm.fullTransaction.items;

        final smsSending = _vm.smsStatus == SendStatus.sending;
        final smsSent = _vm.smsStatus == SendStatus.sent;
        final emailSending = _vm.emailStatus == SendStatus.sending;
        final emailSent = _vm.emailStatus == SendStatus.sent;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
          extendBodyBehindAppBar: true,
          appBar: BnBAppBar(title: "Receipt"),
          body: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // LEFT: RECEIPT
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: kToolbarHeight,
                      bottom: 30,
                    ),
                    child: CustomPaint(
                      foregroundPainter: TornPaperBorderPainter(
                        color: Theme.of(context).colorScheme.outlineVariant,
                        strokeWidth: 1,
                        toothWidth: 12,
                        toothHeight: 8,
                      ),
                      child: ClipPath(
                        clipper: TornPaperClipper(
                          toothWidth: 12,
                          toothHeight: 8,
                        ),
                        child: Container(
                          width: 450,
                          padding: const EdgeInsets.only(
                            top: kToolbarHeight,
                            bottom: 20,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                          ),
                          child: Column(
                            children: [
                              // Upper receipt content
                              Expanded(
                                child: Column(
                                  children: [
                                    Text(
                                      "Thank you!",
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text("Your transaction is complete."),
                                    const SizedBox(height: 20),

                                    // Items fill available space,
                                    // then scroll when necessary.
                                    Flexible(
                                      fit: FlexFit.loose,
                                      child: ListView.builder(
                                        shrinkWrap: true,
                                        padding: EdgeInsets.zero,
                                        itemCount: cart.length,
                                        itemBuilder: (context, index) {
                                          final item = cart[index];

                                          return Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 24,
                                              vertical: 8,
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    "${item.name} (x${item.quantity})",
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  "\$${(item.price * item.quantity).toStringAsFixed(2)}",
                                                  style: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                                    ),

                                    const Divider(),

                                    // Totals stay visible
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 8,
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Subtotal:",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              Text(
                                                "\$${_vm.total.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Tax:",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              const Text(
                                                "\$0.00",
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Divider(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              const Text(
                                                "Total:",
                                                style: TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                "\$${_vm.total.toStringAsFixed(2)}",
                                                style: const TextStyle(
                                                  fontSize: 24,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 5),

                              // Logo pinned to receipt bottom
                              Center(
                                child: SvgPicture.asset(
                                  Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? 'assets/images/dark-lockup.svg'
                                      : 'assets/images/lockup.svg',
                                  width: 180,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // RIGHT: SIDEBAR
              Container(
                width: MediaQuery.sizeOf(context).width / 3,
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                      width: 1,
                    ),
                  ),
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 20),

                      // Logged-in user and help button
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Logged in as:"),
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          TextButton.icon(
                            onPressed: _vm.requestHelpFromUser
                                ? null
                                : () => _vm.requestHelp(user),
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: _vm.requestHelpFromUser
                                  ? Theme.of(context).colorScheme.secondaryFixed
                                  : Theme.of(
                                      context,
                                    ).colorScheme.surfaceContainerHighest,
                              foregroundColor: Theme.of(
                                context,
                              ).colorScheme.onSurface,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                            icon: Icon(
                              _vm.requestHelpFromUser
                                  ? LucideIcons.circleCheck
                                  : Icons.support_agent,
                              size: 16,
                            ),
                            label: Text(
                              _vm.requestHelpFromUser
                                  ? 'Help is on the way!'
                                  : 'Request Help',
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      // Receipt options
                      Expanded(
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                "Would you like a Receipt?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 15),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: (smsSending || smsSent)
                                          ? null
                                          : _vm.sendSmsReceipt,
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        backgroundColor: smsSent
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.secondaryFixed
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                      ),
                                      icon: smsSending
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Icon(
                                              smsSent
                                                  ? LucideIcons.circleCheck
                                                  : LucideIcons.messageSquare,
                                              size: 16,
                                            ),
                                      label: Text(
                                        smsSent
                                            ? 'Receipt Sent!'
                                            : 'Get Text Receipt',
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextButton.icon(
                                      onPressed: (emailSending || emailSent)
                                          ? null
                                          : _vm.sendEmailReceipt,
                                      style: TextButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        backgroundColor: emailSent
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.secondaryFixed
                                            : Theme.of(context)
                                                  .colorScheme
                                                  .surfaceContainerHighest,
                                        foregroundColor: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 16,
                                        ),
                                      ),
                                      icon: emailSending
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : Icon(
                                              emailSent
                                                  ? LucideIcons.circleCheck
                                                  : LucideIcons.mail,
                                              size: 16,
                                            ),
                                      label: Text(
                                        emailSent
                                            ? 'Email Sent!'
                                            : 'Get Email Receipt',
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              if (_vm.smsError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _vm.smsError!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                              if (_vm.emailError != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _vm.emailError!,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                              const SizedBox(height: 30),

                              TextButton(
                                onPressed: _goHome,
                                style: TextButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                                  foregroundColor: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 16,
                                  ),
                                ),
                                child: const Text('Finish Transaction'),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Countdown pinned near bottom
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.clock,
                              color: Theme.of(
                                context,
                              ).colorScheme.secondaryContainer,
                            ),
                            const SizedBox(width: 8),
                            RichText(
                              text: TextSpan(
                                style: Theme.of(context).textTheme.bodySmall,
                                children: [
                                  TextSpan(
                                    text: "Timing out in ",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                  TextSpan(
                                    text: _vm.seconds.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "s",
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sidebar logo
                      Center(
                        child: SvgPicture.asset(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/images/dark-lockup.svg'
                              : 'assets/images/lockup.svg',
                          width: 240,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
