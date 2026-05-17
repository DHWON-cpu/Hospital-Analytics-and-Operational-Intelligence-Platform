USE Final_Project_DB_V2;


-- Question 1. What is the average number of appointments per patient in the last 6 months?
-- standard last date/time is final record 
WITH MaxDate AS (
    SELECT MAX(AppointmentDate) AS LatestAppointmentDate
    FROM Appointment
)
SELECT
    COUNT(*) AS TotalPatientsLast6Months,
    AVG(CAST(AppointmentCount AS DECIMAL(10,2))) AS AvgAppointmentsPerPatientLast6Months
FROM (
    SELECT
        a.PatientID,
        COUNT(*) AS AppointmentCount
    FROM Appointment a
    CROSS JOIN MaxDate m
    WHERE a.AppointmentDate >= DATEADD(MONTH, -6, m.LatestAppointmentDate)
    GROUP BY a.PatientID
) x;

-- Q2. How many patient do reappoint during 6 months ?
WITH MaxDate AS (
    SELECT MAX(AppointmentDate) AS LatestAppointmentDate
    FROM Appointment
),

PatientAppointmentCounts AS (
    SELECT
        a.PatientID,
        COUNT(*) AS TotalAppointments
    FROM Appointment a
    CROSS JOIN MaxDate m
    WHERE a.AppointmentDate >= DATEADD(MONTH, -6, m.LatestAppointmentDate)
    GROUP BY a.PatientID
),

PatientScheduledStatus AS (
    SELECT
        a.PatientID,
        MAX(CASE WHEN a.Status = 'Scheduled' THEN 1 ELSE 0 END) AS HasScheduledAppointment
    FROM Appointment a
    CROSS JOIN MaxDate m
    WHERE a.AppointmentDate >= DATEADD(MONTH, -6, m.LatestAppointmentDate)
    GROUP BY a.PatientID
)

