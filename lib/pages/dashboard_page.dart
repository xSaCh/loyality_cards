import 'dart:io';
import 'package:ext/repositories/code_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ext/blocs/dashboard/dashboard_bloc.dart';
import 'package:ext/models/loyalty_card.dart';
import 'package:ext/widgets/loyalty_card_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_svg/flutter_svg.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  void getId() async {
    if (kIsWeb) debugPrint("ID: ${FirebaseAuth.instance.currentUser?.uid}");
    debugPrint(
        "DID: ${(await SharedPreferences.getInstance()).getString("userID")}");
  }

  String _getFilterTitle(CardFilterType filter) {
    switch (filter) {
      case CardFilterType.all:
        return 'All Cards';
      case CardFilterType.used:
        return 'Used Cards';
      case CardFilterType.expired:
        return 'Expired Cards';
      case CardFilterType.active:
        return 'Active Cards';
    }
  }

  @override
  Widget build(BuildContext context) {
    getId();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Everyday Rewards Inc.'),
        actions: [
          BlocBuilder<DashboardBloc, DashboardState>(
            builder: (context, state) {
              if (state is DashboardLoaded) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PopupMenuButton<CardFilterType>(
                      // icon: const Icon(Icons.filter_list),
                      onSelected: (CardFilterType result) {
                        context.read<DashboardBloc>().add(FilterCards(result));
                      },
                      initialValue: state.currentFilter,
                      itemBuilder: (BuildContext context) =>
                          <PopupMenuEntry<CardFilterType>>[
                        const PopupMenuItem<CardFilterType>(
                          value: CardFilterType.active,
                          child: Text('Active'),
                        ),
                        const PopupMenuItem<CardFilterType>(
                          value: CardFilterType.used,
                          child: Text('Used'),
                        ),
                        const PopupMenuItem<CardFilterType>(
                          value: CardFilterType.expired,
                          child: Text('Expired'),
                        ),
                        const PopupMenuItem<CardFilterType>(
                          value: CardFilterType.all,
                          child: Text('All'),
                        ),
                      ],
                      child: Row(
                        children: [
                          const Icon(Icons.filter_list),
                          const SizedBox(width: 8),
                          Text(_getFilterTitle(state.currentFilter)),
                        ],
                      ),
                    ),
                    // Text("${_getFilterTitle(state.currentFilter)}"),
                    const SizedBox(width: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            if (state is DashboardInitial) {
              context.read<DashboardBloc>().add(LoadDashboard());
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            if (state.filteredCards.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      'lib/assets/images/empty_state.svg',
                      height: 150,
                      width: 150,
                      semanticsLabel: 'No cards found',
                    ),
                    const SizedBox(height: 20),
                    Text(
                      state.allCards.isEmpty
                          ? 'No cards added yet.'
                          : 'No cards match the filter "${_getFilterTitle(state.currentFilter)}".',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (state.allCards.isNotEmpty &&
                        state.currentFilter != CardFilterType.all)
                      TextButton(
                        onPressed: () => context
                            .read<DashboardBloc>()
                            .add(const FilterCards(CardFilterType.all)),
                        child: const Text('Show All Cards'),
                      ),
                  ],
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0, left: 4.0),
                    child: Text(
                      '${_getFilterTitle(state.currentFilter)} (${state.filteredCards.length})',
                      style:
                          Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount:
                            MediaQuery.of(context).size.width > 600 ? 3 : 2,
                        childAspectRatio: 16 / 10,
                        mainAxisSpacing: 12.0,
                        crossAxisSpacing: 12.0,
                      ),
                      itemCount: state.filteredCards.length,
                      itemBuilder: (context, index) {
                        final card = state.filteredCards[index];
                        return GestureDetector(
                          onLongPress: () =>
                              _showDeleteConfirmationDialog(context, card),
                          child: LoyaltyCardWidget(
                            card: card,
                            onMarkUsed: (cardToUpdate, isUsed) {
                              context.read<DashboardBloc>().add(
                                    UpdateCardUsage(
                                      cardId: cardToUpdate.id,
                                      isUsed: isUsed,
                                    ),
                                  );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is DashboardError) {
            return Center(
                child: Padding(
              padding: const EdgeInsets.all(16.0),
              child:
                  Text('Error: ${state.message}', textAlign: TextAlign.center),
            ));
          } else {
            return const Center(child: Text('Something went wrong.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddOptions(context),
        tooltip: 'Add Card',
        icon: const Icon(Icons.add),
        label: const Text("Add Card"),
      ),
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context, LoyaltyCard card) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the card "${card.cardName}"?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child:
                  const Text('Delete', style: TextStyle(color: Colors.white)),
              onPressed: () {
                context.read<DashboardBloc>().add(DeleteCard(card.id));
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${card.cardName} deleted')),
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading:
                    const Icon(Icons.qr_code_scanner, color: Colors.blueAccent),
                title: const Text('From Code/Scan'),
                onTap: () {
                  Navigator.pop(context);
                  _showCodeEntryDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note, color: Colors.green),
                title: const Text('Manual Entry'),
                onTap: () {
                  Navigator.pop(context);
                  _showManualEntryDialog(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCodeEntryDialog(BuildContext context) {
    final codeController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: const Text('Enter or Scan Code'),
          content: TextField(
            controller: codeController,
            decoration:
                const InputDecoration(hintText: "Enter loyalty card code"),
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: const Text('Continue'),
              onPressed: () {
                print('Entered code: ${codeController.text}');
                final c = CodeHandler().fromCode(codeController.text);
                if (c == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                            Text('Invalid code format. Please try again.')),
                  );
                  return;
                }
                context.read<DashboardBloc>().add(AddCard(c));
                Navigator.of(context).pop();
                
              },
            ),
          ],
        );
      },
    );
  }

  void _showManualEntryDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final cardNameController = TextEditingController();
    final couponCodeController = TextEditingController();
    DateTime? selectedDate;
    XFile? pickedImage;

    final ImagePicker picker = ImagePicker();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            Future<void> selectDate(BuildContext context) async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
              );
              if (picked != null && picked != selectedDate) {
                setStateDialog(() {
                  selectedDate = picked;
                });
              }
            }

            Future<void> pickImageDialog(ImageSource source) async {
              try {
                final XFile? image =
                    await picker.pickImage(source: source, imageQuality: 80);
                if (image != null) {
                  setStateDialog(() {
                    pickedImage = image;
                  });
                }
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to pick image: $e')),
                );
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              title: const Text('Add Card Manually'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: cardNameController,
                        decoration: const InputDecoration(
                          labelText: 'Card Name',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.card_membership),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a card name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 15),
                      TextFormField(
                        controller: couponCodeController,
                        decoration: const InputDecoration(
                          labelText: 'Coupon Code (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.confirmation_number),
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: Text(selectedDate == null
                                ? 'No Expiry Date Chosen *'
                                : 'Expiry: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                          ),
                          TextButton.icon(
                            onPressed: () => selectDate(context),
                            icon: const Icon(Icons.calendar_today),
                            label: const Text('Select'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Text("Add Image (Optional)",
                          style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.photo_library),
                            label: const Text("Gallery"),
                            onPressed: () =>
                                pickImageDialog(ImageSource.gallery),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.camera_alt),
                            label: const Text("Camera"),
                            onPressed: () =>
                                pickImageDialog(ImageSource.camera),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      if (pickedImage != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: kIsWeb
                              ? Image.network(pickedImage!.path,
                                  height: 100, fit: BoxFit.cover)
                              : Image.file(File(pickedImage!.path),
                                  height: 100, fit: BoxFit.cover),
                        ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: const Text('Save Card'),
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      if (selectedDate == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Please select an expiry date.')),
                        );
                        return;
                      }

                      final newCard = LoyaltyCard(
                        id: const Uuid().v4(),
                        cardName: cardNameController.text.trim(),
                        expiryDate: selectedDate!,
                        couponCode: couponCodeController.text.isNotEmpty
                            ? couponCodeController.text.trim()
                            : null,
                        imagePath: pickedImage?.path,
                        isUsed: false,
                      );
                      context.read<DashboardBloc>().add(AddCard(newCard));
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
