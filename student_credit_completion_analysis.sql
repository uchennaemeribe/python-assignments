WITH term_credits AS (
    SELECT
        t.StudentID,
        t.Term,
        SUM(t.CourseCreditsEarned) AS total_credits
    FROM Transcripts t
    WHERE t.Term IN ('Fall 2024', 'Winter 2025', 'Spring 2025')
    GROUP BY t.StudentID, t.Term
),

credit_summary AS (
    SELECT
        StudentID,
        SUM(CASE WHEN Term = 'Fall 2024' AND total_credits >= 12 THEN 1 ELSE 0 END) AS fall_completed,
        SUM(CASE WHEN Term = 'Winter 2025' AND total_credits >= 12 THEN 1 ELSE 0 END) AS winter_completed,
        SUM(CASE WHEN Term = 'Spring 2025' AND total_credits >= 12 THEN 1 ELSE 0 END) AS spring_completed
    FROM term_credits
    GROUP BY StudentID
),

current_status AS (
    SELECT
        sg.StudentID,
        sg.GroupCode AS FamilyStatus
    FROM Student_Groups sg
    WHERE sg.Term = 'Spring 2025'   -- most current term
)

SELECT
    cs.StudentID,
    cur.FamilyStatus,
    CASE
        WHEN cs.fall_completed = 1
         AND cs.winter_completed = 1
         AND cs.spring_completed = 1
        THEN 'Completed'
        ELSE 'Not Completed'
    END AS CompletionStatus
FROM credit_summary cs
LEFT JOIN current_status cur
    ON cs.StudentID = cur.StudentID;
