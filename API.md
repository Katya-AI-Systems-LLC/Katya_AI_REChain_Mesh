# API Documentation

## Overview

Katya AI REChain Mesh provides RESTful APIs for blockchain, gaming, IoT, and social features. All endpoints return JSON responses and use standard HTTP status codes.

## Base URL

```
Production: https://api.katya-ai-rechain-mesh.com
Staging: https://staging-api.katya-ai-rechain-mesh.com
Development: http://localhost:8080
```

## Authentication

Most endpoints require authentication using JWT tokens:

```
Authorization: Bearer <your_jwt_token>
```

## Response Format

All responses follow this structure:

```json
{
  "success": true,
  "data": {},
  "message": "Operation successful",
  "timestamp": "2025-01-26T10:30:00Z"
}
```

Error responses:

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid input parameters",
    "details": {}
  },
  "timestamp": "2025-01-26T10:30:00Z"
}
```

## Blockchain API

### Wallets

#### Create Wallet
```http
POST /api/blockchain/wallets
Content-Type: application/json

{
  "network": "ethereum",
  "name": "My Main Wallet"
}
```

#### Get Wallets
```http
GET /api/blockchain/wallets
```

#### Get Wallet Balance
```http
GET /api/blockchain/wallets/{wallet_id}/balance
```

#### Send Transaction
```http
POST /api/blockchain/wallets/{wallet_id}/transactions
Content-Type: application/json

{
  "to": "0x1234...",
  "amount": "1.0",
  "gas_price": "20"
}
```

### NFTs

#### Mint NFT
```http
POST /api/blockchain/nfts/mint
Content-Type: application/json

{
  "contract_address": "0x5678...",
  "metadata": {
    "name": "My NFT",
    "description": "Description",
    "image": "ipfs://..."
  }
}
```

#### Get NFTs
```http
GET /api/blockchain/nfts?owner={address}
```

#### Transfer NFT
```http
POST /api/blockchain/nfts/{token_id}/transfer
Content-Type: application/json

{
  "to": "0x9abc...",
  "contract_address": "0x5678..."
}
```

## Gaming API

### User Progress

#### Get Progress
```http
GET /api/gaming/progress/{user_id}
```

#### Update Progress
```http
PUT /api/gaming/progress/{user_id}
Content-Type: application/json

{
  "experience": 100,
  "level": 5,
  "coins": 50,
  "gems": 10
}
```

### Achievements

#### Get Achievements
```http
GET /api/gaming/achievements
```

#### Unlock Achievement
```http
POST /api/gaming/achievements/{achievement_id}/unlock
Content-Type: application/json

{
  "user_id": "user123"
}
```

### Rewards

#### Get Available Rewards
```http
GET /api/gaming/rewards
```

#### Purchase Reward
```http
POST /api/gaming/rewards/{reward_id}/purchase
Content-Type: application/json

{
  "user_id": "user123",
  "payment_method": "coins"
}
```

## IoT API

### Devices

#### Discover Devices
```http
GET /api/iot/devices/discover
```

#### Register Device
```http
POST /api/iot/devices
Content-Type: application/json

{
  "name": "Temperature Sensor",
  "type": "sensor",
  "manufacturer": "SmartHome Inc",
  "mac_address": "AA:BB:CC:DD:EE:FF"
}
```

#### Get Devices
```http
GET /api/iot/devices?connected=true
```

#### Send Command
```http
POST /api/iot/devices/{device_id}/commands
Content-Type: application/json

{
  "command": "turn_on",
  "parameters": {
    "brightness": 80
  }
}
```

### Sensor Data

#### Get Sensor Data
```http
GET /api/iot/sensors/{device_id}/data?from={timestamp}&to={timestamp}
```

#### Subscribe to Data
```http
WebSocket: wss://api.katya-ai-rechain-mesh.com/api/iot/sensors/{device_id}/stream
```

### Automation Rules

#### Create Rule
```http
POST /api/iot/rules
Content-Type: application/json

