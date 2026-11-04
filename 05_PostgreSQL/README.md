
# 🔄 Hybrid Architecture: Cloud to PostgreSQL Data Warehouse via DuckDB

## 📌 Project Overview

This project establishes a complete end-to-end data warehousing pipeline. Instead of manually downloading heavy cloud-hosted `.csv` datasets to a local machine, this architecture leverages **DuckDB as a high-performance streaming engine** to ingest remote cloud data and pipe it directly into a local production-grade **PostgreSQL** database.

Once the data is streamed into PostgreSQL, the remaining transformation scripts, data marts, and warehouse builds are executed natively inside PostgreSQL.

---

## 🛠️ Environment & Prerequisites Setup

### 1. Database Administration (pgAdmin)

* Download and install **pgAdmin** via the official PostgreSQL installer.
* Open pgAdmin and initialize the default database if not already present:
  * **Database Name:** `postgres`
  * **Username:** `postgres`
  * **Password:** `password`

### 2. Ideation & Execution Environment (VS Code)

To execute queries natively against PostgreSQL from your editor, configure the following:

* Install the **SQLTools** and **SQLTools PostgreSQL Driver** extensions in VS Code.
* Establish a connection to your target database (e.g., `postgres` or your project database `sql_course`).
* **Execution Shortcut:** Highlight your query and press `⌘E + ⌘E` (Mac) or `Ctrl+E + Ctrl+E` (Windows/Linux) to view results instantly in the right-hand panel.

---

## 🏗️ Data Ingestion & Pipeline Workflow

Because PostgreSQL cannot natively stream directly from HTTP/Cloud URLs without complex wrapper extensions, **DuckDB** is introduced purely as an ingestion engine.
