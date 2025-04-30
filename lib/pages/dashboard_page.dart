import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ext/blocs/dashboard/dashboard_bloc.dart';
import 'package:ext/models/loyalty_card.dart'; 
import 'package:ext/widgets/loyalty_card_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart'; 

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Everyday Rewards Inc.'),
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            if (state is DashboardInitial) {
              context.read<DashboardBloc>().add(LoadDashboard());
            }
            return const Center(child: CircularProgressIndicator());
          } else if (state is DashboardLoaded) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 8.0),
                    child: Text(
                      'Total Cards: ${state.cards.length}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 300,
                        childAspectRatio: 16 / 9,
                        mainAxisSpacing: 8.0,
                        crossAxisSpacing: 8.0,
                      ),
                      itemCount: state.cards.length,
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: Key(state.cards[index].id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            context
                                .read<DashboardBloc>()
                                .add(DeleteCard(state.cards[index].id));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${state.cards[index].cardName} deleted')),
                            );
                          },
                          background: Container(
                            color: Colors.red,
                            alignment: Alignment.centerRight,
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          child: LoyaltyCardWidget(card: state.cards[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          } else if (state is DashboardError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            return const Center(child: Text('Something went wrong.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        tooltip: 'Add Card',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext bc) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.qr_code_scanner),
                title: const Text('From Code'),
                onTap: () {
                  Navigator.pop(context);
                  _showCodeEntryDialog(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_note),
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
          title: const Text('Enter Code'),
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
            TextButton(
              child: const Text('Continue'),
              onPressed: () {
                print('Entered code: ${codeController.text}');
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content:
                          Text('Code entry/scanning not implemented yet.')),
                );
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
          builder: (context, setState) {
            Future<void> selectDate(BuildContext context) async {
              final DateTime? picked = await showDatePicker(
                context: context,
                initialDate: selectedDate ?? DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (picked != null && picked != selectedDate) {
                setState(() {
                  selectedDate = picked;
                });
              }
            }

            Future<void> pickImageDialog(ImageSource source) async {
              try {
                final XFile? image = await picker.pickImage(source: source);
                if (image != null) {
                  setState(() {
                    pickedImage = image;
                  });
                }
              } catch (e) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to pick image: $e')),
                );
              }
            }

            return AlertDialog(
              title: const Text('Add Card Manually'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: cardNameController,
                        decoration:
                            const InputDecoration(labelText: 'Card Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a card name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: Text(selectedDate == null
                                ? 'No Expiry Date Chosen'
                                : 'Expiry: ${selectedDate!.toLocal().toString().split(' ')[0]}'),
                          ),
                          TextButton(
                            onPressed: () => selectDate(context),
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                      TextFormField(
                        controller: couponCodeController,
                        decoration: const InputDecoration(
                            labelText: 'Coupon Code (Optional)'),
                      ),
                      const SizedBox(height: 10),
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
                      const SizedBox(height: 10),
                      if (pickedImage != null)
                        kIsWeb
                            ? Image.network(pickedImage!.path, height: 100)
                            : Image.file(File(pickedImage!.path), height: 100),
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
                TextButton(
                  child: const Text('Save'),
                  onPressed: () {
                    if (formKey.currentState!.validate() &&
                        selectedDate != null) {
                      final newCard = LoyaltyCard(
                        id: const Uuid().v4(),
                        cardName: cardNameController.text,
                        expiryDate: selectedDate!,
                        couponCode: couponCodeController.text.isNotEmpty
                            ? couponCodeController.text
                            : null,
                        imagePath: pickedImage?.path,
                      );
                      context.read<DashboardBloc>().add(AddCard(newCard));
                      Navigator.of(context).pop();
                    } else if (selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Please select an expiry date.')),
                      );
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
