-- ==============================================================================
-- FLANKI SUPABASE SEED DATA
-- Description: Sample catalog data for testing and development
-- Created At: 2026-09-16
-- ==============================================================================

-- Sample Published Exam Paper for Catalog Testing
INSERT INTO public.exam_papers (
    id, title, description, category, level, duration_minutes, total_questions, sections_json, is_published
) VALUES (
    'exam_ielts_academic_01',
    'IELTS Academic Practice Test 1 (Mock)',
    'Comprehensive IELTS Academic test covering Reading and Listening with authentic audio tracks.',
    'IELTS',
    'B2-C1',
    60,
    40,
    '[
        {"id": "sec_1", "title": "Listening Section 1: Hotel Booking Inquiry", "questions_count": 10},
        {"id": "sec_2", "title": "Listening Section 2: Campus Tour Guide", "questions_count": 10},
        {"id": "sec_3", "title": "Reading Passage 1: The Evolution of Language", "questions_count": 10},
        {"id": "sec_4", "title": "Reading Passage 2: Microplastics in Ocean Ecosystems", "questions_count": 10}
    ]'::JSONB,
    TRUE
),
(
    'exam_toeic_reading_01',
    'TOEIC Reading 100 Questions Benchmark',
    'Full 75-minute Reading test including Incomplete Sentences, Text Completion, and Reading Comprehension.',
    'TOEIC',
    'B2',
    75,
    100,
    '[
        {"id": "sec_part5", "title": "Part 5: Incomplete Sentences", "questions_count": 30},
        {"id": "sec_part6", "title": "Part 6: Text Completion", "questions_count": 16},
        {"id": "sec_part7", "title": "Part 7: Reading Comprehension", "questions_count": 54}
    ]'::JSONB,
    TRUE
)
ON CONFLICT (id) DO NOTHING;
