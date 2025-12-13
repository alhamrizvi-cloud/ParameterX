🔎 ParameterX

Parameter Discovery & Behavioral Analysis Tool
Author: Alham Rizvi

🛠 Installation

ParameterX is written in Python 3 and works best inside a virtual environment, especially on security distributions like Parrot OS or Kali.

1️⃣ Create a Virtual Environment (Recommended)
python3 -m venv parameterx_venv

2️⃣ Activate the Virtual Environment
source parameterx_venv/bin/activate

3️⃣ Install Required Dependencies
pip install requests beautifulsoup4

▶️ Usage

Run ParameterX by providing a target URL (preferably a lab or authorized application).

python parameterx.py "http://example.com/page.php?id=1"

Example:
python parameterx.py "http://localhost:3000/rest/products?id=1"

🔍 What the Tool Does During Execution

Sends a baseline request to the target URL

Discovers parameters from:

URL query string

HTML form inputs

Built‑in common parameter list

Tests each parameter by removing it

Compares the modified response with the baseline response

Assigns a risk indicator

Saves results to a JSON report

📄 Output Explanation

ParameterX prints results to the terminal and saves them to:

parameterx_report.json

Example Output
{
    "endpoint": "http://example.com/profile",
    "parameter": "user_id",
    "test": "parameter_removal",
    "similarity_score": 0.88,
    "risk": "High"
}

Field Explanation
Field	Description
endpoint	The tested URL
parameter	The parameter being analyzed
test	Type of test performed (currently parameter removal)
similarity_score	How similar the modified response is to the original
risk	Behavior‑based risk indicator
📊 Understanding Risk Levels
Risk	Meaning
Low	Parameter removal caused no meaningful change
Medium	Minor response differences detected
High	Significant behavior change detected

⚠️ Risk does NOT mean vulnerability.
It indicates parameters that require manual validation.

⚠️ Important Notes

ParameterX does not exploit vulnerabilities

Dynamic websites may produce false positives

Always validate findings manually using tools like Burp Suite

Use only on authorized targets or labs

🧪 Recommended Targets

OWASP Juice Shop

PortSwigger Web Security Academy

DVWA

Internal test applications

APIs you own or have permission to test
