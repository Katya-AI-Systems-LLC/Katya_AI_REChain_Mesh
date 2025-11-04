import '../../domain/vote.dart';
import 'base_repository.dart';

/// Repository for managing Vote and Proposal entities
abstract class VoteRepository extends BaseRepository<Vote> {
  /// Creates a new proposal
  Future<Proposal> createProposal(Proposal proposal);
  
  /// Updates an existing proposal
  Future<Proposal> updateProposal(Proposal proposal);
  
  /// Finds a proposal by ID
  Future<Proposal?> findProposalById(String proposalId);
  
  /// Finds all proposals
  Future<List<Proposal>> findAllProposals({
    String? creatorId,
    ProposalStatus? status,
    ProposalType? type,
    bool includeClosed = false,
  });
  
  /// Casts a vote on a proposal
  Future<Vote> castVote(Vote vote);
  
  /// Finds votes for a specific proposal
  Future<List<Vote>> findVotesByProposal(String proposalId);
  
  /// Counts votes for a specific proposal by type
  Future<Map<VoteType, int>> countVotes(String proposalId);
  
  /// Checks if a peer has already voted on a proposal
  Future<bool> hasVoted(String proposalId, String voterId);
  
  /// Updates the status of a proposal
  Future<void> updateProposalStatus(String proposalId, ProposalStatus status);
  
  /// Stream of proposal updates
  Stream<Proposal> watchProposal(String proposalId);
  
  /// Stream of all active proposals
  Stream<List<Proposal>> watchActiveProposals();
  
  /// Calculates the current result of a proposal
  Future<ProposalResult> calculateResult(String proposalId);
}

/// Represents the result of a proposal
class ProposalResult {
  /// The proposal ID
  final String proposalId;
  
  /// Total number of eligible voters
  final int totalVoters;
  
  /// Number of votes cast
  final int votesCast;
  
  /// Votes by type
  final Map<VoteType, int> votes;
  
  /// Whether the quorum was reached
  final bool quorumReached;
  
  /// Whether the approval threshold was reached
  final bool approved;
  
  /// Optional message with additional information
  final String? message;

  const ProposalResult({
    required this.proposalId,
    required this.totalVoters,
    required this.votesCast,
    required this.votes,
    required this.quorumReached,
    required this.approved,
    this.message,
  });

  /// Participation rate (0-1)
  double get participationRate => totalVoters > 0 ? votesCast / totalVoters : 0;
  
  /// Gets the count for a specific vote type
  int getVoteCount(VoteType type) => votes[type] ?? 0;
  
  /// Gets the percentage of votes for a specific type (0-100)
  double getVotePercentage(VoteType type) {
    if (votesCast == 0) return 0;
    return (getVoteCount(type) / votesCast) * 100;
  }
  
  /// Creates a copy with updated fields
  ProposalResult copyWith({
    String? proposalId,
    int? totalVoters,
    int? votesCast,
    Map<VoteType, int>? votes,
    bool? quorumReached,
    bool? approved,
    String? message,
  }) {
    return ProposalResult(
      proposalId: proposalId ?? this.proposalId,
      totalVoters: totalVoters ?? this.totalVoters,
      votesCast: votesCast ?? this.votesCast,
      votes: votes ?? this.votes,
      quorumReached: quorumReached ?? this.quorumReached,
      approved: approved ?? this.approved,
      message: message ?? this.message,
    );
  }
  
  @override
  String toString() {
    return 'ProposalResult(' 
        'proposalId: $proposalId, '
        'approved: $approved, '
        'quorumReached: $quorumReached, '
        'participation: ${(participationRate * 100).toStringAsFixed(1)}%, '
        'votes: $votes'
        ')';
  }
}
