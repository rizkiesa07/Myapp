import 'package:siAbank/Models/transaction_with_category.dart';
import 'package:siAbank/Models/database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class TransactionPage extends StatefulWidget {
  final TransactionWithCategory? transactionsWithCategory;
  const TransactionPage({Key? key, required this.transactionsWithCategory})
      : super(key: key);

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool isExpanse = true;
  late int type;
  final AppDb database = AppDb();
  Category? selectedCategory;
  TextEditingController dateController = TextEditingController();
  TextEditingController amountController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  Future insert(
      int amount, DateTime date, String nameDetail, int categoryId) async {
    DateTime now = DateTime.now();
    final row = await database.into(database.transactions).insertReturning(
        TransactionsCompanion.insert(
            name: nameDetail,
            category_id: categoryId,
            amount: amount,
            transaction_date: date,
            createdAt: now,
            updatedAt: now));
  }

  Future update(int transactionId, int amount, int categoryId,
      DateTime transactionDate, String nameDetail) async {
    await database.updateTransactionRepo(
        transactionId, amount, categoryId, transactionDate, nameDetail);
  }

  @override
  void initState() {
    // TODO: implement initState
    if (widget.transactionsWithCategory != null) {
      updateTransaction(widget.transactionsWithCategory!);
    } else {
      type = 2;

      dateController.text = "";
    }

    super.initState();
  }

  Future<List<Category>> getAllCategory(int type) async {
    return await database.getAllCategoryRepo(type);
  }

  void updateTransaction(TransactionWithCategory initTransaction) {
    amountController.text = initTransaction.transaction.amount.toString();
    descriptionController.text = initTransaction.transaction.name.toString();
    dateController.text = DateFormat('yyyy-MM-dd')
        .format(initTransaction.transaction.transaction_date);
    type = initTransaction.category.type;
    (type == 2) ? isExpanse = true : isExpanse = false;
    selectedCategory = initTransaction.category;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Transacrtion")),
      body: SingleChildScrollView(
        child: SafeArea(
            child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Switch(
                  // This bool value toggles the switch.
                  value: isExpanse,
                  inactiveTrackColor: Colors.green[200],
                  inactiveThumbColor: Colors.green,
                  activeColor: Colors.red,
                  onChanged: (bool value) {
                    setState(() {
                      isExpanse = value;
                      type = (isExpanse) ? 2 : 1;
                      selectedCategory = null;
                    });
                  },
                ),
                Text(
                  isExpanse ? "Expense" : "Income",
                  style: GoogleFonts.montserrat(fontSize: 14),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Amount',
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text("Category", style: GoogleFonts.montserrat()),
            ),
            SizedBox(
              height: 5,
            ),
            
FutureBuilder<List<Category>>(
  future: getAllCategory(type),
  builder: (context, snapshot) {
    if (
snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator();
    } else {
      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButton
<Category>(
            isExpanded: true,
            value: (selectedCategory == null)
                ? snapshot.data!.first
                : selectedCategory,
            icon: const Icon(Icons.arrow_downward),
            elevation: 16,
            onChanged: (Category? newValue) {
              print(newValue!.name);
              setState(() {
                selectedCategory = newValue;
              });
            },
            items: snapshot.data!.map((Category item) {
              return DropdownMenuItem<Category>(
                value: item,
                child: Text(item.name),
              );
            }).toList(),
          ),
        );
      } else {
        
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text("Belum ada kategory"),
        );
      }
    }
  },
),

            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextFormField(
                controller: dateController,
                decoration: const InputDecoration(labelText: "Enter Date"),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(), //get today's date
                      firstDate: DateTime(
                          2000), //DateTime.now() - not to allow to choose before today.
                      lastDate: DateTime(2101));

                  if (pickedDate != null) {
                    print(
                        pickedDate); //get the picked date in the format => 2022-07-04 00:00:00.000
                    String formattedDate = DateFormat('yyyy-MM-dd').format(
                        pickedDate); // format date in required form here we use yyyy-MM-dd that means time is removed
                    print(
                        formattedDate); //formatted date output using intl package =>  2022-07-04
                    //You can format date as per your need

                    setState(() {
                      dateController.text =
                          formattedDate; //set foratted date to TextField value.
                    });
                  } else {
                    print("Date is not selected");
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: TextFormField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Description',
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Center(
                child: ElevatedButton(
                    onPressed: () async {
                      try {
                        if (widget.transactionsWithCategory == null) {
                          // Input Validation
                          int amount = int.tryParse(amountController.text) ??
                              0; // Handle parsing errors
                          DateTime date =
                              DateTime.tryParse(dateController.text) ??
                                  DateTime.now();
                          if (selectedCategory != null) {
                            await insert(
                                int.parse(amountController.text),
                              DateTime.parse(dateController.text),
                              descriptionController.text,
                              selectedCategory!.id);
                          } else {
                            print("Error: Category not selected");
                          }
                        } else {
                          await update(
                              widget.transactionsWithCategory!.transaction.id,
                              int.parse(amountController.text),
                              selectedCategory!.id,
                              DateTime.parse(dateController.text),
                              descriptionController.text);
                        }
                        // Update UI (if needed)
                        setState(() {});
                        Navigator.pop(context, true);
                      } catch (e) {
                        print("Error saving transaction: $e");
                        // Optionally display an error message to the user
                      }
                    },
                    child: Text('Save')))
          ],
        )),
      ),
    );
  }
}
