/*  
-- =========================================================
-- BPO CUSTOMER SUPPORT - MIS & PERFORMANCE ANALYTICS
-- =========================================================
-- Database: bpo_mis_project
-- Main Table: support_data
-- Master Table: agent_master
-- Records: 18,000
-- Agents: 100
-- Purpose:
-- Analyze BPO operational performance, agent productivity,
-- service quality, workload and business performance.
-- =========================================================
*/


/* 
-- =========================================================
-- SECTION 1: DATA VALIDATION
-- =========================================================
*/

/*
-- Q1. a)How many support records are available? 

We need to verify that the database contains the expected 
18,000 records before doing any analysis.
*/

SELECT COUNT(*) AS Total_Records
FROM support_data;



/* Reporting Period 
 Q2. What is the reporting period? 
 
 An MIS report must clearly establish 
 which period is being analyzed.
 */

SELECT
    MIN(Date) AS Start_Date,
    MAX(Date) AS End_Date
FROM support_data;



/* Missing Values
  Q3. Check missing values in critical fields.

We need to ensure missing values aren't affecting our KPIs.
 */

SELECT
    SUM(CASE WHEN Date IS NULL THEN 1 ELSE 0 END) AS Missing_Date,
    SUM(CASE WHEN Agent_ID IS NULL THEN 1 ELSE 0 END) AS Missing_Agent_ID,
    SUM(CASE WHEN Tickets_Received IS NULL THEN 1 ELSE 0 END) AS Missing_Tickets_Received,
    SUM(CASE WHEN Tickets_Resolved IS NULL THEN 1 ELSE 0 END) AS Missing_Tickets_Resolved,
    SUM(CASE WHEN AHT_Minutes IS NULL THEN 1 ELSE 0 END) AS Missing_AHT,
    SUM(CASE WHEN CSAT IS NULL THEN 1 ELSE 0 END) AS Missing_CSAT
FROM support_data;



/* 
-- =========================================================
-- SECTION 2: EXECUTIVE KPI ANALYSIS
-- =========================================================

The goal here is to answer:

"How is the BPO operation performing overall?"
*/



/* Overall Operational KPI's
 * Q.4) What is the overall performance of the BPO operation?
 * 
 * Why are we doing this?

A manager doesn't want to look through 18,000 records.

They need a quick summary of:

Workload
Productivity
Efficiency
Service quality
Customer satisfaction
Pending work
Escalations
 */


SELECT
    SUM(Tickets_Received) AS Total_Tickets_Received,
    SUM(Tickets_Resolved) AS Total_Tickets_Resolved,
    SUM(Backlog) AS Total_Backlog,
    AVG(AHT_Minutes) AS Average_AHT,
    AVG(SLA_Met) * 100 AS SLA_Percentage,
    AVG(CSAT) AS Average_CSAT,
    SUM(Escalations) AS Total_Escalations
FROM support_data;



/* Workload vs Resolution Gaps
 * 
 * Q.5) How much workload remains unresolved?
 *		 Calculate the gap between tickets received and resolved

Unresolved gap highlights the difference between 
incoming workload and completed tickets.
 */


SELECT
    SUM(Tickets_Received) AS Total_Received,
    SUM(Tickets_Resolved) AS Total_Resolved,

    SUM(Tickets_Received) -
    SUM(Tickets_Resolved) AS Unresolved_Gap

FROM support_data;




/* How much workload remains unresolved?
 
 Are we resolving as many tickets as we are receiving?

This is important because if incoming tickets consistently 
exceed resolved tickets, the unresolved workload can increase.
 
 Q.6 Compare received vs resolved workload
 */

SELECT
    SUM(Tickets_Received) AS Total_Received,
    SUM(Tickets_Resolved) AS Total_Resolved,
    SUM(Tickets_Received) - SUM(Tickets_Resolved) AS Unresolved_Gap
FROM support_data;




/* 
-- =========================================================
-- SECTION 3: TIME & TREND ANALYSIS
-- =========================================================

The goal here is to answer:

"How does ticket workload change over time?"
*/


/* Q 7. How do received, resolved and backlog volumes change from day to day?

Why?
This helps management identify:
Increasing workload
Busy periods
Falling productivity
Backlog accumulation
*/

SELECT
    Date,
    SUM(Tickets_Received) AS Tickets_Received,
    SUM(Tickets_Resolved) AS Tickets_Resolved,
    SUM(Backlog) AS Backlog
FROM support_data
GROUP BY Date
ORDER BY Date;



/* Q 8. On which days did service-level performance perform best or worst?

Daily SLA analysis identifies variations 
in service-level performance over time.

Daily SLA analysis identifies variations in service-level performance over time.
*/

SELECT
    Date,
    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage
FROM support_data
GROUP BY Date
ORDER BY SLA_Percentage DESC;



