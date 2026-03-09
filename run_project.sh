#!/usr/bin/env bash
# ============================================================
#  run_project.sh  —  One-shot runner for the Healthcare
#                     Payment Integrity analysis project.
#
#  Usage:   bash run_project.sh
#  Works on macOS and Linux. Requires Python 3.9+.
# ============================================================

set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; BLUE='\033[0;34m'
BOLD='\033[1m'; NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $*"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $*"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $*"; exit 1; }
header(){ echo -e "\n${BOLD}${BLUE}══════════════════════════════════════════${NC}"; \
          echo -e "${BOLD}  $*${NC}"; \
          echo -e "${BOLD}${BLUE}══════════════════════════════════════════${NC}"; }

# ── locate project root ─────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"
header "Healthcare Payment Integrity — Project Runner"
info "Project root: $SCRIPT_DIR"

# ── find Python ─────────────────────────────────────────────
PYTHON=""
for candidate in \
    "$SCRIPT_DIR/venv/bin/python" \
    "$HOME/.pyenv/versions/3.11.9/bin/python" \
    "$(command -v python3 2>/dev/null)" \
    "$(command -v python 2>/dev/null)"; do
    if [[ -x "$candidate" ]]; then
        ver=$("$candidate" -c 'import sys; print(sys.version_info[:2])' 2>/dev/null || true)
        if [[ "$ver" > "(3, 8)" ]]; then
            PYTHON="$candidate"
            break
        fi
    fi
done
[[ -z "$PYTHON" ]] && fail "Python 3.9+ not found. Install it first."
ok "Using Python: $PYTHON ($($PYTHON --version 2>&1))"

PIP="$PYTHON -m pip"

# ── install / upgrade required packages ─────────────────────
header "Step 1 — Installing dependencies"
$PIP install --quiet --upgrade pip
$PIP install --quiet \
    "pandas>=2.0" "numpy>=1.26" "matplotlib>=3.8" \
    "seaborn>=0.13" "plotly>=5.18" "scipy>=1.11" \
    "openpyxl>=3.1" "xlrd>=2.0" "SQLAlchemy>=2.0" \
    "nbformat>=5.9" "nbconvert>=7.14" \
    "jupyterlab>=4.0" "ipykernel>=6.0"
ok "All packages installed."

# ── run notebooks ────────────────────────────────────────────
run_nb() {
    local nb="$1" label="$2"
    info "Running $label …"
    $PYTHON -m jupyter nbconvert \
        --to notebook --execute --inplace \
        --ExecutePreprocessor.timeout=600 \
        --ExecutePreprocessor.kernel_name=python3 \
        "$nb" 2>&1 | tail -3
    ok "$label — done."
}

header "Step 2 — Running notebooks (1 → 6)"
run_nb "notebooks/1_understanding.ipynb"  "Notebook 1: Data Understanding"
run_nb "notebooks/2_cleaning.ipynb"       "Notebook 2: Data Cleaning"
run_nb "notebooks/3_database_setup.ipynb" "Notebook 3: Database Setup"
run_nb "notebooks/4_python_analysis.ipynb""Notebook 4: Python Analysis"
run_nb "notebooks/5_sql_analysis.ipynb"   "Notebook 5: SQL Analysis"
run_nb "notebooks/6_advanced_case_study.ipynb" "Notebook 6: Advanced Case Study"

# ── generate PDF report ──────────────────────────────────────
header "Step 3 — Generating PDF report"
$PYTHON generate_report.py
ok "PDF report ready: Healthcare_Payment_Integrity_Report.pdf"

# ── verify outputs ───────────────────────────────────────────
header "Step 4 — Verifying outputs"
MISSING=0
for f in \
    "data/healthcare.db" \
    "data/cleaned/inpatient_payments_cleaned.csv" \
    "data/cleaned/provider_info_cleaned.csv" \
    "data/cleaned/drg_details_cleaned.csv" \
    "data/cleaned/master_inpatient_payments_cleaned.csv" \
    "Healthcare_Payment_Integrity_Report.pdf"; do
    if [[ -f "$f" ]]; then
        size=$(du -h "$f" | cut -f1)
        ok "$f  ($size)"
    else
        echo -e "${RED}[MISSING]${NC} $f"
        MISSING=$((MISSING+1))
    fi
done

echo ""
if [[ $MISSING -eq 0 ]]; then
    echo -e "${BOLD}${GREEN}All done! Project ran successfully.${NC}"
    echo -e "Open ${BOLD}Healthcare_Payment_Integrity_Report.pdf${NC} for the full analysis."
else
    fail "$MISSING output file(s) missing. Check errors above."
fi
