import 'base_entity.dart';

/// Represents a vote in the consensus mechanism
class Vote extends BaseEntity {
  /// ID of the proposal being voted on
  final String proposalId;
  
  /// ID of the voter (peer)
  final String voterId;
  
  /// Type of vote (e.g., yes, no, abstain)
  final VoteType type;
  
  /// Weight of the vote (for weighted voting systems)
  final double weight;
  
  /// Optional metadata or justification for the vote
  final Map<String, dynamic> metadata;
  
  /// Digital signature of the vote
  final String signature;

  const Vote({
    required super.id,
    required this.proposalId,
    required this.voterId,
    required this.type,
    this.weight = 1.0,
    this.metadata = const {},
    required this.signature,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a copy of the vote with updated fields
  @override
  Vote copyWith({
    String? id,
    String? proposalId,
    String? voterId,
    VoteType? type,
    double? weight,
    Map<String, dynamic>? metadata,
    String? signature,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vote(
      id: id ?? this.id,
      proposalId: proposalId ?? this.proposalId,
      voterId: voterId ?? this.voterId,
      type: type ?? this.type,
      weight: weight ?? this.weight,
      metadata: metadata ?? this.metadata,
      signature: signature ?? this.signature,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        ...super.props,
        proposalId,
        voterId,
        type,
        weight,
        metadata,
        signature,
      ];

  /// Creates a Vote from JSON
  factory Vote.fromJson(Map<String, dynamic> json) {
    return Vote(
      id: json['id'] as String,
      proposalId: json['proposalId'] as String,
      voterId: json['voterId'] as String,
      type: VoteType.values.firstWhere(
        (e) => e.toString() == 'VoteType.${json['type']}',
        orElse: () => VoteType.yes, // Default to yes if not specified
      ),
      weight: (json['weight'] as num?)?.toDouble() ?? 1.0,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      signature: json['signature'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the Vote to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'proposalId': proposalId,
      'voterId': voterId,
      'type': type.toString().split('.').last,
      'weight': weight,
      'metadata': metadata,
      'signature': signature,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Represents a proposal that can be voted on
class Proposal extends BaseEntity {
  /// Title of the proposal
  final String title;
  
  /// Detailed description of the proposal
  final String description;
  
  /// ID of the peer who created the proposal
  final String creatorId;
  
  /// Current status of the proposal
  final ProposalStatus status;
  
  /// Type of proposal
  final ProposalType type;
  
  /// Optional start time for voting
  final DateTime? votingStartTime;
  
  /// Optional end time for voting
  final DateTime? votingEndTime;
  
  /// Quorum required for the proposal to pass (0-1)
  final double quorum;
  
  /// Threshold for approval (0-1)
  final double approvalThreshold;
  
  /// List of voter peer IDs (empty for all peers)
  final List<String> eligibleVoterIds;
  
  /// Optional metadata
  final Map<String, dynamic> metadata;
  
  /// Optional data payload
  final Map<String, dynamic>? data;

  const Proposal({
    required super.id,
    required this.title,
    required this.description,
    required this.creatorId,
    this.status = ProposalStatus.draft,
    this.type = ProposalType.general,
    this.votingStartTime,
    this.votingEndTime,
    this.quorum = 0.5,
    this.approvalThreshold = 0.5,
    this.eligibleVoterIds = const [],
    this.metadata = const {},
    this.data,
    required super.createdAt,
    required super.updatedAt,
  })  : assert(quorum >= 0 && quorum <= 1, 'Quorum must be between 0 and 1'),
        assert(approvalThreshold >= 0 && approvalThreshold <= 1,
            'Approval threshold must be between 0 and 1');

  /// Whether the proposal is currently open for voting
  bool get isVotingOpen {
    if (status != ProposalStatus.voting) return false;
    final now = DateTime.now();
    if (votingStartTime != null && now.isBefore(votingStartTime!)) return false;
    if (votingEndTime != null && now.isAfter(votingEndTime!)) return false;
    return true;
  }

  /// Whether the proposal has passed
  bool get isPassed {
    if (status != ProposalStatus.passed) return false;
    // Implementation would check actual votes against thresholds
    return true; // Simplified for this example
  }

  @override
  List<Object?> get props => [
        ...super.props,
        title,
        description,
        creatorId,
        status,
        type,
        votingStartTime,
        votingEndTime,
        quorum,
        approvalThreshold,
        eligibleVoterIds,
        metadata,
        data,
      ];

  /// Creates a copy of the proposal with updated fields
  @override
  Proposal copyWith({
    String? id,
    String? title,
    String? description,
    String? creatorId,
    ProposalStatus? status,
    ProposalType? type,
    DateTime? votingStartTime,
    DateTime? votingEndTime,
    double? quorum,
    double? approvalThreshold,
    List<String>? eligibleVoterIds,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Proposal(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      creatorId: creatorId ?? this.creatorId,
      status: status ?? this.status,
      type: type ?? this.type,
      votingStartTime: votingStartTime ?? this.votingStartTime,
      votingEndTime: votingEndTime ?? this.votingEndTime,
      quorum: quorum ?? this.quorum,
      approvalThreshold: approvalThreshold ?? this.approvalThreshold,
      eligibleVoterIds: eligibleVoterIds ?? this.eligibleVoterIds,
      metadata: metadata ?? this.metadata,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Creates a Proposal from JSON
  factory Proposal.fromJson(Map<String, dynamic> json) {
    return Proposal(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      creatorId: json['creatorId'] as String,
      status: ProposalStatus.values.firstWhere(
        (e) => e.toString() == 'ProposalStatus.${json['status']}',
        orElse: () => ProposalStatus.draft,
      ),
      type: ProposalType.values.firstWhere(
        (e) => e.toString() == 'ProposalType.${json['type']}',
        orElse: () => ProposalType.general,
      ),
      votingStartTime: json['votingStartTime'] != null
          ? DateTime.parse(json['votingStartTime'] as String)
          : null,
      votingEndTime: json['votingEndTime'] != null
          ? DateTime.parse(json['votingEndTime'] as String)
          : null,
      quorum: (json['quorum'] as num?)?.toDouble() ?? 0.5,
      approvalThreshold: (json['approvalThreshold'] as num?)?.toDouble() ?? 0.5,
      eligibleVoterIds: (json['eligibleVoterIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      data: json['data'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Converts the Proposal to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'creatorId': creatorId,
      'status': status.toString().split('.').last,
      'type': type.toString().split('.').last,
      if (votingStartTime != null)
        'votingStartTime': votingStartTime!.toIso8601String(),
      if (votingEndTime != null)
        'votingEndTime': votingEndTime!.toIso8601String(),
      'quorum': quorum,
      'approvalThreshold': approvalThreshold,
      'eligibleVoterIds': eligibleVoterIds,
      'metadata': metadata,
      if (data != null) 'data': data,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

/// Types of votes
enum VoteType {
  /// In favor of the proposal
  yes,
  
  /// Against the proposal
  no,
  
  /// Abstain from voting (counts toward quorum but not for/against)
  abstain,
  
  /// Veto the proposal (stronger than no in some systems)
  veto,
}

/// Status of a proposal
enum ProposalStatus {
  /// Initial draft state
  draft,
  
  /// Open for voting
  voting,
  
  /// Voting has ended, processing results
  tallying,
  
  /// Proposal has passed
  passed,
  
  /// Proposal was rejected
  rejected,
  
  /// Proposal was executed
  executed,
  
  /// Proposal was cancelled
  cancelled,
  
  /// Proposal failed to execute
  failed,
}

/// Type of proposal
enum ProposalType {
  /// General purpose proposal
  general,
  
  /// Protocol parameter change
  parameterChange,
  
  /// Software upgrade proposal
  softwareUpgrade,
  
  /// Community pool spend proposal
  communityPoolSpend,
  
  /// Text proposal (for signaling)
  text,
  
  /// Emergency proposal (fast-tracked)
  emergency,
  
  /// Governance parameter change
  governanceParameterChange,
}
