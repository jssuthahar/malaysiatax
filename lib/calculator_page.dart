import 'package:flutter/material.dart';
import 'tax_config.dart';
import 'package:url_launcher/url_launcher.dart';

class CalculatePage extends StatefulWidget {
  const CalculatePage({super.key});

  @override
  State<CalculatePage> createState() => _CalculatePageState();
}

class _CalculatePageState extends State<CalculatePage> {
  final TextEditingController _salaryController = TextEditingController();
  bool _isForeigner = false;
  DateTime? _arrivalDate;
  int _selectedYear = DateTime.now().year;

  List<Map<String, dynamic>> _breakdown = [];
  double _totalSalary = 0;
  double _totalTax = 0;
  double _netIncome = 0;
  String _residencyNote = "";

  // Compute resident tax for an annual income using TaxConfig.residentBrackets
  double _calculateResidentAnnualTax(double annualIncome) {
    double tax = 0;
    double prevLimit = 0;
    double remaining = annualIncome;

    for (var bracket in TaxConfig.residentBrackets) {
      final double limit = bracket["limit"];
      final double rate = bracket["rate"];

      double taxable;
      if (limit == double.infinity) {
        taxable = remaining;
      } else {
        taxable = (annualIncome > limit) ? (limit - prevLimit) : (remaining);
      }

      if (taxable > 0) {
        tax += taxable * rate;
        remaining -= taxable;
      }

      prevLimit = limit;
      if (remaining <= 0) break;
    }

    return tax;
  }

  /// Returns the month and year when user becomes resident, or null if not in selected year.
  Map<String, dynamic>? _residentMonthYear(DateTime arrival, int selectedYear) {
    DateTime start = arrival.isAfter(DateTime(selectedYear, 1, 1))
        ? arrival
        : DateTime(selectedYear, 1, 1);
    int days = 0;
    for (int m = start.month; m <= 12; m++) {
      DateTime monthStart = DateTime(selectedYear, m, 1);
      DateTime monthEnd = DateTime(selectedYear, m + 1, 0);
      int daysInMonth = monthEnd.difference(monthStart).inDays + 1;
      if (m == start.month) {
        days += monthEnd.difference(start).inDays + 1;
      } else {
        days += daysInMonth;
      }
      if (days >= 182) {
        return {
          "year": selectedYear,
          "month": m,
          "monthLabel": _monthLabel(DateTime(selectedYear, m, 1))
        };
      }
    }
    return null;
  }

  // Resident start date = arrivalDate + 182 days (i.e. after completing 182 days)
  DateTime? _residentStartDate(DateTime arrival) {
    return arrival.add(const Duration(days: 182));
  }

