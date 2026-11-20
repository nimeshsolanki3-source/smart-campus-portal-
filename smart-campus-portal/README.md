# 🎓 Smart Campus Event & Workshop Portal
> **Marwadi University — Department of Computer Engineering**  
> **Course:** Web Technology (`01CE1306`)  
> **Architecture:** Pure Responsive Front-End Web Application (HTML5, CSS3, Tailwind CSS, Vanilla JavaScript ES6+)

---

## 📌 1. Project Overview & Features

The **Smart Campus Event & Workshop Portal** is a production-ready, interactive web application developed strictly in accordance with the Marwadi University Web Technology syllabus. It requires **zero server installation (No PHP / Apache / XAMPP needed)** and runs directly in any modern browser or via GitHub Pages.

The application features two distinct interfaces:
1. **Client / Student Portal** (Discovery, Live Filters, Interactive Booking, Dynamic QR Ticket Generator)
2. **Admin Management Portal** (Executive Dashboard, Event Creation, Venue Management, Campus Broadcasts, User Directory)

---

## 📁 2. File Directory Structure

```text
smart-campus-portal/
├── index.html                  # Main Landing Page (Hero Carousel, KPIs, Featured Events)
├── events.html                 # Event Discovery & Search Catalog
├── workshops.html              # Hands-on Workshops with Live Category Filters
├── event-details.html          # Detailed Event Agenda, Speakers & .ICS Calendar Export
├── dashboard.html              # Student Dashboard with Digital Entry Pass & QR Modal
├── contact.html                # Campus Inquiry Form with Validation & OpenStreetMap
├── register.html               # Student Registration with Real-Time Regex Validation
├── login.html                  # Authentication Screen with 1-Click Evaluator Demo Buttons
├── validation-demo.html        # Academic Screenshot Tool (Captures Figs 1.1 to 1.5)
├── README.md                   # Project Documentation
│
├── admin/                      # Campus Administrator Interface
│   ├── dashboard.html          # Admin KPI Metrics & Live Registration Feed
│   ├── events.html             # Tabbed Event Table (Approved, Pending, Closed)
│   ├── event-form.html         # Create & Edit Event Publishing Form
│   ├── venues.html             # Smart Venue Status & Capacity Cards
│   ├── broadcasts.html         # Campus Broadcast Transmission Center
│   └── users.html              # Student & Coordinator Directory Table
│
├── assets/
│   ├── css/
│   │   └── style.css           # Custom Animations, Glassmorphism & Print Styling
│   └── js/
│       ├── main.js             # Carousel, Search Filters, Modals, LocalStorage Engine
│       └── validation.js       # University ID Regex Pattern, Live Password Strength Meter
│
└── database/
    └── schema.sql              # Relational SQL DDL (For Viva/Report Schema Presentation)
```

---

## 🚀 3. How to Run

1. Open this folder in File Explorer:
   `C:\Users\naimi\.gemini\antigravity\scratch\smart-campus-portal`
2. Simply double-click **`index.html`** to launch in Google Chrome, Microsoft Edge, or Brave.
3. No server, database, or background service is required!

---

## 🛡️ 4. Form Validation & Rubrics Compliance

### Student ID Validation Pattern
- **Regex:** `/^[A-Z]{2,4}-\d{4}-\d{4,5}$/i`
- **Valid Format:** e.g., `MU-2024-10425` or `CE-2023-8891`
- **Live Feedback:** Instant red error message & border highlighting on invalid input; turns green with checkmark upon valid entry.

### Screenshot Demonstration (`validation-demo.html`)
To capture all 5 required test cases for the lab record / report:
1. Open `validation-demo.html` in your browser.
2. Click each state button:
   - **Fig 1.1:** Empty Form Submission Error
   - **Fig 1.2:** Invalid Student ID Format Error
   - **Fig 1.3:** Weak Password Rejection
   - **Fig 1.4:** Password Confirmation Mismatch
   - **Fig 1.5:** Complete Valid Submission (Success)
