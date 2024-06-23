import 'package:siAbank/Models/database.dart';
import 'package:path/path.dart';
import 'package:siAbank/Pages/transaction_page.dart';
import 'package:siAbank/Models/transaction_with_category.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  final DateTime selectedDate;
  const HomePage({Key? key, required this.selectedDate}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AppDb database = AppDb();

  @override
  void initState() {
    super.initState();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      
      child: SafeArea(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(16)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.download,
                                    color: Colors.greenAccent[400],
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Income',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.white)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  
FutureBuilder(
  future: AppDb().sumIncome(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator(); 
    } else if (snapshot.hasError) {
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            'Error: ${snapshot.error}',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ); 
    } else {
      // Handle both cases: data exists and no data
      int total = snapshot.data as int? ?? 0; 
      return Text(
        "Rp. $total",
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 14,
        ),
      );
    }
  },
),

                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          
                          child: Row(
                            children: [
                              Container(
                                  padding: EdgeInsets.all(3),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Icon(
                                    Icons.upload,
                                    color: Colors.redAccent[400],
                                  )),
                              SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Expense',
                                      style: GoogleFonts.montserrat(
                                          fontSize: 12, color: Colors.white)),
                                  SizedBox(
                                    width: 10,
                                  ),
                                  FutureBuilder(
                                    future: AppDb().sumExpense(),
                                    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator(); 
    } else if (snapshot.hasError) {
      return Expanded(
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Text(
            'Error: ${snapshot.error}',
            style: GoogleFonts.montserrat(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ); 
    } else {
      // Handle both cases: data exists and no data
      int total = snapshot.data as int? ?? 0; 
      return Text(
        "Rp. $total",
        style: GoogleFonts.montserrat(
          color: Colors.white,
          fontSize: 14,
        ),
      );
    }
  },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                )),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Transactions",
              style: GoogleFonts.montserrat(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          StreamBuilder<List<TransactionWithCategory>>(
              stream: database.getTransactionByDateRepo(widget.selectedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  if (snapshot.hasData) {
                    if (snapshot.data!.length > 0) {
                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                elevation: 10,
                                child: ListTile(
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: Icon(Icons.delete),
                                          onPressed: () async {
                                            await database
                                                .deleteTrabsactionRepo(snapshot
                                                    .data![index]
                                                    .transaction
                                                    .id);
                                            setState(() {});
                                          }),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.edit),
                                        onPressed: () {
                                          Navigator.of(context)
                                              .push(MaterialPageRoute(
                                                builder: (context) =>
                                                    TransactionPage(
                                                        transactionsWithCategory:
                                                            snapshot
                                                                .data![index]),
                                              ))
                                              .then((value) {});
                                        },
                                      )
                                    ],
                                  ),
                                  subtitle: Text(snapshot
                                          .data![index].category.name +
                                      " ( " +
                                      snapshot.data![index].transaction.name +
                                      " ) "),
                                  leading: Container(
                                      padding: EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      child: (snapshot
                                                  .data![index].category.type ==
                                              1)
                                          ? Icon(
                                              Icons.download,
                                              color: Colors.greenAccent[400],
                                            )
                                          : Icon(
                                              Icons.upload,
                                              color: Colors.red[400],
                                            )),
                                  title: Text(
                                    "RP. " +
                                        snapshot.data![index].transaction.amount
                                            .toString(),
                                  ),
                                ),
                              ),
                            );
                          });
                    } else {
                      return Center(
                        child: Column(children: [
                          SizedBox(
                            height: 30,
                          ),
                          Text("Belum ada transaksi",
                              style: GoogleFonts.montserrat()),
                        ]),
                      );
                    }
                  } else {
                    return const Center(
                      child: Text('Tidak ada Data'),
                    );
                  }
                }
              }),
        ],
      )),
    );
  }
}
