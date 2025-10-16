/* ==========================================================
   📍 SECTION 1: CREATE TABLES
   ----------------------------------------------------------
   Define structure for Transcripts and Student_Groups tables
   ========================================================== */
CREATE TABLE IF NOT EXISTS public.transcripts (
    studentid INT,
    term VARCHAR(20),
    coursename VARCHAR(100),
    courseid VARCHAR(10),
    coursecreditsearned DECIMAL(4,2)
);

CREATE TABLE IF NOT EXISTS public.student_groups (
    studentid INT,
    term VARCHAR(20),
    groupcode VARCHAR(10)
);

/* ==========================================================
   📍 SECTION 2: INSERT SAMPLE DATA
   ----------------------------------------------------------
   Add test data for demonstration and validation
   ========================================================== */
INSERT INTO public.transcripts (studentid, term, coursename, courseid, coursecreditsearned)
VALUES
(1, 'Fall 2024', 'Math 101', 'MTH101', 4),
(1, 'Fall 2024', 'English 101', 'ENG101', 4),
(1, 'Fall 2024', 'History 101', 'HIS101', 4),
(1, 'Winter 2025', 'Biology 101', 'BIO101', 3),
(1, 'Winter 2025', 'Chemistry 101', 'CHE101', 3),
(1, 'Spring 2025', 'Physics 101', 'PHY101', 3),
(1, 'Spring 2025', 'Philosophy 101', 'PHI101', 3),

(2, 'Fall 2024', 'Math 101', 'MTH101', 6),
(2, 'Winter 2025', 'English 101', 'ENG101', 6),
(2, 'Spring 2025', 'Science 101', 'SCI101', 6);

INSERT INTO public.student_groups (studentid, term, groupcode)
VALUES
(1, 'Spring 2025', 'SING'),
(2, 'Spring 2025', 'PART');

/* ==========================================================
   📍 SECTION 3: VERIFY TABLE CREATION
   ----------------------------------------------------------
   (Optional) Check if tables were created successfully
   ========================================================== */
-- \d public.transcripts;
-- \d public.student_groups;

/* ==========================================================
   📍 SECTION 4: ANALYTICAL QUERY
   ----------------------------------------------------------
   Compute total credits, determine completion status,
   and attach the student’s most current family status
   ========================================================== */
WITH term_credits AS (
    SELECT
        t.studentid,
        t.term,
        SUM(t.coursecreditsearned) AS total_credits
    FROM public.transcripts t
    WHERE t.term IN ('Fall 2024', 'Winter 2025', 'Spring 2025')
    GROUP BY t.studentid, t.term
),

credit_summary AS (
    SELECT
        studentid,
        MAX(CASE WHEN term = 'Fall 2024' AND total_credits >= 12 THEN 1 ELSE 0 END) AS fall_completed,
        MAX(CASE WHEN term = 'Winter 2025' AND total_credits >= 12 THEN 1 ELSE 0 END) AS winter_completed,
        MAX(CASE WHEN term = 'Spring 2025' AND total_credits >= 12 THEN 1 ELSE 0 END) AS spring_completed
    FROM term_credits
    GROUP BY studentid
),

current_status AS (
    SELECT
        sg.studentid,
        sg.groupcode AS familystatus
    FROM public.student_groups sg
    WHERE sg.term = 'Spring 2025'
)

SELECT
    cs.studentid,
    cur.familystatus,
    CASE
        WHEN cs.fall_completed = 1
         AND cs.winter_completed = 1
         AND cs.spring_completed = 1
        THEN 'Completed'
        ELSE 'Not Completed'
    END AS completionstatus
FROM credit_summary cs
LEFT JOIN current_status cur
    ON cs.studentid = cur.studentid;

/* ==========================================================
   📍 SECTION 5: EXPECTED OUTPUT
   ----------------------------------------------------------
   | studentid | familystatus | completionstatus |
   |------------|--------------|------------------|
   | 1          | SING         | Not Completed    |
   | 2          | PART         | Completed        |
   ========================================================== */
