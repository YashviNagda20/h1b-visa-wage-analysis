# Data Documentation

## H1B Visa Wage Analysis Dataset

---

<img width="1546" height="771" alt="image" src="https://github.com/user-attachments/assets/96c3cc81-4dbc-4203-a4d9-3afeb7381132" />



## Overview

This folder contains the complete dataset used for analyzing H1B visa wage patterns across U.S. states, industries, and visa classes.

**Dataset Size**: 561,000+ H1B visa applications  
**File Format**: Microsoft Excel (.xlsx)  
**Data Period**: 2023-2024   
**Source**: U.S. Department of Labor H1B disclosure data

---

## File Description

### `h1b_data.xlsx`

The primary dataset containing H1B visa application information with wage, location, employer, and industry details.

**File Size**: ~100-200 MB (varies based on actual data)  
**Encoding**: UTF-8  
**Sheets**: Multiple relational tables (see Database Schema below)

---

## Database Schema

The dataset is structured as a **normalized relational database** with 6 interconnected tables:

### 1. **position** (Primary Table)
Main table containing H1B position details

| Column | Data Type | Description |
|--------|-----------|-------------|
| `id` | INTEGER | Primary key - unique position identifier |
| `job_id` | INTEGER | Foreign key → job.id |
| `employer_id` | INTEGER | Foreign key → employer.id |
| `location_id` | INTEGER | Foreign key → location.id |
| `visa_class` | VARCHAR | Visa classification (H-1B, E-3, H-1B1) |
| `wage_to` | DECIMAL | Maximum wage for the position |
| `wage_from` | DECIMAL | Minimum wage for the position |
| `wage_unit` | VARCHAR | Wage unit (Year, Hour, Week, Month) |
| `case_status` | VARCHAR | Application status (Certified, Denied, etc.) |

**Estimated Rows**: 561,000+

---

### 2. **job** (Job Titles)
Contains standardized job titles

| Column | Data Type | Description |
|--------|-----------|-------------|
| `id` | INTEGER | Primary key - unique job identifier |
| `Title` | VARCHAR | Job title (e.g., "Data Analyst", "Business Analyst") |
| `soc_code` | VARCHAR | Standard Occupational Classification code |

**Estimated Rows**: 5,000-10,000 unique job titles

---

### 3. **location** (Geographic Data)
Geographic information for job positions

| Column | Data Type | Description |
|--------|-----------|-------------|
| `id` | INTEGER | Primary key - unique location identifier |
| `state_id` | INTEGER | Foreign key → state.id |
| `worksite_city` | VARCHAR | City where work will be performed |
| `worksite_county` | VARCHAR | County information |
| `worksite_postal_code` | VARCHAR | ZIP/postal code |

**Estimated Rows**: 20,000-30,000 unique locations

---

### 4. **state** (State-Level Data)
State information with economic indicators

| Column | Data Type | Description |
|--------|-----------|-------------|
| `id` | INTEGER | Primary key - unique state identifier |
| `state` | VARCHAR | State name (e.g., "California", "Texas") |
| `state_abbreviation` | VARCHAR(2) | Two-letter state code (e.g., "CA", "TX") |
| `state_tax_rate` | DECIMAL | State income tax rate (percentage) |
| `cost_of_living` | DECIMAL | Cost of living index (100 = national average) |

**Estimated Rows**: 50 (U.S. states + territories)

**Tax Rate Examples**:
- Washington, Texas, Florida: 0% (no state income tax)
- California: 13.3% (top bracket)
- New York: 10.9% (top bracket)

---

### 5. **employer** (Employer Information)
Company/organization details

| Column | Data Type | Description |
|--------|-----------|-------------|
| `id` | INTEGER | Primary key - unique employer identifier |
| `employer_name` | VARCHAR | Company/organization name |
| `industry_id` | INTEGER | Foreign key → industry.id |
| `employer_city` | VARCHAR | Employer headquarters city |
| `employer_state` | VARCHAR | Employer headquarters state |

**Estimated Rows**: 100,000+ unique employers

---

### 6. **industry** (Industry Classification)
NAICS industry categorization

| Column | Data Type | Description |
|--------|-----------|-------------|
| `id` | INTEGER | Primary key - unique industry identifier |
| `naics_code` | VARCHAR | NAICS (North American Industry Classification System) code |
| `naics_industry_name` | VARCHAR | Industry name/description |
| `industry_sector` | VARCHAR | Broad industry sector |

**Estimated Rows**: 1,000+ industry categories

