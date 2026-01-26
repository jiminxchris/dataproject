-- 의미론적 피드백 검색 함수
CREATE OR REPLACE FUNCTION feedback_system.search_feedback_semantic(
    search_query TEXT,
    limit_results INT DEFAULT 10,
    min_sentiment REAL DEFAULT -1.0,
    max_sentiment REAL DEFAULT 1.0,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT '-infinity',
    end_date TIMESTAMP WITH TIME ZONE DEFAULT 'infinity',
    tag_filter TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS TABLE (
    feedback_id INT,
    content TEXT,
    sentiment_score REAL,
    created_at TIMESTAMP WITH TIME ZONE,
    customer_name TEXT,
    source_name TEXT,
    semantic_similarity REAL
) LANGUAGE plpgsql AS $$
DECLARE
    query_embedding VECTOR(768);
    query_tokens TSVECTOR;
BEGIN
    -- Python 함수를 호출하여 검색 쿼리의 임베딩 생성
    -- 실제로는 Python 함수 호출을 위한 PL/Python 설정이 필요
    -- 여기서는 PostgreSQL의 내장 PL/Python 지원 대신 미리 계산된 임베딩 사용을 가정
    
    -- 방법 1: Python 함수를 호출하여 임베딩 구하기 (PL/Python 필요)
    -- EXECUTE format('SELECT %s.create_embedding(%L)', 'python', search_query) INTO query_embedding;
    
    -- 방법 2: 미리 계산된 임베딩 사용하기 (예시)
    WITH embedded_query AS (
        SELECT * FROM feedback_system.feedbacks 
        ORDER BY content <-> search_query 
        LIMIT 1
    )
    SELECT embedding INTO query_embedding FROM embedded_query;
    
    -- 검색 쿼리에 대한 토큰 생성 (전체 텍스트 검색용)
    query_tokens := to_tsvector('korean', search_query);
    
    RETURN QUERY
    WITH combined_search AS (
        SELECT 
            f.feedback_id,
            f.content,
            f.sentiment_score,
            f.created_at,
            c.name as customer_name,
            s.source_name,
            -- 벡터 유사성 점수
            (f.embedding <=> query_embedding) as vector_similarity,
            -- 텍스트 매칭 점수 (ts_rank)
            ts_rank(f.content_vector, plainto_tsquery('korean', search_query)) as text_match_score
        FROM feedback_system.feedbacks f
        JOIN feedback_system.customers c ON f.customer_id = c.customer_id
        JOIN feedback_system.feedback_sources s ON f.source_id = s.source_id
        WHERE 
            f.sentiment_score BETWEEN min_sentiment AND max_sentiment
            AND f.created_at BETWEEN start_date AND end_date
            AND (
                array_length(tag_filter, 1) IS NULL 
                OR EXISTS (
                    SELECT 1 
                    FROM feedback_system.feedback_tags ft
                    JOIN feedback_system.tags t ON ft.tag_id = t.tag_id
                    WHERE ft.feedback_id = f.feedback_id
                    AND t.tag_name = ANY(tag_filter)
                )
            )
    )
    SELECT 
        feedback_id,
        content,
        sentiment_score,
        created_at,
        customer_name,
        source_name,
        -- 벡터 유사성과 텍스트 매칭 점수를 조합
        -- 낮은 벡터 거리가 더 좋으므로 역수로 변환 후 가중치 부여
        (0.7 * (1.0 / (vector_similarity + 0.0001)) + 0.3 * text_match_score) as semantic_similarity
    FROM combined_search
    ORDER BY semantic_similarity DESC
    LIMIT limit_results;
END; $$;


-- 인사이트 생성 함수 (오픈소스 도구를 사용한 접근)
CREATE OR REPLACE FUNCTION feedback_system.generate_tag_insights(
    tag_name TEXT,
    days_back INT DEFAULT 30
)
RETURNS TABLE (
    insight_text TEXT,
    sentiment_avg REAL,
    feedback_count INT,
    relevant_feedback_ids INT[]
)
LANGUAGE plpgsql AS $$
DECLARE
    tag_id INT;
    relevant_feedbacks INT[];
    avg_sentiment REAL;
    total_count INT;
    insight TEXT;
    feedback_sample TEXT;
BEGIN
    -- 태그 ID 가져오기
    SELECT t.tag_id INTO tag_id
    FROM feedback_system.tags t
    WHERE t.tag_name = tag_name;
    
    IF tag_id IS NULL THEN
        RETURN QUERY SELECT 
            'Tag not found'::TEXT,
            0::REAL,
            0::INT,
            ARRAY[]::INT[];
        RETURN;
    END IF;
    
    -- 관련 피드백 조회
    SELECT 
        array_agg(f.feedback_id),
        AVG(f.sentiment_score),
        COUNT(f.feedback_id)
    INTO
        relevant_feedbacks,
        avg_sentiment,
        total_count
    FROM feedback_system.feedbacks f
    JOIN feedback_system.feedback_tags ft ON f.feedback_id = ft.feedback_id
    WHERE 
        ft.tag_id = tag_id
        AND f.created_at >= (CURRENT_DATE - (days_back || ' days')::INTERVAL);
    
-- 의미론적 피드백 검색 함수
CREATE OR REPLACE FUNCTION feedback_system.search_feedback_semantic(
    search_query TEXT,
    limit_results INT DEFAULT 10,
    min_sentiment REAL DEFAULT -1.0,
    max_sentiment REAL DEFAULT 1.0,
    start_date TIMESTAMP WITH TIME ZONE DEFAULT '-infinity',
    end_date TIMESTAMP WITH TIME ZONE DEFAULT 'infinity',
    tag_filter TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS TABLE (
    feedback_id INT,
    content TEXT,
    sentiment_score REAL,
    created_at TIMESTAMP WITH TIME ZONE,
    customer_name TEXT,
    source_name TEXT,
    semantic_similarity REAL
) LANGUAGE plpgsql AS $$
DECLARE
    query_embedding VECTOR(768);
    query_tokens TSVECTOR;
BEGIN
    -- Python 함수를 호출하여 검색 쿼리의 임베딩 생성
    -- 실제로는 Python 함수 호출을 위한 PL/Python 설정이 필요
    -- 여기서는 PostgreSQL의 내장 PL/Python 지원 대신 미리 계산된 임베딩 사용을 가정
    
    -- 방법 1: Python 함수를 호출하여 임베딩 구하기 (PL/Python 필요)
    -- EXECUTE format('SELECT %s.create_embedding(%L)', 'python', search_query) INTO query_embedding;
    
    -- 방법 2: 미리 계산된 임베딩 사용하기 (예시)
    WITH embedded_query AS (
        SELECT * FROM feedback_system.feedbacks 
        ORDER BY content <-> search_query 
        LIMIT 1
    )
    SELECT embedding INTO query_embedding FROM embedded_query;
    
    -- 검색 쿼리에 대한 토큰 생성 (전체 텍스트 검색용)
    query_tokens := to_tsvector('korean', search_query);
    
    RETURN QUERY
    WITH combined_search AS (
        SELECT 
            f.feedback_id,
            f.content,
            f.sentiment_score,
            f.created_at,
            c.name as customer_name,
            s.source_name,
            -- 벡터 유사성 점수
            (f.embedding <=> query_embedding) as vector_similarity,
            -- 텍스트 매칭 점수 (ts_rank)
            ts_rank(f.content_vector, plainto_tsquery('korean', search_query)) as text_match_score
        FROM feedback_system.feedbacks f
        JOIN feedback_system.customers c ON f.customer_id = c.customer_id
        JOIN feedback_system.feedback_sources s ON f.source_id = s.source_id
        WHERE 
            f.sentiment_score BETWEEN min_sentiment AND max_sentiment
            AND f.created_at BETWEEN start_date AND end_date
            AND (
                array_length(tag_filter, 1) IS NULL 
                OR EXISTS (
                    SELECT 1 
                    FROM feedback_system.feedback_tags ft
                    JOIN feedback_system.tags t ON ft.tag_id = t.tag_id
                    WHERE ft.feedback_id = f.feedback_id
                    AND t.tag_name = ANY(tag_filter)
                )
            )
    )
    SELECT 
        feedback_id,
        content,
        sentiment_score,
        created_at,
        customer_name,
        source_name,
        -- 벡터 유사성과 텍스트 매칭 점수를 조합
        -- 낮은 벡터 거리가 더 좋으므로 역수로 변환 후 가중치 부여
        (0.7 * (1.0 / (vector_similarity + 0.0001)) + 0.3 * text_match_score) as semantic_similarity
    FROM combined_search
    ORDER BY semantic_similarity DESC
    LIMIT limit_results;
END; $$;


-- 인사이트 생성 함수 (오픈소스 도구를 사용한 접근)
CREATE OR REPLACE FUNCTION feedback_system.generate_tag_insights(
    tag_name TEXT,
    days_back INT DEFAULT 30
)
RETURNS TABLE (
    insight_text TEXT,
    sentiment_avg REAL,
    feedback_count INT,
    relevant_feedback_ids INT[]
)
LANGUAGE plpgsql AS $$
DECLARE
    tag_id INT;
    relevant_feedbacks INT[];
    avg_sentiment REAL;
    total_count INT;
    insight TEXT;
    feedback_sample TEXT;
BEGIN
    -- 태그 ID 가져오기
    SELECT t.tag_id INTO tag_id
    FROM feedback_system.tags t
    WHERE t.tag_name = tag_name;
    
    IF tag_id IS NULL THEN
        RETURN QUERY SELECT 
            'Tag not found'::TEXT,
            0::REAL,
            0::INT,
            ARRAY[]::INT[];
        RETURN;
    END IF;
    
    -- 관련 피드백 조회
    SELECT 
        array_agg(f.feedback_id),
        AVG(f.sentiment_score),
        COUNT(f.feedback_id)
    INTO
        relevant_feedbacks,
        avg_sentiment,
        total_count
    FROM feedback_system.feedbacks f
    JOIN feedback_system.feedback_tags ft ON f.feedback_id = ft.feedback_id
    WHERE 
        ft.tag_id = tag_id
        AND f.created_at >= (CURRENT_DATE - (days_back || ' days')::INTERVAL);    
    