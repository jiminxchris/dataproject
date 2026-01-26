

-- 스키마 생성
CREATE SCHEMA IF NOT EXISTS feedback_system;

-- 확장 프로그램 설치
CREATE EXTENSION IF NOT EXISTS azure_ai;
CREATE EXTENSION IF NOT EXISTS vector;
CREATE EXTENSION IF NOT EXISTS pg_trgm;  -- 유사 문자열 검색을 위한 확장

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
    embedding VECTOR(1536),  -- OpenAI의 text-embedding-ada-002 모델을 위한 벡터 크기
    feedback_data JSONB,  -- 추가 메타데이터 저장
    image_url TEXT,  -- 이미지 기반 피드백 URL (있는 경우)
    image_analysis JSONB  -- 이미지 분석 결과
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

-- 인사이트 테이블 (AI 분석 결과)
CREATE TABLE feedback_system.insights (
    insight_id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    source_query TEXT,  -- 이 인사이트를 생성하는 데 사용된 쿼리
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    insight_data JSONB,  -- 추가 분석 데이터
    time_period TSRANGE  -- 이 인사이트가 적용되는 시간 범위
);

-- 인덱스 생성
CREATE INDEX idx_feedbacks_embedding ON feedback_system.feedbacks USING ivfflat (embedding vector_cosine_ops);
CREATE INDEX idx_feedbacks_content ON feedback_system.feedbacks USING gin (to_tsvector('english', content));
CREATE INDEX idx_feedbacks_created_at ON feedback_system.feedbacks (created_at);
CREATE INDEX idx_feedbacks_sentiment ON feedback_system.feedbacks (sentiment_score);












