# Decentralized Cultural Exchange Smart Contract

A blockchain-powered platform for cross-cultural learning with immersive experiences built on the Stacks blockchain using Clarity smart contracts.

## Overview

The Decentralized Cultural Exchange platform enables cultural hosts to create immersive learning experiences while allowing participants to discover and engage with diverse cultures in a trustless, decentralized environment. The platform facilitates cultural exchange through smart contracts that handle payments, reviews, and reputation systems.

## Features

### Core Functionality
- **Cultural Experience Creation**: Hosts can create detailed cultural experiences with pricing and participant limits
- **Secure Payments**: Automated payment processing with platform fees
- **Review System**: Post-experience rating and review mechanism
- **Profile Management**: Separate profiles for hosts and participants
- **Cultural Badges**: Achievement system for participants
- **Attendance Tracking**: Host-verified attendance system

### Smart Contract Features
- **Gas Optimized**: Efficient Clarity code with minimal transaction costs
- **Security First**: Comprehensive input validation and error handling
- **Transparent**: All transactions and ratings publicly verifiable
- **Decentralized**: No central authority controls user interactions

## Contract Structure

### Data Models

#### Cultural Experience
```clarity
{
  host: principal,
  title: (string-ascii 100),
  description: (string-ascii 500),
  culture: (string-ascii 50),
  location: (string-ascii 100),
  price: uint,
  max-participants: uint,
  current-participants: uint,
  start-time: uint,
  end-time: uint,
  is-active: bool,
  total-earned: uint
}
```

#### Host Profile
```clarity
{
  name: (string-ascii 50),
  bio: (string-ascii 300),
  cultural-background: (string-ascii 100),
  rating: uint,
  total-reviews: uint,
  experiences-hosted: uint,
  is-verified: bool
}
```

#### Participant Profile
```clarity
{
  name: (string-ascii 50),
  interests: (string-ascii 200),
  experiences-joined: uint,
  cultural-badges: (list 10 (string-ascii 30))
}
```

## Key Functions

### Host Functions
- `create-host-profile`: Register as a cultural experience host
- `create-experience`: Create a new cultural exchange experience
- `mark-attendance`: Verify participant attendance
- `deactivate-experience`: Emergency deactivation of experiences

### Participant Functions
- `create-participant-profile`: Register as a cultural exchange participant
- `join-experience`: Book and pay for cultural experiences
- `submit-review`: Rate and review completed experiences

### Administrative Functions
- `award-cultural-badge`: Award achievements to participants
- `update-platform-fee`: Adjust platform commission (owner only)

## Getting Started

### Prerequisites
- Stacks wallet (Hiro Wallet, Xverse, etc.)
- STX tokens for transactions and experience payments
- Clarity CLI for development (optional)

### Deployment

1. **Deploy to Stacks Testnet**
```bash
clarinet contract deploy cultural-exchange --testnet
```

2. **Deploy to Stacks Mainnet**
```bash
clarinet contract deploy cultural-exchange --mainnet
```

### Usage Examples

#### Creating a Host Profile
```clarity
(contract-call? .cultural-exchange create-host-profile 
  "Maria Santos" 
  "Passionate about sharing Brazilian culture through cooking and dance"
  "Brazilian"
)
```

#### Creating a Cultural Experience
```clarity
(contract-call? .cultural-exchange create-experience
  "Traditional Samba Workshop"
  "Learn authentic samba dancing with traditional music and cultural context"
  "Brazilian"
  "São Paulo, Brazil"
  u1000000 ;; 1 STX
  u20
  u1000 ;; start block
  u2000 ;; end block
)
```

#### Joining an Experience
```clarity
(contract-call? .cultural-exchange join-experience u1)
```

## Security Considerations

### Input Validation
- All string inputs are length-limited to prevent bloat
- Numeric inputs validated for reasonable ranges
- Principal validation for authorization checks

### Payment Security
- Atomic payment processing prevents partial failures
- Platform fees calculated and distributed automatically
- Funds held in contract until experience completion

### Access Control
- Host-only functions protected by principal verification
- Owner-only administrative functions secured
- Participant verification for review submissions

## Platform Economics

### Fee Structure
- **Platform Fee**: 5% (configurable by owner, max 10%)
- **Host Earnings**: 95% of experience price
- **Payment Token**: STX (Stacks native token)

### Incentive Mechanisms
- **Host Ratings**: Reputation-based discovery
- **Cultural Badges**: Gamification for participants
- **Review System**: Quality assurance mechanism

## Error Codes

| Code | Description |
|------|-------------|
| u401 | Unauthorized access |
| u404 | Resource not found |
| u400 | Invalid parameters |
| u402 | Insufficient funds |
| u409 | Resource already exists |
| u410 | Experience has ended |
| u411 | Not a participant |
| u412 | Review already submitted |

## Development

### Testing
```bash
clarinet test
```

### Local Development
```bash
clarinet console
```

### Contract Verification
The contract includes comprehensive checks for:
- Input validation
- Authorization verification
- State consistency
- Payment integrity

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions:
- Create an issue in the GitHub repository
- Join our Discord community
- Check the documentation wiki

## Roadmap

- [ ] Multi-token payment support
- [ ] Integration with IPFS for media storage
- [ ] Mobile app integration
- [ ] Advanced matching algorithms
- [ ] Cultural NFT certificates
- [ ] DAO governance implementation

---

**Built with love for global cultural exchange on Stacks blockchain**