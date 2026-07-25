SELECT * FROM healthcare_dataset LIMIT 10;
SELECT COUNT(*) AS invalid_age_count
FROM healthcare_dataset
WHERE `Age` < 0 OR `Age` > 120;
SELECT COUNT(*) AS invalid_billing_count
FROM healthcare_dataset
WHERE `Billing Amount` < 0;
SELECT DISTINCT `blood type`
FROM healthcare_dataset
WHERE `blood type` NOT IN ('A+','A-','B+','B-','AB+','AB-','O+','O-');
SELECT 
	SUM(CASE WHEN `NAME` IS NULL OR `NAME` = '' THEN 1 ELSE 0 END) AS missing_name,
    SUM(CASE WHEN `Age` IS NULL THEN 1 ELSE 0 END) AS missing_age,
    SUM(CASE WHEN `Medical Condition` IS NULL OR `Medical Condition` = '' THEN 1 ELSE 0 END) AS missing_condition,
    SUM(CASE WHEN `Doctor` IS NULL OR `Doctor` = '' THEN 1 ELSE 0 END) AS missing_doctor,
    SUM(CASE WHEN `Billing Amount` IS NULL THEN 1 ELSE 0 END) AS missing_billing
FROM healthcare_dataset;
SELECT
    ROUND(
        (SUM(CASE WHEN `Name` IS NULL THEN 1 ELSE 0 END)
	   + SUM(CASE WHEN `Age` IS NULL THEN 1 ELSE 0 END)
       + SUM(CASE WHEN `Medical Condition` IS NULL THEN 1 ELSE 0 END))
       / (COUNT(*) * 3) * 100, 2
	) AS overall_missing_pct
FROM healthcare_dataset;
SELECT COUNT(*) AS rows_missing_multi_cols
FROM healthcare_dataset
WHERE (
	(`Name` IS NULL) + (`Age` IS NULL) + (`Medical Condition` IS NULL)
  + (`Doctor` IS NULL) + (`Billing Amount` IS NULL)
) >= 2;
SELECT `Name`
FROM healthcare_dataset
WHERE `Name` <> CONCAT(UPPER(LEFT(`Name`,1)), LOWER(SUBSTRING(`Name`,2)));
SELECT DISTINCT `Gender` FROM healthcare_dataset;
SELECT DISTINCT `Admission Type` FROM healthcare_dataset;
SELECT DISTINCT `Test Results` FROM healthcare_dataset;
SELECT `Discharge Date`, `Date of Admission`
FROM healthcare_dataset
WHERE STR_TO_DATE(`Discharge Date`, '%Y-%m-%d') < STR_TO_DATE(`Date of Admission`, '%Y-%m-%d');
CREATE OR REPLACE VIEW healthcare_relevant AS
SELECT
	`Name`, `Age`, `Gender`, `Blood Type`, `Medical Condition`,
    `Date of Admission`, `Doctor`, `Hospital`, `Insurance Provider`,
    `Billing Amount`, `Room Number`, `Admission Type`, `Discharge Date`,
    `Medication`, `Test Results`
FROM healthcare_dataset;
SELECT MIN(STR_TO_DATE(`Date of Admission`, '%Y-%m-%d')) AS earlist_admission,
       MAX(STR_TO_DATE(`Date of Admission`, '%Y-%m-%d')) AS latest_admission
FROM healthcare_dataset;
SELECT COUNT(*) AS outdated_rows
FROM healthcare_dataset
WHERE STR_TO_DATE(`Date of Admission`, '%Y-%m-%d') < DATE_SUB(CURDATE(), INTERVAL 5 YEAR);
SELECT `Name`, `Age`, `Date of Admission`, `Doctor`, COUNT(*) AS cnt
FROM healthcare_dataset
GROUP BY `Name`, `Age`, `Date of Admission`, `Doctor`
HAVING COUNT(*) > 1;
CREATE TABLE healthcare_dedup AS
SELECT DISTINCT *
FROM healthcare_dataset;
SELECT COUNT(*) AS invalid_test_results
FROM healthcare_dataset
WHERE `Test Results` NOT IN ('Normal', 'Abnormal', 'Inconclusive');
SELECT COUNT(*) AS invalid_rows
FROM healthcare_dataset
WHERE `Age` < 0 OR `Age` > 120 OR `Billing Amount` < 0;
SELECT 
	COUNT(*) AS total_rows,
    SUM(CASE WHEN `Age` < 0 OR `Age` > 120 OR `Billing Amount` < 0
              OR `Name` IS NULL THEN 1 ELSE 0 END) AS problem_rows,
	ROUND(100 - (SUM(CASE WHEN `Age` < 0 OR `Age` > 120 OR `Billing Amount` < 0
              OR `Name` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100), 2) AS quality_score_pct
FROM healthcare_dataset;
SET SQL_SAFE_UPDATES = 0;
DELETE FROM healthcare_dedup
WHERE `Age` < 0 OR `Age` > 120 OR `Billing Amount` <0;
DELETE FROM healthcare_dedup
WHERE `Name` IS NULL OR `Name` = '';
DELETE FROM healthcare_dedup
WHERE `Test Results` NOT IN ('Normal','Abnormal','Inconclusive');
UPDATE healthcare_dedup
SET `Name` = CONCAT(UPPER(LEFT(`Name`,1)), LOWER(SUBSTRING(`Name`,2)));
SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN `Age`< 0 OR `Age` > 120 OR `Billing Amount` <0
              OR `Name` IS NULL THEN 1 ELSE 0 END) AS problem_rows,
	ROUND(100 - (SUM(CASE WHEN `Age` < 0 OR `Age` > 120 OR `Billing Amount` < 0
              OR `Name` IS NULL THEN 1 ELSE 0 END) / COUNT(*) * 100), 2) AS quaiity_score_pct
FROM healthcare_dedup;
SELECT * FROM healthcare_dedup;
SELECT 'Before Cleaning' AS Stage, 55500 AS Total_Rows, 108 Problem_Rows, 99.81 AS Quality_Score
UNION ALL
SELECT 'After Cleaning', 54860, 0, 100.00;