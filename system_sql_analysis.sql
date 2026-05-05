CREATE DATABASE system_monitoring;
USE system_monitoring;

DESCRIBE set2_cleaned_sys_data

-- To check for CPU Spikes

SELECT count(*) FROM set2_cleaned_sys_data
WHERE overall_cpu_stress > 1.0 
ORDER BY overall_cpu_stress DESC;

-- 45 record

-- To check Memory Stability

SELECT AVG(memory_used_percent), MAX(memory_used_percent), MIN(memory_used_percent) 
FROM set2_cleaned_sys_data;

-- 1,What was the peak stress period
SELECT hour, overall_cpu_stress
FROM set2_cleaned_sys_data
ORDER BY overall_cpu_stress DESC 
LIMIT 5; 

-- hour = 6,3,20,22,9

-- 2, What was the less stress period
SELECT hour, overall_cpu_stress
FROM set2_cleaned_sys_data
ORDER BY overall_cpu_stress asc
LIMIT 5;

-- hour = 12,17,18,13

-- 3,Is our memory usage becoming "dangerous"?
-- KPI: Average vs. Max Memory Usage.

SELECT AVG(memory_used_percent) AS avg_memory, 
       MAX(memory_used_percent) AS max_memory,
       (MAX(memory_used_percent) - AVG(memory_used_percent)) AS variance
FROM set2_cleaned_sys_data;

-- Which hour of the day is the "busiest"

SELECT hour AS hour_of_day, 
       AVG('load-1m') AS avg_load 
FROM set2_cleaned_sys_data
GROUP BY hour_of_day
ORDER BY avg_load DESC;

SELECT hour AS hour_of_day, 
       AVG(overall_cpu_stress) AS avg_load 
FROM set2_cleaned_sys_data
GROUP BY hour_of_day
ORDER BY avg_load DESC;

-- How often does the system go into "High Stress"?
-- KPI: Stress Frequency Count.

SELECT 
    CASE 
        WHEN  overall_cpu_stress > 1.0 THEN 'High Stress'
        WHEN overall_cpu_stress BETWEEN 0.5 AND 1.0 THEN 'Moderate'
        ELSE 'Low/Idle'
    END AS stress_category,
    COUNT(*) AS occurrence_count
FROM set2_cleaned_sys_data
GROUP BY stress_category;

-- Correlation between Disk and CPU?
-- KPI: Multi-metric behavior.

SELECT hour, overall_cpu_stress, disk_activity 
FROM set2_cleaned_sys_data
WHERE disk_activity > (SELECT AVG(disk_activity) FROM set2_cleaned_sys_data)
AND overall_cpu_stress > 0.8;