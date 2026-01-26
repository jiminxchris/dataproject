

-- 스키마 생성
CREATE SCHEMA IF NOT EXISTS feedback_system;

-- 확장 프로그램 설치
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE EXTENSION IF NOT EXISTS fuzzystrmatch;

-- 고객 테이블
CREATE TABLE feedback_system.customers (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    company TEXT,
    industry TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 피드백 소스 테이블
CREATE TABLE feedback_system.feedback_sources (
    source_id SERIAL PRIMARY KEY,
    source_name TEXT NOT NULL,
    source_type TEXT NOT NULL, -- 'email', 'social_media', 'support_ticket', 'review' 등
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 피드백 테이블
CREATE TABLE feedback_system.feedbacks (
    feedback_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES feedback_system.customers(customer_id),
    source_id INTEGER REFERENCES feedback_system.feedback_sources(source_id),
    content TEXT NOT NULL,
    original_language TEXT,
    translated_content TEXT,
    sentiment_score REAL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    embedding VECTOR(768),  -- BERT 또는 다른 변환기 모델의 임베딩 크기에 맞춤
    content_vector TSVECTOR, -- PostgreSQL 전체 텍스트 검색용
    feedback_data JSONB,  -- 추가 메타데이터 저장
    image_path TEXT,  -- 이미지 기반 피드백 로컬 경로 (있는 경우)
    image_tags JSONB  -- 이미지 태그 (커스텀 처리된)
);

-- 피드백 태그 테이블
CREATE TABLE feedback_system.tags (
    tag_id SERIAL PRIMARY KEY,
    tag_name TEXT NOT NULL UNIQUE,
    tag_category TEXT,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 피드백-태그 연결 테이블
CREATE TABLE feedback_system.feedback_tags (
    feedback_id INTEGER REFERENCES feedback_system.feedbacks(feedback_id),
    tag_id INTEGER REFERENCES feedback_system.tags(tag_id),
    confidence_score REAL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    PRIMARY KEY (feedback_id, tag_id)
);

-- 인사이트 테이블
CREATE TABLE feedback_system.insights (
    insight_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    source_query TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    insight_data JSONB,
    time_period TSRANGE
);

-- 트리거 함수: 피드백 내용이 업데이트될 때 tsvector 업데이트
CREATE OR REPLACE FUNCTION feedback_system.update_content_vector()
RETURNS TRIGGER AS $$
BEGIN
    NEW.content_vector = to_tsvector('korean', COALESCE(NEW.translated_content, NEW.content));
    RETURN NEW;
END;

$$ LANGUAGE plpgsql;

CREATE TRIGGER update_feedbacks_content_vector
BEFORE INSERT OR UPDATE OF content, translated_content
ON feedback_system.feedbacks
FOR EACH ROW EXECUTE FUNCTION feedback_system.update_content_vector();

-- 인덱스 생성
CREATE INDEX idx_feedbacks_embedding ON feedback_system.feedbacks USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_feedbacks_content_vector ON feedback_system.feedbacks USING gin (content_vector);
CREATE INDEX idx_feedbacks_created_at ON feedback_system.feedbacks (created_at);
CREATE INDEX idx_feedbacks_sentiment ON feedback_system.feedbacks (sentiment_score);



