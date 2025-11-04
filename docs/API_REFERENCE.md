# API Reference for Katya AI REChain Mesh

This comprehensive API reference provides detailed documentation for all endpoints, data models, authentication methods, and integration patterns for the Katya AI REChain Mesh platform.

## Table of Contents

- [Overview](#overview)
- [Authentication](#authentication)
- [Rate Limiting](#rate-limiting)
- [Error Handling](#error-handling)
- [Core API Endpoints](#core-api-endpoints)
- [Platform Management](#platform-management)
- [Repository Management](#repository-management)
- [User Management](#user-management)
- [AI/ML Endpoints](#aiml-endpoints)
- [Webhooks](#webhooks)
- [Data Models](#data-models)
- [SDKs and Libraries](#sdks-and-libraries)

## Overview

The Katya AI REChain Mesh API provides RESTful endpoints for managing repository synchronization across multiple Git platforms, AI-powered operations, and system administration.

### Base URL
```
https://api.katya-ai-rechain-mesh.com/v1
```

### API Versions
- **v1** (Current): Stable production API
- **v2** (Beta): Next-generation API with enhanced features

### Content Types
- **Request**: `application/json`
- **Response**: `application/json`
- **File Uploads**: `multipart/form-data`

### HTTP Status Codes
- **200 OK**: Success
- **201 Created**: Resource created
- **204 No Content**: Success with no response body
- **400 Bad Request**: Invalid request
- **401 Unauthorized**: Authentication required
- **403 Forbidden**: Insufficient permissions
- **404 Not Found**: Resource not found
- **409 Conflict**: Resource conflict
- **422 Unprocessable Entity**: Validation error
- **429 Too Many Requests**: Rate limit exceeded
- **500 Internal Server Error**: Server error
- **503 Service Unavailable**: Service temporarily unavailable

## Authentication

### API Key Authentication

```bash
# Include API key in header
curl -H "Authorization: Bearer YOUR_API_KEY" \
     https://api.katya-ai-rechain-mesh.com/v1/repositories
```

### OAuth 2.0 Authentication

#### Authorization Code Flow

```bash
# 1. Redirect user to authorization URL
GET https://api.katya-ai-rechain-mesh.com/oauth/authorize?response_type=code&client_id=YOUR_CLIENT_ID&redirect_uri=YOUR_REDIRECT_URI&scope=read+write

# 2. Exchange code for access token
POST https://api.katya-ai-rechain-mesh.com/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=authorization_code&code=AUTH_CODE&redirect_uri=YOUR_REDIRECT_URI&client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET
```

#### Client Credentials Flow

```bash
# For server-to-server authentication
POST https://api.katya-ai-rechain-mesh.com/oauth/token
Content-Type: application/x-www-form-urlencoded

grant_type=client_credentials&client_id=YOUR_CLIENT_ID&client_secret=YOUR_CLIENT_SECRET&scope=admin
```

### JWT Token Authentication

```bash
# Include JWT token in Authorization header
curl -H "Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..." \
     https://api.katya-ai-rechain-mesh.com/v1/user/profile
```

### Session Authentication

```bash
# Use session cookie for web applications
curl -b "session_id=abc123" \
     https://api.katya-ai-rechain-mesh.com/v1/dashboard
```

## Rate Limiting

### Rate Limit Headers

```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1640995200
X-RateLimit-Retry-After: 60
```

### Rate Limits by Endpoint Category

| Category | Limit | Window |
|----------|-------|--------|
| **Read Operations** | 1000 req/min | 1 minute |
| **Write Operations** | 100 req/min | 1 minute |
| **AI Inference** | 50 req/min | 1 minute |
| **File Uploads** | 10 req/min | 1 minute |
| **Administrative** | 50 req/min | 1 minute |

### Rate Limit Exceeded Response

```json
{
  "error": "rate_limit_exceeded",
  "message": "API rate limit exceeded",
  "retry_after": 60,
  "limit": 1000,
  "remaining": 0,
  "reset_time": "2024-01-01T12:00:00Z"
}
```

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "field": "email",
      "reason": "invalid_format"
    },
    "request_id": "req_1234567890",
    "timestamp": "2024-01-01T12:00:00Z"
  }
}
```

### Common Error Codes

| Error Code | HTTP Status | Description |
|------------|-------------|-------------|
| `VALIDATION_ERROR` | 400 | Request validation failed |
| `AUTHENTICATION_ERROR` | 401 | Invalid or missing credentials |
| `AUTHORIZATION_ERROR` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `CONFLICT` | 409 | Resource conflict |
| `RATE_LIMIT_EXCEEDED` | 429 | Rate limit exceeded |
| `INTERNAL_ERROR` | 500 | Internal server error |
| `SERVICE_UNAVAILABLE` | 503 | Service temporarily unavailable |

## Core API Endpoints

### Health Check

#### GET /health

Check API service health and status.

**Response (200 OK):**
```json
{
  "status": "healthy",
  "version": "1.2.3",
  "timestamp": "2024-01-01T12:00:00Z",
  "services": {
    "database": "healthy",
    "redis": "healthy",
    "rabbitmq": "healthy",
    "ai_engine": "healthy"
  }
}
```

### System Information

#### GET /info

Get system information and capabilities.

**Response (200 OK):**
```json
{
  "name": "Katya AI REChain Mesh",
  "version": "1.2.3",
  "build": "abc123def",
  "environment": "production",
  "features": [
    "multi_platform_sync",
    "ai_powered_insights",
    "real_time_monitoring",
    "webhook_support"
  ],
  "supported_platforms": [
    "github",
    "gitlab",
    "bitbucket",
    "gitea"
  ]
}
```

## Platform Management

### List Platforms

#### GET /platforms

Get list of configured Git platforms.

**Query Parameters:**
- `active` (boolean): Filter by active status
- `limit` (integer): Maximum number of results (default: 50)
- `offset` (integer): Pagination offset (default: 0)

**Response (200 OK):**
```json
{
  "platforms": [
    {
      "id": "github",
      "name": "GitHub",
      "api_url": "https://api.github.com",
      "auth_type": "token",
      "rate_limit": 5000,
      "is_active": true,
      "last_sync": "2024-01-01T12:00:00Z",
      "repositories_count": 1250
    }
  ],
  "total": 4,
  "limit": 50,
  "offset": 0
}
```

### Get Platform

#### GET /platforms/{platform_id}

Get detailed information about a specific platform.

**Path Parameters:**
- `platform_id` (string): Platform identifier

**Response (200 OK):**
```json
{
  "id": "github",
  "name": "GitHub",
  "api_url": "https://api.github.com",
  "auth_type": "token",
  "rate_limit": 5000,
  "is_active": true,
  "config": {
    "webhooks_enabled": true,
    "sync_interval": 300,
    "max_concurrent_syncs": 10
  },
  "credentials": {
    "configured": true,
    "last_validated": "2024-01-01T12:00:00Z"
  },
  "statistics": {
    "total_repositories": 1250,
    "active_repositories": 1200,
    "last_sync": "2024-01-01T12:00:00Z",
    "sync_success_rate": 0.98
  }
}
```

### Configure Platform

#### POST /platforms/{platform_id}/configure

Configure authentication and settings for a platform.

**Path Parameters:**
- `platform_id` (string): Platform identifier

**Request Body:**
```json
{
  "auth": {
    "type": "token",
    "token": "ghp_1234567890abcdef"
  },
  "config": {
    "webhooks_enabled": true,
    "sync_interval": 300,
    "max_concurrent_syncs": 10,
    "rate_limit_buffer": 0.8
  }
}
```

**Response (200 OK):**
```json
{
  "message": "Platform configured successfully",
  "platform_id": "github",
  "validated": true,
  "next_sync": "2024-01-01T12:05:00Z"
}
```

### Test Platform Connection

#### POST /platforms/{platform_id}/test

Test platform connectivity and authentication.

**Path Parameters:**
- `platform_id` (string): Platform identifier

**Response (200 OK):**
```json
{
  "connected": true,
  "authenticated": true,
  "rate_limit": {
    "limit": 5000,
    "remaining": 4999,
    "reset": "2024-01-01T13:00:00Z"
  },
  "capabilities": [
    "repositories",
    "webhooks",
    "issues",
    "pull_requests"
  ]
}
```

## Repository Management

### List Repositories

#### GET /repositories

Get list of synchronized repositories.

**Query Parameters:**
- `platform` (string): Filter by platform
- `owner` (string): Filter by repository owner
- `name` (string): Filter by repository name
- `status` (string): Filter by sync status (active, inactive, error)
- `limit` (integer): Maximum number of results (default: 50)
- `offset` (integer): Pagination offset (default: 0)

**Response (200 OK):**
```json
{
  "repositories": [
    {
      "id": "123",
      "platform": "github",
      "owner": "katya-ai",
      "name": "rechain-mesh",
      "description": "Distributed repository synchronization platform",
      "is_private": false,
      "status": "active",
      "last_sync": "2024-01-01T12:00:00Z",
      "sync_status": "success",
      "branches": ["main", "develop"],
      "tags": ["v1.0.0", "v1.1.0", "v1.2.0"],
      "statistics": {
        "commits": 1250,
        "contributors": 25,
        "issues": 45,
        "pull_requests": 89
      }
    }
  ],
  "total": 1250,
  "limit": 50,
  "offset": 0
}
```

### Get Repository

#### GET /repositories/{repository_id}

Get detailed information about a repository.

**Path Parameters:**
- `repository_id` (string): Repository identifier

**Response (200 OK):**
```json
{
  "id": "123",
  "platform": "github",
  "platform_id": "123456789",
  "owner": "katya-ai",
  "name": "rechain-mesh",
  "full_name": "katya-ai/rechain-mesh",
  "description": "Distributed repository synchronization platform",
  "homepage": "https://katya-ai-rechain-mesh.com",
  "language": "Go",
  "is_private": false,
  "is_fork": false,
  "is_archived": false,
  "is_disabled": false,
  "created_at": "2023-01-01T00:00:00Z",
  "updated_at": "2024-01-01T12:00:00Z",
  "pushed_at": "2024-01-01T11:30:00Z",
  "status": "active",
  "config": {
    "sync_enabled": true,
    "sync_interval": 300,
    "webhooks_enabled": true,
    "branches_to_sync": ["main", "develop"],
    "tags_to_sync": ["*"]
  },
  "statistics": {
    "size": 52428800,
    "stars": 1250,
    "forks": 89,
    "watchers": 456,
    "issues": {
      "open": 12,
      "closed": 33
    },
    "pull_requests": {
      "open": 5,
      "closed": 84
    }
  },
  "last_sync": {
    "timestamp": "2024-01-01T12:00:00Z",
    "status": "success",
    "duration": 45,
    "commits_synced": 3,
    "issues_synced": 2
  }
}
```

### Sync Repository

#### POST /repositories/{repository_id}/sync

Trigger manual synchronization for a repository.

**Path Parameters:**
- `repository_id` (string): Repository identifier

**Query Parameters:**
- `type` (string): Sync type (full, incremental, metadata) (default: incremental)
- `force` (boolean): Force sync even if recently synced (default: false)

**Response (202 Accepted):**
```json
{
  "sync_id": "sync_1234567890",
  "repository_id": "123",
  "type": "incremental",
  "status": "queued",
  "queued_at": "2024-01-01T12:00:00Z",
  "estimated_duration": 30
}
```

### Get Sync Status

#### GET /repositories/{repository_id}/sync/{sync_id}

Get status of a synchronization operation.

**Path Parameters:**
- `repository_id` (string): Repository identifier
- `sync_id` (string): Sync operation identifier

**Response (200 OK):**
```json
{
  "sync_id": "sync_1234567890",
  "repository_id": "123",
  "type": "incremental",
  "status": "completed",
  "progress": 100,
  "started_at": "2024-01-01T12:00:00Z",
  "completed_at": "2024-01-01T12:00:45Z",
  "duration": 45,
  "results": {
    "commits_synced": 3,
    "issues_synced": 2,
    "pull_requests_synced": 1,
    "branches_synced": 2,
    "tags_synced": 0
  },
  "errors": []
}
```

### Configure Repository

#### PUT /repositories/{repository_id}/config

Update repository synchronization configuration.

**Path Parameters:**
- `repository_id` (string): Repository identifier

**Request Body:**
```json
{
  "sync_enabled": true,
  "sync_interval": 600,
  "webhooks_enabled": true,
  "branches_to_sync": ["main", "develop", "feature/*"],
  "tags_to_sync": ["v*"],
  "exclude_patterns": [".git/", "node_modules/"],
  "include_metadata": true,
  "include_issues": true,
  "include_pull_requests": true,
  "include_releases": true
}
```

**Response (200 OK):**
```json
{
  "message": "Repository configuration updated",
  "repository_id": "123",
  "next_sync": "2024-01-01T12:10:00Z"
}
```

## User Management

### Get Current User

#### GET /user

Get current authenticated user information.

**Response (200 OK):**
```json
{
  "id": "user_123",
  "username": "johndoe",
  "email": "john.doe@example.com",
  "full_name": "John Doe",
  "avatar_url": "https://avatars.githubusercontent.com/u/12345678?v=4",
  "role": "admin",
  "is_active": true,
  "created_at": "2023-06-01T00:00:00Z",
  "last_login": "2024-01-01T11:00:00Z",
  "preferences": {
    "theme": "dark",
    "notifications": {
      "email": true,
      "webhook": false
    }
  }
}
```

### Update User Profile

#### PUT /user/profile

Update current user profile information.

**Request Body:**
```json
{
  "full_name": "John Doe",
  "email": "john.doe@example.com",
  "avatar_url": "https://avatars.githubusercontent.com/u/12345678?v=4",
  "preferences": {
    "theme": "dark",
    "timezone": "America/New_York",
    "notifications": {
      "email": true,
      "webhook": false,
      "sync_complete": true
    }
  }
}
```

**Response (200 OK):**
```json
{
  "message": "Profile updated successfully",
  "user": {
    "id": "user_123",
    "username": "johndoe",
    "email": "john.doe@example.com",
    "full_name": "John Doe",
    "updated_at": "2024-01-01T12:00:00Z"
  }
}
```

### List User Repositories

#### GET /user/repositories

Get repositories accessible by the current user.

**Query Parameters:**
- `platform` (string): Filter by platform
- `role` (string): Filter by user role (owner, collaborator, viewer)
- `status` (string): Filter by repository status
- `limit` (integer): Maximum number of results (default: 50)
- `offset` (integer): Pagination offset (default: 0)

**Response (200 OK):**
```json
{
  "repositories": [
    {
      "id": "123",
      "platform": "github",
      "owner": "katya-ai",
      "name": "rechain-mesh",
      "role": "admin",
      "permissions": {
        "read": true,
        "write": true,
        "admin": true
      },
      "last_accessed": "2024-01-01T11:30:00Z"
    }
  ],
  "total": 25,
  "limit": 50,
  "offset": 0
}
```

## AI/ML Endpoints

### AI Inference

#### POST /ai/inference

Perform AI inference on repository data.

**Request Body:**
```json
{
  "model": "code-analysis-v1",
  "input": {
    "type": "repository",
    "repository_id": "123",
    "data": {
      "files": ["src/main.go", "src/api.go"],
      "content": "...code content...",
      "context": "analyze code quality and suggest improvements"
    }
  },
  "parameters": {
    "temperature": 0.7,
    "max_tokens": 1000,
    "top_p": 0.9
  }
}
```

**Response (200 OK):**
```json
{
  "inference_id": "inf_1234567890",
  "model": "code-analysis-v1",
  "status": "completed",
  "result": {
    "analysis": {
      "code_quality_score": 8.5,
      "complexity": "medium",
      "maintainability": "high",
      "suggestions": [
        "Consider adding error handling for edge cases",
        "Use more descriptive variable names",
        "Add unit tests for the new function"
      ]
    },
    "confidence": 0.92
  },
  "processing_time": 2.3,
  "tokens_used": 456
}
```

### Get Inference Status

#### GET /ai/inference/{inference_id}

Get status of an AI inference operation.

**Path Parameters:**
- `inference_id` (string): Inference operation identifier

**Response (200 OK):**
```json
{
  "inference_id": "inf_1234567890",
  "status": "completed",
  "progress": 100,
  "started_at": "2024-01-01T12:00:00Z",
  "completed_at": "2024-01-01T12:00:02Z",
  "result": {
    "type": "code_analysis",
    "data": {
      "issues": 3,
      "recommendations": 5,
      "score": 8.7
    }
  },
  "metadata": {
    "model_version": "v1.2.0",
    "processing_time": 2.3,
    "tokens_used": 456
  }
}
```

### List Available Models

#### GET /ai/models

Get list of available AI models.

**Query Parameters:**
- `type` (string): Filter by model type (analysis, generation, classification)
- `capability` (string): Filter by capability
- `limit` (integer): Maximum number of results (default: 50)

**Response (200 OK):**
```json
{
  "models": [
    {
      "id": "code-analysis-v1",
      "name": "Code Analysis Model",
      "type": "analysis",
      "version": "1.2.0",
      "capabilities": [
        "code_quality_analysis",
        "bug_detection",
        "performance_optimization"
      ],
      "input_formats": ["code", "repository"],
      "output_formats": ["json", "markdown"],
      "max_input_size": 1048576,
      "estimated_cost_per_request": 0.02,
      "is_active": true
    }
  ],
  "total": 12
}
```

### Batch Inference

#### POST /ai/batch

Perform batch AI inference operations.

**Request Body:**
```json
{
  "model": "code-analysis-v1",
  "requests": [
    {
      "id": "req_1",
      "input": {
        "type": "file",
        "content": "...code content...",
        "language": "go"
      }
    },
    {
      "id": "req_2",
      "input": {
        "type": "repository_summary",
        "repository_id": "123"
      }
    }
  ],
  "options": {
    "parallel_processing": true,
    "max_concurrent": 5,
    "timeout": 300
  }
}
```

**Response (202 Accepted):**
```json
{
  "batch_id": "batch_1234567890",
  "status": "processing",
  "total_requests": 2,
  "completed": 0,
  "estimated_completion": "2024-01-01T12:05:00Z",
  "results_url": "/ai/batch/batch_1234567890/results"
}
```

## Webhooks

### Register Webhook

#### POST /webhooks

Register a webhook for repository events.

**Request Body:**
```json
{
  "name": "repository-sync-webhook",
  "url": "https://my-app.example.com/webhooks/katya",
  "events": [
    "repository.sync.completed",
    "repository.sync.failed",
    "repository.updated"
  ],
  "secret": "webhook_secret_key",
  "active": true,
  "filters": {
    "platforms": ["github", "gitlab"],
    "repositories": ["katya-ai/*"]
  }
}
```

**Response (201 Created):**
```json
{
  "id": "webhook_123",
  "name": "repository-sync-webhook",
  "url": "https://my-app.example.com/webhooks/katya",
  "events": [
    "repository.sync.completed",
    "repository.sync.failed",
    "repository.updated"
  ],
  "active": true,
  "created_at": "2024-01-01T12:00:00Z",
  "secret_preview": "webhook_sec..."
}
```

### List Webhooks

#### GET /webhooks

Get list of registered webhooks.

**Query Parameters:**
- `active` (boolean): Filter by active status
- `event` (string): Filter by event type
- `limit` (integer): Maximum number of results (default: 50)

**Response (200 OK):**
```json
{
  "webhooks": [
    {
      "id": "webhook_123",
      "name": "repository-sync-webhook",
      "url": "https://my-app.example.com/webhooks/katya",
      "events": [
        "repository.sync.completed",
        "repository.sync.failed"
      ],
      "active": true,
      "created_at": "2024-01-01T12:00:00Z",
      "last_triggered": "2024-01-01T11:30:00Z",
      "success_rate": 0.98
    }
  ],
  "total": 5
}
```

### Webhook Payload Format

```json
{
  "event": "repository.sync.completed",
  "timestamp": "2024-01-01T12:00:00Z",
  "webhook_id": "webhook_123",
  "data": {
    "repository": {
      "id": "123",
      "platform": "github",
      "owner": "katya-ai",
      "name": "rechain-mesh"
    },
    "sync": {
      "id": "sync_1234567890",
      "type": "incremental",
      "status": "success",
      "duration": 45,
      "results": {
        "commits_synced": 3,
        "issues_synced": 2
      }
    }
  },
  "signature": "sha256=abc123def456..."
}
```

### Delete Webhook

#### DELETE /webhooks/{webhook_id}

Delete a webhook registration.

**Path Parameters:**
- `webhook_id` (string): Webhook identifier

**Response (204 No Content):**

## Data Models

### Repository Model

```typescript
interface Repository {
  id: string;
  platform: Platform;
  platform_id: string;
  owner: string;
  name: string;
  full_name: string;
  description?: string;
  homepage?: string;
  language?: string;
  is_private: boolean;
  is_fork: boolean;
  is_archived: boolean;
  is_disabled: boolean;
  created_at: Date;
  updated_at: Date;
  pushed_at: Date;
  size: number;
  stars: number;
  forks: number;
  watchers: number;
  default_branch: string;
  status: RepositoryStatus;
  config: RepositoryConfig;
  statistics: RepositoryStatistics;
  last_sync: SyncInfo;
}

type RepositoryStatus = 'active' | 'inactive' | 'error' | 'syncing';

interface RepositoryConfig {
  sync_enabled: boolean;
  sync_interval: number;
  webhooks_enabled: boolean;
  branches_to_sync: string[];
  tags_to_sync: string[];
  exclude_patterns: string[];
  include_metadata: boolean;
  include_issues: boolean;
  include_pull_requests: boolean;
  include_releases: boolean;
}

interface RepositoryStatistics {
  commits: number;
  contributors: number;
  issues: IssueStats;
  pull_requests: PullRequestStats;
}

interface IssueStats {
  open: number;
  closed: number;
}

interface PullRequestStats {
  open: number;
  closed: number;
  merged: number;
}

interface SyncInfo {
  timestamp: Date;
  status: SyncStatus;
  duration: number;
  commits_synced: number;
  issues_synced: number;
  pull_requests_synced: number;
  branches_synced: number;
  tags_synced: number;
}

type SyncStatus = 'success' | 'failed' | 'partial' | 'running';
```

### User Model

```typescript
interface User {
  id: string;
  username: string;
  email: string;
  full_name?: string;
  avatar_url?: string;
  role: UserRole;
  is_active: boolean;
  is_verified: boolean;
  created_at: Date;
  updated_at: Date;
  last_login?: Date;
  preferences: UserPreferences;
  statistics: UserStatistics;
}

type UserRole = 'admin' | 'manager' | 'user' | 'viewer';

interface UserPreferences {
  theme: 'light' | 'dark' | 'auto';
  timezone: string;
  notifications: NotificationPreferences;
  dashboard: DashboardPreferences;
}

interface NotificationPreferences {
  email: boolean;
  webhook: boolean;
  sync_complete: boolean;
  error_alerts: boolean;
  weekly_digest: boolean;
}

interface DashboardPreferences {
  default_view: string;
  items_per_page: number;
  visible_columns: string[];
}

interface UserStatistics {
  repositories_count: number;
  total_syncs: number;
  successful_syncs: number;
  failed_syncs: number;
  storage_used: number;
}
```

### Platform Model

```typescript
interface Platform {
  id: string;
  name: string;
  display_name: string;
  api_base_url: string;
  auth_type: AuthType;
  rate_limit: number;
  is_active: boolean;
  config: PlatformConfig;
  credentials: PlatformCredentials;
  statistics: PlatformStatistics;
  created_at: Date;
  updated_at: Date;
}

type AuthType = 'token' | 'oauth' | 'basic' | 'none';

interface PlatformConfig {
  webhooks_enabled: boolean;
  sync_interval: number;
  max_concurrent_syncs: number;
  rate_limit_buffer: number;
  timeout: number;
  retry_attempts: number;
  backoff_multiplier: number;
}

interface PlatformCredentials {
  configured: boolean;
  last_validated?: Date;
  expires_at?: Date;
  scopes: string[];
}

interface PlatformStatistics {
  total_repositories: number;
  active_repositories: number;
  total_syncs: number;
  successful_syncs: number;
  failed_syncs: number;
  last_sync?: Date;
  sync_success_rate: number;
  average_sync_duration: number;
}
```

## SDKs and Libraries

### Official SDKs

#### Go SDK

```go
package main

import (
    "context"
    "fmt"
    "log"

    "github.com/katya-ai-rechain-mesh/go-sdk"
)

func main() {
    // Initialize client
    client := katya.NewClient(&katya.Config{
        APIKey: "your_api_key",
        BaseURL: "https://api.katya-ai-rechain-mesh.com/v1",
    })

    // List repositories
    repos, err := client.Repositories.List(context.Background(), &katya.RepositoryListOptions{
        Platform: "github",
        Limit: 50,
    })
    if err != nil {
        log.Fatal(err)
    }

    for _, repo := range repos.Repositories {
        fmt.Printf("Repository: %s/%s\n", repo.Owner, repo.Name)
    }

    // Sync repository
    sync, err := client.Repositories.Sync(context.Background(), "repo_id", &katya.SyncOptions{
        Type: katya.SyncTypeIncremental,
    })
    if err != nil {
        log.Fatal(err)
    }

    fmt.Printf("Sync started: %s\n", sync.SyncID)
}
```

#### Python SDK

```python
from katya_mesh import KatyaClient

# Initialize client
client = KatyaClient(api_key="your_api_key")

# List repositories
repositories = client.repositories.list(platform="github", limit=50)

for repo in repositories['repositories']:
    print(f"Repository: {repo['owner']}/{repo['name']}")

# Sync repository
sync_result = client.repositories.sync("repo_id", sync_type="incremental")
print(f"Sync started: {sync_result['sync_id']}")

# AI inference
inference = client.ai.inference(
    model="code-analysis-v1",
    input={
        "type": "repository",
        "repository_id": "repo_id",
        "context": "analyze code quality"
    }
)
print(f"Inference result: {inference['result']}")
```

#### JavaScript/TypeScript SDK

```typescript
import { KatyaClient } from '@katya-ai-rechain-mesh/sdk';

const client = new KatyaClient({
  apiKey: 'your_api_key',
  baseURL: 'https://api.katya-ai-rechain-mesh.com/v1'
});

// List repositories
const repositories = await client.repositories.list({
  platform: 'github',
  limit: 50
});

repositories.repositories.forEach(repo => {
  console.log(`Repository: ${repo.owner}/${repo.name}`);
});

// Sync repository
const sync = await client.repositories.sync('repo_id', {
  type: 'incremental'
});
console.log(`Sync started: ${sync.sync_id}`);

// AI inference
const inference = await client.ai.inference({
  model: 'code-analysis-v1',
  input: {
    type: 'repository',
    repository_id: 'repo_id',
    context: 'analyze code quality'
  }
});
console.log(`Inference result:`, inference.result);
```

### Community Libraries

- **Ruby**: `katya-mesh-ruby` - Ruby gem for Katya AI REChain Mesh API
- **PHP**: `katya-mesh-php` - PHP SDK for Katya AI REChain Mesh
- **C#**: `KatyaMesh.NET` - .NET library for Katya AI REChain Mesh API
- **Rust**: `katya-mesh-rs` - Rust crate for Katya AI REChain Mesh

### Integration Examples

#### GitHub Actions Integration

```yaml
name: Sync Repository with Katya
on:
  push:
    branches: [ main ]

jobs:
  sync:
    runs-on: ubuntu-latest
    steps:
      - name: Sync with Katya AI REChain Mesh
        uses: katya-ai-rechain-mesh/github-action@v1
        with:
          api-key: ${{ secrets.KATYA_API_KEY }}
          repository-id: ${{ github.repository }}
          sync-type: incremental
```

#### Docker Integration

```dockerfile
FROM katya-ai-rechain-mesh/sync-agent:latest

# Configure platform credentials
ENV GITHUB_TOKEN=${GITHUB_TOKEN}
ENV GITLAB_TOKEN=${GITLAB_TOKEN}

# Configure repositories to sync
ENV SYNC_REPOSITORIES=github.com/katya-ai/rechain-mesh,gitlab.com/katya-ai/mesh-core

# Start sync agent
CMD ["katya-sync-agent", "--config", "/etc/katya/config.yaml"]
```

---

This API reference provides comprehensive documentation for integrating with the Katya AI REChain Mesh platform. For additional support, visit our [developer portal](https://developers.katya-ai-rechain-mesh.com) or join our [community forum](https://community.katya-ai-rechain-mesh.com).
