import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/Controller/userControllers/expense_track_controller.dart';
import 'package:smart_umrah_app/Models/ExpensesModel_expenses_model.dart';

final _formKey = GlobalKey<FormState>();
final TextEditingController _itemController = TextEditingController();
final TextEditingController _placeController = TextEditingController();
final TextEditingController _amountController = TextEditingController();
final ExpenseController expenseController = Get.put(ExpenseController());

void showAddExpenseDialog(BuildContext context) {
  _itemController.clear();
  _placeController.clear();
  _amountController.clear();

  Get.defaultDialog(
    title: "Add Expense",
    content: Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _itemController,
            decoration: const InputDecoration(labelText: "Item"),
            validator: (value) => value!.isEmpty ? "Enter item" : null,
          ),
          TextFormField(
            controller: _placeController,
            decoration: const InputDecoration(labelText: "Place"),
            validator: (value) => value!.isEmpty ? "Enter place" : null,
          ),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? "Enter amount" : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final expense = Expense(
                  item: _itemController.text,
                  place: _placeController.text,
                  amount: double.parse(_amountController.text),
                  date: DateTime.now(),
                );
                await expenseController.addExpense(expense);
                Get.back();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    ),
  );
}

void showEditExpenseDialog(BuildContext context, Expense expense) {
  _itemController.text = expense.item;
  _placeController.text = expense.place;
  _amountController.text = expense.amount.toString();

  Get.defaultDialog(
    title: "Edit Expense",
    content: Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _itemController,
            decoration: const InputDecoration(labelText: "Item"),
            validator: (value) => value!.isEmpty ? "Enter item" : null,
          ),
          TextFormField(
            controller: _placeController,
            decoration: const InputDecoration(labelText: "Place"),
            validator: (value) => value!.isEmpty ? "Enter place" : null,
          ),
          TextFormField(
            controller: _amountController,
            decoration: const InputDecoration(labelText: "Amount"),
            keyboardType: TextInputType.number,
            validator: (value) => value!.isEmpty ? "Enter amount" : null,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final updatedExpense = Expense(
                  id: expense.id,
                  item: _itemController.text,
                  place: _placeController.text,
                  amount: double.parse(_amountController.text),
                  date: DateTime.now(),
                );
                await expenseController.editExpense(updatedExpense);
                Get.back();
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    ),
  );
}
