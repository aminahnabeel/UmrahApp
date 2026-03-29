import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:smart_umrah_app/Controller/userControllers/expense_track_controller.dart';
import 'package:smart_umrah_app/Models/ExpensesModel_expenses_model.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart';

class TrackExpenses extends StatelessWidget {
  TrackExpenses({super.key});

  final ExpenseController expenseController = Get.put(ExpenseController());

  // Theme Colors
  static const Color customBlue = Color(0xFF0D47A1);

  void _showExpenseDialog(BuildContext context, {Expense? expense}) {
    bool isEdit = expense != null;
    final _formKey = GlobalKey<FormState>();
    
    // Controllers initialization
    final _itemController = TextEditingController(text: isEdit ? expense.item : "");
    final _placeController = TextEditingController(text: isEdit ? expense.place : "");
    final _amountController = TextEditingController(text: isEdit ? expense.amount.toString() : "");

    Get.defaultDialog(
      title: isEdit ? "Edit Expense" : "Add Expense",
      backgroundColor: Colors.white,
      barrierDismissible: false, // User ko button hi use karna parega band karne ke liye
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(_itemController, "Item Name", Icons.shopping_bag),
            const SizedBox(height: 10),
            _buildTextField(_placeController, "Place/Shop", Icons.location_on),
            const SizedBox(height: 10),
            _buildTextField(_amountController, "Amount (SAR)", Icons.money, isNumber: true),
          ],
        ),
      ),
      confirm: ElevatedButton(
        onPressed: () async {
          if (_formKey.currentState!.validate()) {
            // Naya Expense object banana
            final newExpense = Expense(
              id: isEdit ? expense.id : null,
              item: _itemController.text,
              place: _placeController.text,
              amount: double.parse(_amountController.text),
              date: isEdit ? expense.date : DateTime.now(),
            );

            // Firebase operations
            if (isEdit) {
              await expenseController.editExpense(newExpense);
            } else {
              await expenseController.addExpense(newExpense);
            }
            
            // Automatic Dialog Dismissal
            Get.back(); 
            
            Get.snackbar(
              "Success", 
              isEdit ? "Expense Updated" : "Expense Added",
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
            );
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: customBlue),
        child: Text(isEdit ? "Update" : "Save", style: const TextStyle(color: Colors.white)),
      ),
      cancel: TextButton(
        onPressed: () => Get.back(), // Cancel par automatically dialog hat jayega
        child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: customBlue),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      validator: (value) => value == null || value.isEmpty ? "Required" : null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(title: "Track Expenses", showBackButton: true),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0D47A1), Color(0xFF1976D2)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Obx(() {
                  if (expenseController.expenses.isEmpty) {
                    return const Center(
                      child: Text("No expenses yet", style: TextStyle(color: Colors.white70)),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: expenseController.expenses.length,
                    itemBuilder: (context, index) {
                      final exp = expenseController.expenses[index];
                      return Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: Color(0xFFE3F2FD),
                            child: Icon(Icons.receipt_long, color: customBlue),
                          ),
                          title: Text(exp.item, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text("${exp.place} • ${DateFormat("dd MMM").format(exp.date)}"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text("${exp.amount} SAR", style: const TextStyle(fontWeight: FontWeight.bold, color: customBlue)),
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.amber, size: 20),
                                onPressed: () => _showExpenseDialog(context, expense: exp),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent, size: 20),
                                onPressed: () => expenseController.deleteExpense(exp.id!),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
              
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: ElevatedButton.icon(
                  onPressed: () => _showExpenseDialog(context),
                  icon: const Icon(Icons.add_circle),
                  label: const Text("Add New Expense", style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: customBlue,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),

              Obx(() => Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Total Expenses", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text("${expenseController.totalExpense.value.toStringAsFixed(2)} SAR", 
                        style: const TextStyle(fontSize: 20, color: customBlue, fontWeight: FontWeight.bold)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}