/*
-- =========================================================
-- SECTION 4: AGENT PERFORMANCE ANALYSIS
-- =========================================================
*/

/* Q9. What is each agent's overall performance ?
 
  Management needs one table where they can compare 
  agents instead of checking separate reports for tickets, AHT, SLA, CSAT, etc.
 
 Agent Performance Scorecard
 Agent performance scorecard evaluates productivity, efficiency, 
 service quality, customer satisfaction and workload at the individual agent level.
 */


SELECT
    Agent_ID,
    Agent_Name,

    SUM(Tickets_Received) AS Tickets_Received,

    SUM(Tickets_Resolved) AS Tickets_Resolved,

    ROUND(
        SUM(Tickets_Resolved) /
        NULLIF(SUM(Tickets_Received), 0) * 100,
        2
    ) AS Resolution_Percentage,

    ROUND(AVG(AHT_Minutes), 2) AS Average_AHT,

    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage,

    ROUND(AVG(CSAT), 2) AS Average_CSAT,

    SUM(Backlog) AS Total_Backlog,

    SUM(Escalations) AS Total_Escalations

FROM support_data

GROUP BY Agent_ID, Agent_Name

ORDER BY Resolution_Percentage DESC;



/* Q10. Who are the top 10 agents? 
 
 Which agents have the highest resolution performance?
 */

SELECT
    Agent_ID,
    Agent_Name,

    SUM(Tickets_Received) AS Tickets_Received,

    SUM(Tickets_Resolved) AS Tickets_Resolved,

    ROUND(
        SUM(Tickets_Resolved) /
        NULLIF(SUM(Tickets_Received), 0) * 100,
        2
    ) AS Resolution_Percentage,

    ROUND(AVG(AHT_Minutes), 2) AS Average_AHT,

    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage,

    ROUND(AVG(CSAT), 2) AS Average_CSAT

FROM support_data

GROUP BY Agent_ID, Agent_Name

ORDER BY Resolution_Percentage DESC

LIMIT 10;




/* Q11. Who has high workload but low resolution? 
  
  
  Identifies agents handling above-average workload 
  while maintaining below-target resolution performance.
 */


SELECT
    Agent_ID,
    Agent_Name,

    SUM(Tickets_Received) AS Tickets_Received,

    SUM(Tickets_Resolved) AS Tickets_Resolved,

    ROUND(
        SUM(Tickets_Resolved) /
        NULLIF(SUM(Tickets_Received), 0) * 100,
        2
    ) AS Resolution_Percentage,

    SUM(Backlog) AS Total_Backlog,

    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage,

    ROUND(AVG(CSAT), 2) AS Average_CSAT

FROM support_data

GROUP BY Agent_ID, Agent_Name

HAVING
    SUM(Tickets_Received) >
    (
        SELECT AVG(Agent_Tickets)
        FROM
        (
            SELECT
                Agent_ID,
                SUM(Tickets_Received) AS Agent_Tickets
            FROM support_data
            GROUP BY Agent_ID
        ) AS Agent_Workload
    )
    AND
    SUM(Tickets_Resolved) /
    NULLIF(SUM(Tickets_Received), 0) * 100 < 80

ORDER BY Total_Backlog DESC;


/*
-- =========================================================
-- SECTION 5: TEAM PERFORMANCE ANALYSIS
-- =========================================================

Which BPO team is performing well, and where are the operational problems?

*/

/* Q12 — How is each team performing?
 "Team Performance Scorecard"
Why?
This gives management a complete comparison of teams using the most important KPIs:

Workload
Resolution
AHT
SLA
CSAT
Backlog
Escalations
*/

SELECT
    Team,

    SUM(Tickets_Received) AS Tickets_Received,

    SUM(Tickets_Resolved) AS Tickets_Resolved,

    ROUND(
        SUM(Tickets_Resolved) /
        NULLIF(SUM(Tickets_Received), 0) * 100,
        2
    ) AS Resolution_Percentage,

    ROUND(AVG(AHT_Minutes), 2) AS Average_AHT,

    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage,

    ROUND(AVG(CSAT), 2) AS Average_CSAT,

    SUM(Backlog) AS Total_Backlog,

    SUM(Escalations) AS Total_Escalations

FROM support_data

GROUP BY Team

ORDER BY Resolution_Percentage DESC;




/* 
-- =========================================================
-- SECTION 6: CATEGORY ANALYSIS
-- =========================================================

We want to understand what types of customer 
issues are creating workload and operational problems.
*/

/* Q13. Category workload and resolution analysis
  
  Category analysis identifies major sources of customer 
  support workload and their resolution performance.
 */

SELECT
    Category,

    SUM(Tickets_Received) AS Tickets_Received,

    SUM(Tickets_Resolved) AS Tickets_Resolved,

    ROUND(
        SUM(Tickets_Resolved) /
        NULLIF(SUM(Tickets_Received), 0) * 100,
        2
    ) AS Resolution_Percentage,

    SUM(Backlog) AS Total_Backlog