  // Build user-friendly explanation / timeline and compute monthly breakdown
  void _calculate() {
    _breakdown = [];
    _totalSalary = 0;
    _totalTax = 0;
    _netIncome = 0;
    _residencyNote = "";

    final double monthlySalary = double.tryParse(_salaryController.text) ?? 0;
    if (monthlySalary <= 0) {
      setState(() {});
      return;
    }

    List<DateTime> months =
        List.generate(12, (i) => DateTime(_selectedYear, i + 1, 1));

    bool isLocal = !_isForeigner;
    int daysSoFar = 0;
    bool crossed182 = false;
    int residentMonth = -1;

    if (_isForeigner &&
        _arrivalDate != null &&
        _arrivalDate!.year <= _selectedYear) {
      DateTime start = _arrivalDate!.isAfter(DateTime(_selectedYear, 1, 1))
          ? _arrivalDate!
          : DateTime(_selectedYear, 1, 1);

      for (var m in months) {
        Map<String, dynamic> row = {
          "monthLabel": _monthLabel(m),
          "salary": 0.0,
          "tax": 0.0,
          "rateLabel": "—",
          "status": "Before Arrival / N/A"
        };

        if (m.isBefore(DateTime(_arrivalDate!.year, _arrivalDate!.month, 1))) {
          row["status"] = "Before Arrival";
        } else {
          // Calculate days in this month
          DateTime monthStart = m;
          DateTime monthEnd = DateTime(m.year, m.month + 1, 0);
          int daysInMonth = monthEnd.difference(monthStart).inDays + 1;

          // For arrival month, only count days from arrival
          if (m.month == _arrivalDate!.month && m.year == _arrivalDate!.year) {
            daysInMonth = monthEnd.difference(_arrivalDate!).inDays + 1;
          }

          daysSoFar += daysInMonth;

          if (!crossed182 && daysSoFar >= 182) {
            crossed182 = true;
            residentMonth = m.month;
          }

          row["salary"] = monthlySalary;
          if (!crossed182) {
            row["tax"] = monthlySalary * TaxConfig.nonResidentRate;
            row["rateLabel"] =
                "${(TaxConfig.nonResidentRate * 100).toStringAsFixed(0)}% (Non-resident)";
            row["status"] = "Non-resident (30%)";
          } else {
            double annualResidentTax =
                _calculateResidentAnnualTax(monthlySalary * 12);
            double monthlyResidentTax = annualResidentTax / 12;
            row["tax"] = monthlyResidentTax;
            row["rateLabel"] = "Progressive (resident)";
            row["status"] = "Resident (progressive)";
          }
        }

        _breakdown.add(row);
        _totalSalary += (row["salary"] as double);
        _totalTax += (row["tax"] as double);
        _netIncome += (row["salary"] as double) - (row["tax"] as double);
      }

      if (residentMonth > 0) {
        _residencyNote =
            "You arrived on ${_formatDate(_arrivalDate!)} — you complete 182 days in ${_monthLabel(DateTime(_selectedYear, residentMonth, 1))} ${_selectedYear} and become Resident for the rest of the year.";
      } else {
        // Calculate when 182 days will be completed in the next year
        final nextYear = _selectedYear + 1;
        DateTime nextYearStart = DateTime(nextYear, 1, 1);
        DateTime arrival = _arrivalDate!;
        // Days left to reach 182 after current year
        int daysLeft = 182 - daysSoFar;
        DateTime residentDate = arrival.add(Duration(days: 182));
        int residentMonthNextYear =
            residentDate.year == nextYear ? residentDate.month : -1;
        String nextResidentMonthLabel = residentMonthNextYear > 0
            ? _monthLabel(DateTime(nextYear, residentMonthNextYear, 1))
            : "N/A";
        _residencyNote =
            "You arrived on ${_formatDate(_arrivalDate!)} — not enough days in $_selectedYear to meet 182-day rule. You will be Non-Resident for $_selectedYear (30% flat). "
            "You will become Resident in $nextResidentMonthLabel $nextYear if you stay continuously.";
      }
    } else {
      // Local or arrival after selected year
      for (var m in months) {
        Map<String, dynamic> row = {
          "monthLabel": _monthLabel(m),
          "salary": monthlySalary,
          "tax": 0.0,
          "rateLabel": "Progressive (resident)",
          "status": "Resident (progressive)"
        };
        double annualResidentTax =
            _calculateResidentAnnualTax(monthlySalary * 12);
        double monthlyResidentTax = annualResidentTax / 12;
        row["tax"] = monthlyResidentTax;

        _breakdown.add(row);
        _totalSalary += (row["salary"] as double);
        _totalTax += (row["tax"] as double);
        _netIncome += (row["salary"] as double) - (row["tax"] as double);
      }
      _residencyNote = isLocal
          ? "Local Malaysian — progressive resident tax applies for the year."
          : "You arrive after $_selectedYear. No salary/tax for this year.";
    }

    setState(() {});
  }

  String _monthLabel(DateTime d) {
    final names = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${names[d.month - 1]} ${d.year}";
  }

  String _formatDate(DateTime d) {
    final names = [
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "May",
      "Jun",
      "Jul",
      "Aug",
      "Sep",
      "Oct",
      "Nov",
      "Dec"
    ];
    return "${d.day} ${names[d.month - 1]} ${d.year}";
  }

