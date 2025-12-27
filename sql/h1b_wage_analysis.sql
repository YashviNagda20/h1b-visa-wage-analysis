-- ============================================================================
-- H1B Visa Wage Analysis - Main Query
-- ============================================================================
-- Project: Optimizing Career Choices for International STEM Students
-- Purpose: Analyze U.S. wage trends across states, industries, and visa types
-- Dataset: 561,000+ H1B visa applications
-- Team: LPY Group
-- ============================================================================

-- QUERY OVERVIEW:
-- This query analyzes wage patterns for Analytics roles by joining data from
-- 6 relational tables to provide comprehensive insights on:
--   1. Geographic wage variations (state-level)
--   2. Industry-specific compensation trends
--   3. Visa class impact on earnings
--   4. Tax and cost-of-living considerations
--   5. City-level job market insights

-- ============================================================================
-- MAIN ANALYSIS QUERY
-- ============================================================================

SELECT 
    -- VISA INFORMATION
    p.visa_class AS visa_class,              -- The visa class associated with the position
                                              -- (H-1B, E-3, H-1B1)
    
    -- JOB DETAILS
    j.Title AS job_title,                    -- The title of the job position
                                              -- (focused on analytics roles)
    
    -- INDUSTRY CLASSIFICATION
    i.naics_industry_name AS industry_name,  -- NAICS industry classification
                                              -- (North American Industry Classification System)
    
    -- WAGE METRICS
    AVG(p.wage_to) AS avg_wage,              -- Average wage for the position
                                              -- (aggregated across similar roles)
    p.wage_unit AS wage_unit,                -- Unit of wage measurement
                                              -- (hourly, annually, weekly)
    
    -- GEOGRAPHIC INFORMATION
    s.state AS state_name,                   -- State where the job is located
    l.worksite_city AS city,                 -- City where the job is located
    
    -- ECONOMIC FACTORS
    s.state_tax_rate,                        -- State income tax rate
                                              -- (affects disposable income)
    s.cost_of_living                         -- Cost of living index for the state
                                              -- (baseline: national average = 100)

FROM 
    -- PRIMARY TABLE: Job Positions
    position p                                -- Main table containing H1B position data
    
    -- JOIN 1: Job Titles
    JOIN job j 
        ON p.job_id = j.id                   -- Link positions to job titles
    
    -- JOIN 2: Location Details
    JOIN location l 
        ON p.location_id = l.id              -- Link positions to geographic locations
    
    -- JOIN 3: State Information
    JOIN state s 
        ON l.state_id = s.id                 -- Link locations to state-level data
                                              -- (tax rates, cost of living)
    
    -- JOIN 4: Employer Information
    JOIN employer e 
        ON p.employer_id = e.id              -- Link positions to employer details
    
    -- JOIN 5: Industry Classification
    JOIN industry i 
        ON e.industry_id = i.id              -- Link employers to industry categories

WHERE 
    -- DATA QUALITY FILTERS
    p.wage_to IS NOT NULL                    -- Exclude positions without wage data
    
    -- ROLE FILTERS
    AND j.Title LIKE '%Analyst%'             -- Focus on Analytics roles
                                              -- (Business Analyst, Data Analyst, etc.)

GROUP BY 
    -- AGGREGATION DIMENSIONS
    p.visa_class,                            -- Group by visa type
    j.Title,                                 -- Group by specific job title
    i.naics_industry_name,                   -- Group by industry
    p.wage_unit,                             -- Group by wage unit
    s.state,                                 -- Group by state
    l.worksite_city,                         -- Group by city
    s.state_tax_rate,                        -- Include tax rate in grouping
    s.cost_of_living                         -- Include cost of living in grouping

ORDER BY 
    avg_wage DESC;                           -- Sort results by highest wages first


-- ============================================================================
-- QUERY METRICS
-- ============================================================================
-- Expected Output Columns: 9
-- Expected Rows: ~50,000+ (varies based on dataset)
-- Processing Time: ~2-5 seconds (depending on database optimization)
-- Data Sources: 6 tables (position, job, location, state, employer, industry)