FROM support_data

GROUP BY Category

ORDER BY Tickets_Received DESC;



/* Q14. Which categories have service-quality concerns ?
 
 Identifies categories with potential service-quality concerns
 */


SELECT
    Category,

    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage,

    ROUND(AVG(CSAT), 2) AS Average_CSAT,

    ROUND(AVG(AHT_Minutes), 2) AS Average_AHT,

    ROUND(AVG(First_Response_Minutes), 2) AS Average_First_Response,

    SUM(Backlog) AS Total_Backlog,

    SUM(Escalations) AS Total_Escalations

FROM support_data

GROUP BY Category

ORDER BY
    SLA_Percentage ASC,
    Average_CSAT ASC;



/* 
-- =========================================================
-- SECTION 7: PRIORITY ANALYSIS
-- =========================================================
Which ticket priority levels generate the highest workload, 
backlog, and escalations?
*/

/* Q15. Which ticket priorities create the most operational pressure?
  
Identifies ticket priorities creating the highest workload, 
backlog and operational pressure.

 */

SELECT
    Priority,

    SUM(Tickets_Received) AS Tickets_Received,

    SUM(Tickets_Resolved) AS Tickets_Resolved,

    ROUND(
        SUM(Tickets_Resolved) /
        NULLIF(SUM(Tickets_Received), 0) * 100,
        2
    ) AS Resolution_Percentage,

    SUM(Backlog) AS Total_Backlog,

    SUM(Escalations) AS Total_Escalations

FROM support_data

GROUP BY Priority

ORDER BY Tickets_Received DESC;



/* Q16. Do different priority levels have different service-quality performance?
  
  How does service quality differ across High, 
  Medium, and Low priority tickets?
  
  Compares service quality across ticket priority levels
  using SLA, response time, AHT and customer satisfaction.
*/

SELECT
    Priority,

    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage,

    ROUND(AVG(First_Response_Minutes), 2) AS Average_First_Response,

    ROUND(AVG(AHT_Minutes), 2) AS Average_AHT,

    ROUND(AVG(CSAT), 2) AS Average_CSAT

FROM support_data

GROUP BY Priority

ORDER BY SLA_Percentage ASC, Average_CSAT ASC;



/* 
-- =========================================================
-- SECTION 8: SHIFT & WORKSPACE ANALYSIS
-- =========================================================
Which shift performs better overall?
*/

/* Q17. How does operational performance and workforce availability differ across shifts?
  
Compares workload, productivity, service quality
and workforce attendance across operational shifts.

 */

SELECT
    Shift,

    SUM(Tickets_Received) AS Tickets_Received,

    SUM(Tickets_Resolved) AS Tickets_Resolved,

    ROUND(
        SUM(Tickets_Resolved) /
        NULLIF(SUM(Tickets_Received), 0) * 100,
        2
    ) AS Resolution_Percentage,

    ROUND(AVG(AHT_Minutes), 2) AS Average_AHT,

    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage,

    ROUND(AVG(CSAT), 2) AS Average_CSAT,

    SUM(Backlog) AS Total_Backlog,

    SUM(Escalations) AS Total_Escalations,

    ROUND(
        AVG(
            CASE
                WHEN Attendance = 'Present' THEN 1
                ELSE 0
            END
        ) * 100,
        2
    ) AS Attendance_Percentage

FROM support_data

GROUP BY Shift

ORDER BY SLA_Percentage DESC;



/* 
-- =========================================================
-- SECTION 9: FINAL BUSINESS BOTTLENECK ANALYSIS
-- =========================================================
Which support categories show the highest operational pressure when workload, 
backlog, SLA, customer satisfaction, handling time, and escalations are considered together?
*/

/* Q18. Which operational areas require the most management attention?
  
Combines workload, backlog, service quality and escalations
to identify potential operational bottlenecks.

 */


SELECT
    Category,

    SUM(Tickets_Received) AS Tickets_Received,

    SUM(Tickets_Resolved) AS Tickets_Resolved,

    ROUND(
        SUM(Tickets_Resolved) /
        NULLIF(SUM(Tickets_Received), 0) * 100,
        2
    ) AS Resolution_Percentage,

    SUM(Backlog) AS Total_Backlog,

    ROUND(AVG(SLA_Met) * 100, 2) AS SLA_Percentage,

    ROUND(AVG(CSAT), 2) AS Average_CSAT,

    ROUND(AVG(AHT_Minutes), 2) AS Average_AHT,

    SUM(Escalations) AS Total_Escalations

FROM support_data

GROUP BY Category

ORDER BY
    Total_Backlog DESC,
    SLA_Percentage ASC,
    Average_CSAT ASC;






