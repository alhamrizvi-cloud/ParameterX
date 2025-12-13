<img width="1024" height="768" alt="image" src="https://github.com/user-attachments/assets/d691e2aa-d0cc-470b-9ddd-3640bb1edb51" />
# 🔎 ParameterX

**Parameter Discovery & Behavioral Analysis Tool**  
**Author:** Alham Rizvi

---

## 📌 Description

ParameterX is a **Python-based web security tool** designed for **penetration testers**, especially at the **junior level**.

Its primary purpose is to **discover HTTP parameters** in web applications and **analyze how removing those parameters affects application behavior**. This helps identify parameters that may be vulnerable to **IDOR, logic flaws, or access control issues**.

Think of ParameterX as a **smart reconnaissance and analysis tool** that assists testers in deciding **what to test manually next**.

---

## 🔍 What the Tool Does

ParameterX works in **five main steps**:

### 1️⃣ Baseline Request
- Sends a request to the target URL
- Captures the normal response
- Uses this as a comparison reference

---

### 2️⃣ Parameter Discovery
Extracts parameters from:
- URL query strings (e.g. `?id=1&user_id=2`)
- HTML form inputs
- A built‑in list of common parameters  
  (e.g. `token`, `session_id`, `isAdmin`)

This helps identify **all potential points of user-controlled input**.

---

### 3️⃣ Parameter Removal Test
- Removes each discovered parameter one by one
- Sends a modified request to the server
- Observes how the application responds

---

### 4️⃣ Response Comparison
- Compares the modified response with the baseline
- Calculates a similarity score
- Detects behavioral differences caused by parameter removal

---

### 5️⃣ Risk Indication & Reporting
- Assigns a **risk level** based on response difference:
  - **Low** – No meaningful change
  - **Medium** – Minor behavior change
  - **High** – Significant behavior change
- Outputs results to a JSON file:  
  `parameterx_report.json`

⚠️ Risk levels indicate **parameters worth manual testing**, not confirmed vulnerabilities.

---

## 🛠 Installation

ParameterX is written in **Python 3** and works best inside a **virtual environment**, especially on security-focused Linux distributions like **Parrot OS** or **Kali Linux**.

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/alhamrizvi-cloud/ParameterX
cd ParameterX
python3 -m venv parameterx_venv
source parameterx_venv/bin/activate
pip install requests beautifulsoup4
EXAMPLE:
python3 parameterx.py "http://example.com/page.php?id=1"
```

## 🌍 Run ParameterX as a Global Command (Optional)

You can install ParameterX as a **global Linux command**, allowing you to run it **without `python3`**, just like other security tools.

### 1️⃣ Add a Shebang (Already Included)

Ensure the first line of `parameterx.py` is:

```python
#!/usr/bin/env python3
chmod +x parameterx.py

mv parameterx.py parameterx
sudo mv parameterx /usr/local/bin/
parameterx "http://example.com/page.php?id=1"





