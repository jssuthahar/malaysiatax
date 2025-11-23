# 🇲🇾 Malaysia Tax Calculator (Flutter Web)

**Fast, Accurate, and Simple Malaysia Income Tax Estimator for Locals & Foreigners**

This open-source **Flutter Web Malaysia Tax Calculator** helps you instantly estimate your **monthly and yearly Malaysian income tax**, whether you are a **Malaysian resident** or **foreigner** working in Malaysia.

It supports progressive resident tax brackets, non-resident flat tax rules, and provides a clean UI with monthly breakdowns and net salary calculations.

🔗 **Live App:** [https://jssuthahar.github.io/malaysiatax/](https://jssuthahar.github.io/malaysiatax/)
📺 **YouTube:** [https://www.youtube.com/@NikiBhavi](https://www.youtube.com/@NikiBhavi)

---

## 🌟 Why This Tax Calculator?

Many people—locals, expats, tourists, new workers—struggle to calculate Malaysian tax correctly.
To make things simple, I created this **free tax calculator website** that helps you:

✔ Understand **Malaysia income tax rules**
✔ Calculate tax for **locals and foreigners**
✔ Estimate **take-home salary**
✔ Learn about **resident vs non-resident** tax
✔ View Malaysia's latest **tax brackets**

Please share this tool with your friends if they plan to work or move to Malaysia. 🇲🇾
Your support for **NikiBhavi Vlog** means a lot! 🙏

---

# 🚀 Malaysia Tax Calculator — Key Features

## 1️⃣ **Income Tax Calculation**

Supports the complete Malaysian income tax system:

* **Residents** → Progressive tax brackets
* **Foreigners** → Non-resident flat rate (first 182 days), then progressive
* Monthly and annual:

  * Tax payable
  * Total salary
  * Net income
  * Effective tax rate

---

## 2️⃣ **Interactive UI (Flutter Web)**

* Clean dashboard
* **YouTube banner** promoting NikiBhavi channel
* Button navigation to Calculator
* Color-coded monthly breakdowns
* Fully responsive design

---

## 3️⃣ **Malaysia Tax Rules Preview**

Includes a simple preview of:

* **Resident tax brackets**
* **Non-resident tax rate**
* Easy JSON-based configuration for future updates

---

## 4️⃣ **User Inputs**

* Monthly salary (MYR)
* Year of calculation
* Resident/Foreigner selection
* Arrival date (for foreigners)

---

## 5️⃣ **Important Disclaimer**

This tool provides **estimated tax values**.
Always verify with the official **LHDN Malaysia** 👉 [https://www.hasil.gov.my](https://www.hasil.gov.my)

---

# 🖥️ Screenshots

<p align="center">
  <img src="https://github.com/jssuthahar/malaysiatax/blob/main/ScreenShort/MalaysiaTax1.png" width="30%" />
  <img src="https://github.com/jssuthahar/malaysiatax/blob/main/ScreenShort/MalaysiaTax2.png" width="30%" />
  <img src="https://github.com/jssuthahar/malaysiatax/blob/main/ScreenShort/MalaysiaTax3.png" width="30%" />
</p>

---

# 🌐 Live Demo

👉 **Use the Malaysia Tax Calculator**
[https://jssuthahar.github.io/malaysiatax/](https://jssuthahar.github.io/malaysiatax/)

---

# 💛 Support My Work

<a href="https://buymeacoffee.com/jssuthahar" target="_blank">
  <img src="https://cdn.buymeacoffee.com/buttons/v2/default-yellow.png" alt="Buy Me a Coffee" style="height:50px;">
</a>

📺 Watch & Support:
**NikiBhavi Vlog** – [https://www.youtube.com/@NikiBhavi](https://www.youtube.com/@NikiBhavi)

---

# 📦 Project Structure

```
malaysia_tax_calculator/
│
├─ lib/
│   ├─ main.dart
│   ├─ home_page.dart         # Home page with YouTube banner & tax overview
│   ├─ calculator_page.dart   # Tax calculation logic & UI
│   └─ tax_config.dart        # Load tax brackets & non-resident rate
│
├─ assets/
│   └─ tax_rules.json         # Editable tax rules for Malaysia
│
├─ pubspec.yaml
├─ README.md
└─ web/
    └─ index.html             # Flutter Web entry point
```

---

# 🛠️ Installation & Setup

## 1. Clone this repository

```bash
git clone <your-repo-url>
cd malaysia_tax_calculator
```

## 2. Install dependencies

```bash
flutter pub get
```

## 3. Run the app in browser

```bash
flutter run -d chrome
```

## 4. Build for production

```bash
flutter build web
```

Output will be generated in `build/web/` → ready for **GitHub Pages** hosting.

---

# 📁 Tax Rules JSON (Editable)

**assets/tax_rules.json**

```json
{
  "malaysia": {
    "non_resident_rate": 0.30,
    "resident_brackets": [
      { "limit": 5000, "rate": 0.01 },
      { "limit": 20000, "rate": 0.03 },
      { "limit": 35000, "rate": 0.08 },
      { "limit": 50000, "rate": 0.13 },
      { "limit": 70000, "rate": 0.21 },
      { "limit": 100000, "rate": 0.24 },
      { "limit": 250000, "rate": 0.24 },
      { "limit": 400000, "rate": 0.25 },
      { "limit": 600000, "rate": 0.26 },
      { "limit": 1000000, "rate": 0.28 },
      { "limit": "infinity", "rate": 0.30 }
    ]
  }
}
```

---

# 📘 How to Use the Calculator

## ▶ On **Home Page**

* View NikiBhavi YouTube banner
* View Malaysia tax bracket summary
* Click **Start Calculation**

## ▶ On **Calculator Page**

1. Enter your **monthly salary**
2. Choose **year**
3. Select:

   * Local resident
   * Foreigner
4. If foreigner → enter **arrival date**
5. Click **Calculate**
6. View:

   * Monthly tax
   * Total tax
   * Total salary
   * Net income
   * Effective tax %

---

# ℹ️ Important Notes

* Foreigners pay **30% flat** for first **182 days**.
* After crossing 182 days → switch to **resident tax** (progressive).
* JSON tax rules allow quick tax updates without app modifications.
* All results are **estimates only**.
* Always refer to **LHDN Malaysia** for final confirmation.

---

# 📦 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  url_launcher: ^6.2.1
```

---

# 📄 License

MIT License © **Suthahar Jegatheesan**

---