**Example Industries**:
- Computer Systems Design and Related Services
- Management, Scientific, and Technical Consulting Services
- Pharmaceutical and Medicine Manufacturing
- Investment Banking and Securities Dealing

---

## Data Relationships

```
position (PRIMARY)
    ├── job_id → job.id
    ├── employer_id → employer.id
    │       └── industry_id → industry.id
    └── location_id → location.id
            └── state_id → state.id
```

**Query Pattern**: Most analyses join all 6 tables to combine:
- Position wage data
- Job titles
- Geographic location
- State economics
- Employer details
- Industry classification

---

## Data Quality Notes

### Completeness
- **Wage Data**: ~95% complete (some positions lack wage information)
- **Location Data**: ~98% complete
- **Industry Classification**: ~90% complete (some employers lack NAICS codes)

### Data Cleaning Applied
1. **Null Handling**: Rows with missing wage data excluded from analysis
2. **Outlier Treatment**: Extreme outliers (>$3M or <$30K) flagged for review
3. **Standardization**: Job titles normalized to common formats
4. **Geocoding**: City names standardized to USPS format

### Known Limitations
- Some positions list wage ranges; we use `wage_to` (maximum) for analysis
- Wage units vary; queries should filter for consistent units (typically "Year")
- Part-time vs full-time not explicitly differentiated
- Some employers have incomplete industry classifications

---

## Data Sources

### Primary Source
**U.S. Department of Labor - Office of Foreign Labor Certification (OFLC)**
- H1B disclosure data (publicly available)
- Updated quarterly
- Available at: https://www.dol.gov/agencies/eta/foreign-labor/performance

### Supplementary Data
1. **Tax Rates**: State tax authority websites + Tax Foundation research
2. **Cost of Living**: Missouri Economic Research and Information Center (MERIC)
3. **NAICS Codes**: U.S. Census Bureau classification system
4. **SOC Codes**: Bureau of Labor Statistics Occupational Classification

---

## Usage Guidelines

### Loading the Data

**Excel**:
```
1. Open h1b_data.xlsx
2. Navigate between sheets for different tables
3. Use Excel's Data → Relationships to explore connections
```

**Python (pandas)**:
```python
import pandas as pd

# Load all sheets
excel_file = pd.ExcelFile('h1b_data.xlsx')

# Load individual tables
position_df = pd.read_excel(excel_file, sheet_name='position')
job_df = pd.read_excel(excel_file, sheet_name='job')
location_df = pd.read_excel(excel_file, sheet_name='location')
state_df = pd.read_excel(excel_file, sheet_name='state')
employer_df = pd.read_excel(excel_file, sheet_name='employer')
industry_df = pd.read_excel(excel_file, sheet_name='industry')
```

**SQL Import** (if converting to database):
```sql
-- Use Excel import wizard in MySQL Workbench, SQL Server Management Studio,
-- or pgAdmin to import each sheet as a separate table
```

---

### Analysis Recommendations

1. **Always filter for annual wages** when comparing salaries:
   ```sql
   WHERE wage_unit = 'Year'
   ```

2. **Exclude null wages** for accurate averages:
   ```sql
   WHERE wage_to IS NOT NULL
   ```

3. **Join all relevant tables** for comprehensive insights:
   ```sql
   FROM position p
   JOIN job j ON p.job_id = j.id
   JOIN location l ON p.location_id = l.id
   JOIN state s ON l.state_id = s.id
   JOIN employer e ON p.employer_id = e.id
   JOIN industry i ON e.industry_id = i.id
   ```

4. **Consider sample sizes** when analyzing niche categories:
   - Some states/industries may have <100 positions
   - Use COUNT(*) to verify statistical significance

---

## Data Privacy & Ethics

### Compliance
- All data is **publicly disclosed** by the U.S. Department of Labor
- No personal identifying information (PII) is included
- Employer and location data is publicly available

### Ethical Use
- Data should be used for research, educational, and career planning purposes
- Avoid drawing definitive conclusions from small sample sizes
- Consider broader economic and social context when interpreting findings

---

## Updates & Maintenance

**Last Updated**: December 2024  
**Update Frequency**: As needed (source data updated quarterly)  
**Version**: 1.0

To request updated data or report data quality issues, please open an issue in this repository.

---

## Additional Resources

- **OFLC Performance Data**: https://www.dol.gov/agencies/eta/foreign-labor/performance
- **NAICS Classification**: https://www.census.gov/naics/
- **BLS Occupational Data**: https://www.bls.gov/oes/
- **State Tax Information**: https://taxfoundation.org/

---

**Questions?** Open an issue in the repository or contact the project team. Yashvi Nagda, Priyanka Nath and Lordina 
