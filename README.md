# 🔎 ParameterX

**Parameter Discovery & Behavioral Analysis Tool**  
**Author:** Alham Rizvi


## 🛠 Installation

ParameterX is written in **Python 3** and works best inside a **virtual environment**, especially on security distributions like **Parrot OS** or **Kali Linux**.

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