SELECT
    COUNT(*) AS TotalPatientsWithAppointments_Last6Months,
    SUM(CASE WHEN pac.TotalAppointments >= 2 THEN 1 ELSE 0 END) AS RebookedPatients_Last6Months,
    CAST(
        SUM(CASE WHEN pac.TotalAppointments >= 2 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS ReappointmentRate_Last6Months,

    SUM(CASE WHEN pss.HasScheduledAppointment = 1 THEN 1 ELSE 0 END) AS PatientsWithScheduled_Last6Months,
    CAST(
        SUM(CASE WHEN pss.HasScheduledAppointment = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS ScheduledPatientRate_Last6Months
FROM PatientAppointmentCounts pac
JOIN PatientScheduledStatus pss
    ON pac.PatientID = pss.PatientID;


-- # Q3.  How does appointment performance vary by month in terms of patient volume, average appointments per patient, and appointment status outcomes?
SELECT
    CAST(YEAR(AppointmentDate) AS VARCHAR(4)) + '-'
    + RIGHT('0' + CAST(MONTH(AppointmentDate) AS VARCHAR(2)), 2) AS YearMonth,

    COUNT(*) AS TotalAppointments,
    COUNT(DISTINCT PatientID) AS UniquePatients,
    CAST(COUNT(*) * 1.0 / COUNT(DISTINCT PatientID) AS DECIMAL(10,2)) AS AvgAppointmentsPerPatient,

    SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedAppointments,
    SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments,
    SUM(CASE WHEN Status = 'Scheduled' THEN 1 ELSE 0 END) AS ScheduledAppointments,

    CAST(SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS CompletionRate,
    CAST(SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS CancellationRate,
    CAST(SUM(CASE WHEN Status = 'Scheduled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS StillScheduledRate
FROM Appointment
GROUP BY
    YEAR(AppointmentDate),
    MONTH(AppointmentDate)
ORDER BY
    YearMonth;

-- # Q4.  최근 6개월 기준, 취소율이 가장 높은 병과
-- Which department has the highest cancellation rate in the last 6 months?
WITH MaxDate AS (
    SELECT MAX(AppointmentDate) AS LatestAppointmentDate
    FROM Appointment
)
SELECT
    d.DepartmentName,
    COUNT(*) AS TotalAppointments_Last6Months,
    SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments_Last6Months,
    CAST(
        SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) * 100.0 / COUNT(*)
        AS DECIMAL(5,2)
    ) AS CancellationRate_Last6Months
FROM Appointment a
JOIN Doctor doc
    ON a.DoctorID = doc.DoctorID
JOIN Department d
    ON doc.DepartmentID = d.DepartmentID
CROSS JOIN MaxDate m
WHERE a.AppointmentDate >= DATEADD(MONTH, -6, m.LatestAppointmentDate)
GROUP BY
    d.DepartmentName
ORDER BY
    CancellationRate_Last6Months DESC,
    CancelledAppointments_Last6Months DESC;


 /*-- Q 5. 
	•	최근 6개월 전체 예약 수
	•	최근 6개월 전체 환자 수
	•	환자당 평균 예약 수
	•	취소 예약 수
	•	취소율
	•	재예약 환자 수
	•	재예약율
환자 수 / 재예약 환자 수 / 평균 예약 수 */
-- ? 

-- 최근 6개월 예약만 추출
-- 의사별 환자 수 / 재예약 환자 수 / 평균 예약 수
-- 	•	MaxDate
--	•	Last6MonthsAppointments
--	•	DoctorAppointmentStats
--	•	DoctorPatientCounts

-- 의사별 환자 수 / 재예약 환자 수 / 평균 예약 수 / scheduled 환자 수
WITH MaxDate AS (
    SELECT MAX(AppointmentDate) AS LatestAppointmentDate
    FROM Appointment
),

-- Recent 6 month appointment
Last6MonthsAppointments AS (
    SELECT
        a.AppointmentID,
        a.PatientID,
        a.DoctorID,
        a.AppointmentDate,
        a.Status
    FROM Appointment a
    CROSS JOIN MaxDate m
    WHERE a.AppointmentDate >= DATEADD(MONTH, -6, m.LatestAppointmentDate)
),

-- 의사별 전체 예약 수 / 완료 수 / 취소 수 / scheduled 수
DoctorAppointmentStats AS (
    SELECT
        DoctorID,
        COUNT(*) AS TotalAppointments_Last6Months,
        SUM(CASE WHEN Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedAppointments_Last6Months,
        SUM(CASE WHEN Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments_Last6Months,
        SUM(CASE WHEN Status = 'Scheduled' THEN 1 ELSE 0 END) AS ScheduledAppointments_Last6Months
    FROM Last6MonthsAppointments
    GROUP BY DoctorID
),

-- 의사-환자별 예약 횟수
DoctorPatientCounts AS (
    SELECT
        DoctorID,
        PatientID,
        COUNT(*) AS AppointmentCount
    FROM Last6MonthsAppointments
    GROUP BY
        DoctorID,
        PatientID
),

-- 의사-환자별 scheduled 예약 존재 여부
DoctorPatientScheduled AS (
    SELECT
        DoctorID,
        PatientID,
        MAX(CASE WHEN Status = 'Scheduled' THEN 1 ELSE 0 END) AS HasScheduledAppointment
    FROM Last6MonthsAppointments
    GROUP BY
        DoctorID,
        PatientID
),

-- 의사별 환자 수 / 재예약 환자 수 / 평균 예약 수 / scheduled 환자 수
DoctorReappointmentStats AS (
    SELECT
        dpc.DoctorID,
        COUNT(*) AS TotalPatients_Last6Months,
        SUM(CASE WHEN dpc.AppointmentCount >= 2 THEN 1 ELSE 0 END) AS RebookedPatients_Last6Months,
        CAST(AVG(CAST(dpc.AppointmentCount AS DECIMAL(10,2))) AS DECIMAL(10,2)) AS AvgAppointmentsPerPatient_Last6Months,
        SUM(CASE WHEN dps.HasScheduledAppointment = 1 THEN 1 ELSE 0 END) AS PatientsWithScheduled_Last6Months
    FROM DoctorPatientCounts dpc
    JOIN DoctorPatientScheduled dps
        ON dpc.DoctorID = dps.DoctorID
       AND dpc.PatientID = dps.PatientID
    GROUP BY
        dpc.DoctorID
)

SELECT
    d.DepartmentName,
    doc.DoctorID,
    doc.FirstName + ' ' + doc.LastName AS DoctorName,

    das.TotalAppointments_Last6Months,
    drs.TotalPatients_Last6Months,
    drs.AvgAppointmentsPerPatient_Last6Months,

    das.CompletedAppointments_Last6Months,
    CAST(
        das.CompletedAppointments_Last6Months * 100.0 / NULLIF(das.TotalAppointments_Last6Months, 0)
        AS DECIMAL(5,2)
    ) AS CompletedRate_Last6Months,

    das.CancelledAppointments_Last6Months,
    CAST(
        das.CancelledAppointments_Last6Months * 100.0 / NULLIF(das.TotalAppointments_Last6Months, 0)
        AS DECIMAL(5,2)
    ) AS CancellationRate_Last6Months,

    das.ScheduledAppointments_Last6Months,
    CAST(
        das.ScheduledAppointments_Last6Months * 100.0 / NULLIF(das.TotalAppointments_Last6Months, 0)
        AS DECIMAL(5,2)
    ) AS ScheduledRate_Last6Months,

    drs.RebookedPatients_Last6Months,
    CAST(
        drs.RebookedPatients_Last6Months * 100.0 / NULLIF(drs.TotalPatients_Last6Months, 0)
        AS DECIMAL(5,2)
    ) AS ReappointmentRate_Last6Months,

    drs.PatientsWithScheduled_Last6Months,
    CAST(
        drs.PatientsWithScheduled_Last6Months * 100.0 / NULLIF(drs.TotalPatients_Last6Months, 0)
        AS DECIMAL(5,2)
    ) AS ScheduledPatientRate_Last6Months

FROM DoctorAppointmentStats das
JOIN DoctorReappointmentStats drs
    ON das.DoctorID = drs.DoctorID
JOIN Doctor doc
    ON das.DoctorID = doc.DoctorID
JOIN Department d
    ON doc.DepartmentID = d.DepartmentID
ORDER BY
    ReappointmentRate_Last6Months ASC,
    ScheduledRate_Last6Months ASC,
    CancellationRate_Last6Months DESC,
    TotalPatients_Last6Months DESC;

--------------
--------------

--------------
--  Q6 예약 취소한 환자의 병명은 ? 

WITH MaxDate AS (
    SELECT MAX(AppointmentDate) AS LatestAppointmentDate
    FROM Appointment
),

CancelledPatients AS (
    SELECT DISTINCT
        a.PatientID
    FROM Appointment a
    CROSS JOIN MaxDate m
    WHERE a.AppointmentDate >= DATEADD(MONTH, -6, m.LatestAppointmentDate)
      AND a.Status = 'Cancelled'
),

RecentMedicalRecords AS (
    SELECT
        mr.RecordID,
        mr.PatientID,
        mr.VisitDate,
        mr.Diagnosis
    FROM MedicalRecord mr
    CROSS JOIN MaxDate m
    WHERE mr.VisitDate >= DATEADD(MONTH, -6, m.LatestAppointmentDate)
),

DiagnosisDistribution AS (
    SELECT
        rm.Diagnosis,
        COUNT(DISTINCT cp.PatientID) AS PatientCount,
        COUNT(*) AS VisitCount
    FROM CancelledPatients cp
    JOIN RecentMedicalRecords rm
        ON cp.PatientID = rm.PatientID
    GROUP BY
        rm.Diagnosis
),

TotalCancelledPatientsWithDiagnosis AS (
    SELECT
        COUNT(DISTINCT cp.PatientID) AS TotalPatients
    FROM CancelledPatients cp
    JOIN RecentMedicalRecords rm
        ON cp.PatientID = rm.PatientID
)

SELECT
    dd.Diagnosis,
    dd.PatientCount,
    dd.VisitCount,
    CAST(dd.PatientCount * 100.0 / t.TotalPatients AS DECIMAL(5,2)) AS PatientDistributionRate
FROM DiagnosisDistribution dd
CROSS JOIN TotalCancelledPatientsWithDiagnosis t
ORDER BY
    dd.PatientCount DESC,
    dd.VisitCount DESC,
    dd.Diagnosis;


-- Q7 재방문율이 높은 병명들 중에서, 취소율도 높은 병명은 무엇인가?
-- Which diagnoses with high reappointment rates also have high cancellation rates?
WITH PatientAppointmentCounts AS (
    SELECT
        PatientID,
        COUNT(*) AS TotalAppointments
    FROM Appointment
    GROUP BY PatientID
),

PatientDiagnosis AS (
    SELECT DISTINCT
        mr.PatientID,
        mr.Diagnosis
    FROM MedicalRecord mr
    WHERE mr.Diagnosis IS NOT NULL
),

DiagnosisReappointmentStats AS (
    SELECT
        pd.Diagnosis,
        COUNT(*) AS TotalPatients,
        SUM(CASE WHEN pac.TotalAppointments >= 2 THEN 1 ELSE 0 END) AS RebookedPatients
    FROM PatientDiagnosis pd
    JOIN PatientAppointmentCounts pac
        ON pd.PatientID = pac.PatientID
    GROUP BY
        pd.Diagnosis
),

DiagnosisCancellationStats AS (
    SELECT
        pd.Diagnosis,
        COUNT(a.AppointmentID) AS TotalAppointments,
        SUM(CASE WHEN a.Status = 'Cancelled' THEN 1 ELSE 0 END) AS CancelledAppointments
    FROM PatientDiagnosis pd
    JOIN Appointment a
        ON pd.PatientID = a.PatientID
    GROUP BY
        pd.Diagnosis
)

SELECT
    drs.Diagnosis,
    drs.TotalPatients,
    drs.RebookedPatients,
    CAST(
        drs.RebookedPatients * 100.0 / NULLIF(drs.TotalPatients, 0)
        AS DECIMAL(5,2)
    ) AS ReappointmentRate,

    dcs.TotalAppointments,
    dcs.CancelledAppointments,
    CAST(
        dcs.CancelledAppointments * 100.0 / NULLIF(dcs.TotalAppointments, 0)
        AS DECIMAL(5,2)
    ) AS CancellationRate
FROM DiagnosisReappointmentStats drs
JOIN DiagnosisCancellationStats dcs
    ON drs.Diagnosis = dcs.Diagnosis
ORDER BY
    ReappointmentRate DESC,
    CancellationRate DESC,
    drs.TotalPatients DESC,
    drs.Diagnosis;