{
  "name": "Auto Light",
  "device_id": "device123",
  "sensor_type": "motion",
  "condition": "motion_detected == true",
  "action": "turn_on_light"
}
```

#### Get Rules
```http
GET /api/iot/rules?device_id={device_id}
```

## Social API

### Profiles

#### Get Profile
```http
GET /api/social/profiles/{user_id}
```

#### Update Profile
```http
PUT /api/social/profiles/{user_id}
Content-Type: application/json

{
  "display_name": "John Doe",
  "bio": "Flutter developer",
  "interests": ["technology", "blockchain"]
}
```

### Friends

#### Send Friend Request
```http
POST /api/social/friends/requests
Content-Type: application/json

{
  "to_user_id": "user456"
}
```

#### Get Friends
```http
GET /api/social/friends/{user_id}
```

#### Accept Friend Request
```http
PUT /api/social/friends/requests/{request_id}/accept
```

### Groups

#### Create Group
```http
POST /api/social/groups
Content-Type: application/json

{
  "name": "Flutter Developers",
  "description": "Community of Flutter enthusiasts",
  "type": "public"
}
```

#### Join Group
```http
POST /api/social/groups/{group_id}/join
```

#### Get Group Members
```http
GET /api/social/groups/{group_id}/members
```

### Messages

#### Send Message
```http
POST /api/social/messages
Content-Type: application/json

{
  "recipient_id": "user456",
  "content": "Hello!",
  "type": "text"
}
```

#### Get Messages
```http
GET /api/social/messages?conversation_id={conversation_id}&limit=50
```

#### Mark as Read
```http
PUT /api/social/messages/{message_id}/read
```

### Polls

#### Create Poll
```http
POST /api/social/polls
Content-Type: application/json

{
  "question": "What's your favorite Flutter feature?",
  "options": ["Hot Reload", "Widget Tree", "State Management"],
  "duration_hours": 24
}
```

#### Vote
```http
POST /api/social/polls/{poll_id}/vote
Content-Type: application/json

{
  "option_index": 0
}
```

#### Get Poll Results
```http
GET /api/social/polls/{poll_id}/results
```

## WebSocket Events

### Real-time Updates

#### Blockchain Events
```javascript
// Subscribe to wallet balance changes
socket.emit('subscribe', 'blockchain:balance:{wallet_id}');

// Subscribe to NFT transfers
socket.emit('subscribe', 'blockchain:nft:transfers');
```

#### IoT Events
```javascript
// Subscribe to sensor data
socket.emit('subscribe', 'iot:sensors:{device_id}');

// Subscribe to device status changes
socket.emit('subscribe', 'iot:devices:status');
```

#### Social Events
```javascript
// Subscribe to messages
socket.emit('subscribe', 'social:messages:{user_id}');

// Subscribe to friend requests
socket.emit('subscribe', 'social:friends:requests:{user_id}');
```

## Rate Limiting

API endpoints are rate-limited to prevent abuse:

- **Authentication**: 5 requests/minute
- **General API**: 100 requests/minute
- **IoT commands**: 30 requests/minute
- **File uploads**: 10 requests/hour

## Error Codes

| Code | Description |
|------|-------------|
| 400 | Bad Request - Invalid input |
| 401 | Unauthorized - Invalid authentication |
| 403 | Forbidden - Insufficient permissions |
| 404 | Not Found - Resource doesn't exist |
| 429 | Too Many Requests - Rate limit exceeded |
| 500 | Internal Server Error - Server issue |
| 503 | Service Unavailable - Service temporarily down |

## SDKs and Libraries

### Flutter SDK
```dart
import 'package:katya_rechain_mesh_api/katya_rechain_mesh_api.dart';

final api = KatyaRechainMeshAPI(baseUrl: 'https://api.katya-ai-rechain-mesh.com');
```

### JavaScript SDK
```javascript
import { KatyaRechainMeshAPI } from 'katya-rechain-mesh-api';

const api = new KatyaRechainMeshAPI('https://api.katya-ai-rechain-mesh.com');
```

## Support

For API support and questions:
- **Documentation**: [docs.katya-ai-rechain-mesh.com](https://docs.katya-ai-rechain-mesh.com)
- **Issues**: [GitHub Issues](https://github.com/katya-ai-rechain-mesh/issues)
- **Email**: api-support@katya-ai.com

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for API version history and breaking changes.