-- ============================================================================
-- USAGE NOTES
-- ============================================================================
-- 1. This query can be modified to focus on specific job titles by changing
--    the LIKE clause (e.g., '%Data Scientist%', '%Engineer%')
--
-- 2. Additional filters can be added for specific states or industries:
--    Example: AND s.state IN ('California', 'New York', 'Texas')
--
-- 3. For annual wage comparisons only, add:
--    AND p.wage_unit = 'Year'
--
-- 4. To focus on specific visa classes:
--    AND p.visa_class IN ('H-1B', 'E-3')


-- ============================================================================
-- ALTERNATIVE QUERIES
-- ============================================================================

-- Query 1: Top 10 States by Average Wage (Analytics Roles)
-- Uncomment to use:
/*
SELECT 
    s.state AS state_name,
    AVG(p.wage_to) AS avg_wage,
    COUNT(*) AS total_positions
FROM position p
JOIN job j ON p.job_id = j.id
JOIN location l ON p.location_id = l.id
JOIN state s ON l.state_id = s.id
WHERE p.wage_to IS NOT NULL 
    AND j.Title LIKE '%Analyst%'
    AND p.wage_unit = 'Year'
GROUP BY s.state
ORDER BY avg_wage DESC
LIMIT 10;
*/

-- Query 2: Industry Comparison by Average Wage
-- Uncomment to use:
/*
SELECT 
    i.naics_industry_name AS industry,
    AVG(p.wage_to) AS avg_wage,
    COUNT(*) AS total_positions,
    MIN(p.wage_to) AS min_wage,
    MAX(p.wage_to) AS max_wage
FROM position p
JOIN job j ON p.job_id = j.id
JOIN employer e ON p.employer_id = e.id
JOIN industry i ON e.industry_id = i.id
WHERE p.wage_to IS NOT NULL 
    AND j.Title LIKE '%Analyst%'
    AND p.wage_unit = 'Year'
GROUP BY i.naics_industry_name
ORDER BY avg_wage DESC
LIMIT 20;
*/

-- Query 3: Disposable Income Calculation (Tax-Adjusted)
-- Uncomment to use:
/*
SELECT 
    s.state AS state_name,
    AVG(p.wage_to) AS avg_wage,
    AVG(p.wage_to * (1 - s.state_tax_rate/100)) AS avg_disposable_income,
    s.state_tax_rate,
    s.cost_of_living
FROM position p
JOIN job j ON p.job_id = j.id
JOIN location l ON p.location_id = l.id
JOIN state s ON l.state_id = s.id
WHERE p.wage_to IS NOT NULL 
    AND j.Title LIKE '%Analyst%'
    AND p.wage_unit = 'Year'
GROUP BY s.state, s.state_tax_rate, s.cost_of_living
ORDER BY avg_disposable_income DESC
LIMIT 10;
*/


-- ============================================================================
-- DATABASE SCHEMA REFERENCE
-- ============================================================================
-- 
-- TABLE: position
--   - id (PRIMARY KEY)
--   - job_id (FOREIGN KEY -> job.id)
--   - employer_id (FOREIGN KEY -> employer.id)
--   - location_id (FOREIGN KEY -> location.id)
--   - visa_class (VARCHAR)
--   - wage_to (DECIMAL)
--   - wage_unit (VARCHAR)
--
-- TABLE: job
--   - id (PRIMARY KEY)
--   - Title (VARCHAR)
--
-- TABLE: location
--   - id (PRIMARY KEY)
--   - state_id (FOREIGN KEY -> state.id)
--   - worksite_city (VARCHAR)
--
-- TABLE: state
--   - id (PRIMARY KEY)
--   - state (VARCHAR)
--   - state_tax_rate (DECIMAL)
--   - cost_of_living (DECIMAL)
--
-- TABLE: employer
--   - id (PRIMARY KEY)
--   - industry_id (FOREIGN KEY -> industry.id)
--
-- TABLE: industry
--   - id (PRIMARY KEY)
--   - naics_industry_name (VARCHAR)
--
-- ============================================================================

-- END OF QUERY FILE