  Widget _buildSummaryCard() {
    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Summary for $_selectedYear",
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Total Salary:",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text("MYR ${_totalSalary.toStringAsFixed(2)}"),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Total Tax:",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text("MYR ${_totalTax.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 6),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Net Income:",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              Text("MYR ${_netIncome.toStringAsFixed(2)}",
                  style: const TextStyle(
                      color: Colors.green, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 10),
            if (_residencyNote.isNotEmpty) _buildResidencyNote(),
          ],
        ),
      ),
    );
  }

  Widget _buildResidencyNote() {
    if (_isForeigner && _arrivalDate != null) {
      final residentMonth =
          _breakdown.indexWhere((r) => r["status"] == "Resident (progressive)");
      if (residentMonth > 0) {
        final monthLabel =
            _monthLabel(DateTime(_selectedYear, residentMonth + 1, 1));
        return RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.deepPurple, fontSize: 14),
            children: [
              TextSpan(
                  text:
                      "You arrived on ${_formatDate(_arrivalDate!)} — you complete 182 days in "),
              TextSpan(
                text: "$monthLabel $_selectedYear",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " and become "),
              TextSpan(
                text: "Resident",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextSpan(text: " for the rest of the year."),
            ],
          ),
        );
      } else {
        return Text(
          "You arrived on ${_formatDate(_arrivalDate!)} — not enough days in $_selectedYear to meet 182-day rule. You will be Non-Resident for $_selectedYear (30% flat).",
          style: const TextStyle(color: Colors.deepPurple),
        );
      }
    } else {
      return Text(
        _residencyNote,
        style: const TextStyle(color: Colors.deepPurple),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Malaysia Tax Calculator")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Inputs
          const Text("1) Enter monthly salary (before tax)",
              style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: _salaryController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: "e.g. 5000",
              prefixText: "MYR ",
            ),
          ),
          const SizedBox(height: 12),

          // Year selector
          Row(children: [
            const Text("2) Select tax year",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 8),
            Tooltip(
                message: "Choose the tax year you want to estimate",
                child: const Icon(Icons.info, size: 16)),
          ]),
          const SizedBox(height: 6),
          DropdownButton<int>(
            value: _selectedYear,
            items: List.generate(6, (i) => DateTime.now().year + i)
                .map((y) => DropdownMenuItem(value: y, child: Text("$y")))
                .toList(),
            onChanged: (v) => setState(() => _selectedYear = v!),
          ),
          const SizedBox(height: 12),

          // Foreigner switch + tooltip
          Row(children: [
            const Text("3) Are you a foreigner? ",
                style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(width: 6),
            Tooltip(
              message:
                  "Foreigners: subject to 30% flat while non-resident. If stay ≥183 days in a year, you become tax resident and progressive rates apply.",
              child: Icon(Icons.info_outline, size: 18),
            ),
            const Spacer(),
            Switch(
                value: _isForeigner,
                onChanged: (v) => setState(() {
                      _isForeigner = v;
                      if (!_isForeigner) _arrivalDate = null;
                    })),
          ]),
          const SizedBox(height: 6),

          // Arrival date picker (only for foreigners)
          if (_isForeigner)
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("4) Select arrival date to Malaysia",
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              ElevatedButton.icon(
                icon: const Icon(Icons.calendar_today),
                label: Text(_arrivalDate == null
                    ? "Pick arrival date"
                    : _formatDate(_arrivalDate!)),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime(_selectedYear, 1, 1),
                    firstDate: DateTime(_selectedYear, 1, 1),
                    lastDate: DateTime(_selectedYear, 12, 31),
                  );
                  if (picked != null) setState(() => _arrivalDate = picked);
                },
              ),
              const SizedBox(height: 8),
            ]),

          // Calculate button
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.play_circle),
              label: const Text("Calculate"),
              onPressed: () {
                _breakdown.clear();
                _totalSalary = 0;
                _totalTax = 0;
                _netIncome = 0;
                _residencyNote = "";
                _calculate();
              },
            ),
          ),

          const SizedBox(height: 16),

          // Summary card
          if (_breakdown.isNotEmpty) _buildSummaryCard(),

          const SizedBox(height: 12),

          // Explanation text (plain-language)
          if (_breakdown.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _isForeigner && _arrivalDate != null
                      ? "Explanation: You arrived on ${_formatDate(_arrivalDate!)}. Months before arrival show 0 income. Months between arrival and completing 183 days are taxed at 30% (non-resident). After completing 183 days you are taxed using Malaysia's progressive resident brackets (shown as 'Progressive' below)."
                      : "Explanation: All months are taxed using Malaysia's progressive resident tax brackets.",
                ),
              ),
            ),

          const SizedBox(height: 10),

          // Legend
          if (_breakdown.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Legend",
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      const Text(
                          "30% (Non-resident): Flat rate for non-resident foreigner months."),
                      const SizedBox(height: 4),
                      const Text(
                          "Progressive (Resident): Monthly share of resident tax computed from progressive annual slabs."),
                    ]),
              ),
            ),

          const SizedBox(height: 10),

          // Monthly table (simple list)
          if (_breakdown.isNotEmpty)
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(2),
                3: FlexColumnWidth(2),
              },
              children: [
                const TableRow(children: [
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Month",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Salary (MYR)",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Tax (MYR)",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                  Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("Rate",
                          style: TextStyle(fontWeight: FontWeight.bold))),
                ]),
                ..._breakdown.map((r) => TableRow(children: [
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(r["monthLabel"])),
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child:
                              Text((r["salary"] as double).toStringAsFixed(2))),
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text((r["tax"] as double).toStringAsFixed(2))),
                      Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(r["rateLabel"])),
                    ])),
              ],
            ),

          const SizedBox(height: 14),

          // Footer: disclaimer & subscribe reminder
          const Text(
            "Disclaimer: This calculator is for reference only. Check official LHDN (hasil.gov.my) for precise rules and reliefs. This app uses editable tax rules from assets/tax_rules.json.",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () =>
                launchUrl(Uri.parse("https://www.youtube.com/@NikiBhavi")),
            child: const Text(
              "Learn more on NikiBhavi Vlog — Subscribe!",
              style: TextStyle(
                  color: Colors.blue, decoration: TextDecoration.underline),
            ),
          ),
        ]),
      ),
    );
  }
}
