-- Database initialization script for Copilot Metrics Dashboard
-- This script sets up the basic database structure and initial configuration

-- Create database extensions if needed
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pg_stat_statements";

-- Create schemas
CREATE SCHEMA IF NOT EXISTS copilot_metrics;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Set default schema
SET search_path TO copilot_metrics, public;

-- Create tables for metrics storage
CREATE TABLE IF NOT EXISTS organizations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    github_id BIGINT UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    login VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS repositories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    github_id BIGINT UNIQUE NOT NULL,
    organization_id UUID REFERENCES organizations(id),
    name VARCHAR(255) NOT NULL,
    full_name VARCHAR(512) NOT NULL,
    private BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    github_id BIGINT UNIQUE NOT NULL,
    login VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    email VARCHAR(255),
    organization_id UUID REFERENCES organizations(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS copilot_usage (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id),
    repository_id UUID REFERENCES repositories(id),
    date DATE NOT NULL,
    suggestions_count INTEGER DEFAULT 0,
    acceptances_count INTEGER DEFAULT 0,
    lines_suggested INTEGER DEFAULT 0,
    lines_accepted INTEGER DEFAULT 0,
    active_users INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS team_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_name VARCHAR(255) NOT NULL,
    organization_id UUID REFERENCES organizations(id),
    date DATE NOT NULL,
    total_suggestions INTEGER DEFAULT 0,
    total_acceptances INTEGER DEFAULT 0,
    acceptance_rate DECIMAL(5,2) DEFAULT 0,
    active_users INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_copilot_usage_user_date ON copilot_usage(user_id, date);
CREATE INDEX IF NOT EXISTS idx_copilot_usage_repo_date ON copilot_usage(repository_id, date);
CREATE INDEX IF NOT EXISTS idx_copilot_usage_date ON copilot_usage(date);
CREATE INDEX IF NOT EXISTS idx_team_metrics_org_date ON team_metrics(organization_id, date);
CREATE INDEX IF NOT EXISTS idx_repositories_org ON repositories(organization_id);
CREATE INDEX IF NOT EXISTS idx_users_org ON users(organization_id);

-- Create views for analytics
CREATE OR REPLACE VIEW analytics.daily_summary AS
SELECT 
    date,
    COUNT(DISTINCT user_id) as active_users,
    SUM(suggestions_count) as total_suggestions,
    SUM(acceptances_count) as total_acceptances,
    CASE 
        WHEN SUM(suggestions_count) > 0 
        THEN ROUND((SUM(acceptances_count)::DECIMAL / SUM(suggestions_count)) * 100, 2)
        ELSE 0 
    END as acceptance_rate
FROM copilot_usage 
GROUP BY date
ORDER BY date DESC;

CREATE OR REPLACE VIEW analytics.user_summary AS
SELECT 
    u.login,
    u.name,
    COUNT(DISTINCT cu.date) as active_days,
    SUM(cu.suggestions_count) as total_suggestions,
    SUM(cu.acceptances_count) as total_acceptances,
    CASE 
        WHEN SUM(cu.suggestions_count) > 0 
        THEN ROUND((SUM(cu.acceptances_count)::DECIMAL / SUM(cu.suggestions_count)) * 100, 2)
        ELSE 0 
    END as acceptance_rate
FROM users u
LEFT JOIN copilot_usage cu ON u.id = cu.user_id
GROUP BY u.id, u.login, u.name
ORDER BY total_suggestions DESC;

CREATE OR REPLACE VIEW analytics.repository_summary AS
SELECT 
    r.full_name,
    COUNT(DISTINCT cu.user_id) as unique_users,
    COUNT(DISTINCT cu.date) as active_days,
    SUM(cu.suggestions_count) as total_suggestions,
    SUM(cu.acceptances_count) as total_acceptances,
    CASE 
        WHEN SUM(cu.suggestions_count) > 0 
        THEN ROUND((SUM(cu.acceptances_count)::DECIMAL / SUM(cu.suggestions_count)) * 100, 2)
        ELSE 0 
    END as acceptance_rate
FROM repositories r
LEFT JOIN copilot_usage cu ON r.id = cu.repository_id
GROUP BY r.id, r.full_name
ORDER BY total_suggestions DESC;

-- Create functions for data cleanup
CREATE OR REPLACE FUNCTION cleanup_old_data(retention_days INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    DELETE FROM copilot_usage 
    WHERE date < (CURRENT_DATE - INTERVAL '1 day' * retention_days);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    
    DELETE FROM team_metrics 
    WHERE date < (CURRENT_DATE - INTERVAL '1 day' * retention_days);
    
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for updating timestamps
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply update triggers
CREATE TRIGGER organizations_updated_at
    BEFORE UPDATE ON organizations
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER repositories_updated_at
    BEFORE UPDATE ON repositories
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at();

-- Grant permissions
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA copilot_metrics TO postgres;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA copilot_metrics TO postgres;
GRANT ALL PRIVILEGES ON ALL FUNCTIONS IN SCHEMA copilot_metrics TO postgres;
GRANT USAGE ON SCHEMA analytics TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA analytics TO postgres;

-- Insert initial configuration if needed
INSERT INTO organizations (github_id, name, login) 
VALUES (0, 'Default Organization', 'default')
ON CONFLICT (github_id) DO NOTHING;

-- Create indexes for JSON fields if using JSONB columns
-- This is useful for storing additional metadata
CREATE INDEX IF NOT EXISTS idx_copilot_usage_metadata ON copilot_usage USING GIN ((metadata)) 
WHERE metadata IS NOT NULL;

-- Final message
DO $$
BEGIN
    RAISE NOTICE 'Database initialization completed successfully';
    RAISE NOTICE 'Schemas created: copilot_metrics, analytics';
    RAISE NOTICE 'Tables created: organizations, repositories, users, copilot_usage, team_metrics';
    RAISE NOTICE 'Views created: daily_summary, user_summary, repository_summary';
    RAISE NOTICE 'Functions created: cleanup_old_data, update_updated_at';
END
$$;
