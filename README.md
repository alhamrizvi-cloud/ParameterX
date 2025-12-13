# 🔎 ParameterX

**Parameter Discovery & Behavioral Analysis Tool**  
**Author:** Alham Rizvi


## 🛠 Installation

ParameterX is a Python-based web security tool designed for penetration testers, especially at the junior level.
Its primary purpose is discovering HTTP parameters in web applications and analyzing how removing or manipulating them changes the behavior of the application.

## 🔍 What the Tool Does

ParameterX works in five main steps:

Baseline Request

Sends a request to the target URL to get the normal response.

This is used as a comparison point.

Parameter Discovery

Extracts parameters from:

URL query strings (e.g., ?id=1&user_id=2)

HTML form inputs (<input name="email">)

A built-in list of common parameters (e.g., token, session_id, isAdmin)

This helps find all potential points of interest in the app.

Parameter Removal Test

Removes each parameter one by one.

Sends the modified request to the server.

Compares the response to the baseline.

Response Comparison

Measures how similar the responses are (e.g., using a similarity score).

If removing a parameter changes the response, it may indicate hidden logic or access control depending on that parameter.

Risk Indication

Assigns a risk level based on the similarity score:

Low – no change

Medium – minor differences

High – significant behavioral change

Outputs findings in a JSON report (parameterx_report.json) for documentation

Think of it as a smart reconnaissance tool that helps you find parameters that might be vulnerable to IDOR, logic flaws, or access control issues.

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/alhamrizvi-cloud/ParameterX
cd ParameterX

2️⃣ Create a Virtual Environment (Recommended)
python3 -m venv parameterx_venv

3️⃣ Activate the Virtual Environment
source parameterx_venv/bin/activate

4️⃣ Install Required Dependencies
pip install requests beautifulsoup4

▶️ Usage

Run ParameterX by providing a target URL
(use only lab or authorized applications).

python parameterx.py "http://example.com/page.php?id=1"

Example:
python parameterx.py "http://localhost:3000/rest/products?id=1"
```


