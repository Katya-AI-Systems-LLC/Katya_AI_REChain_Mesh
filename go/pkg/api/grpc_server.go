package api

import (
	"context"
	"fmt"
	"net"
	"time"

	"go.uber.org/zap"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	pb "github.com/rechain-network/katya-mesh-go/pkg/api/proto"
)

// GRPCServer implements the gRPC API server
type GRPCServer struct {
	pb.UnimplementedMeshServiceServer
	server   *grpc.Server
	listener net.Listener
	logger   *zap.Logger
	broker   MeshBroker // Interface for mesh operations
}

// NewGRPCServer creates a new gRPC server
func NewGRPCServer(broker MeshBroker, logger *zap.Logger) *GRPCServer {
	return &GRPCServer{
		broker: broker,
		logger: logger,
	}
}

// Start starts the gRPC server
func (s *GRPCServer) Start(address string) error {
	listener, err := net.Listen("tcp", address)
	if err != nil {
		return fmt.Errorf("failed to listen on %s: %w", address, err)
	}

	s.listener = listener
	s.server = grpc.NewServer(
		grpc.UnaryInterceptor(s.unaryInterceptor),
		grpc.StreamInterceptor(s.streamInterceptor),
	)

	pb.RegisterMeshServiceServer(s.server, s)
	reflection.Register(s.server)

	s.logger.Info("Starting gRPC server", zap.String("address", address))
	go func() {
		if err := s.server.Serve(listener); err != nil {
			s.logger.Error("gRPC server error", zap.Error(err))
		}
	}()

	return nil
}

// Stop stops the gRPC server
func (s *GRPCServer) Stop() {
	if s.server != nil {
		s.logger.Info("Stopping gRPC server")
		s.server.GracefulStop()
	}
	if s.listener != nil {
		s.listener.Close()
	}
}

// unaryInterceptor provides unary RPC interception
func (s *GRPCServer) unaryInterceptor(ctx context.Context, req interface{}, info *grpc.UnaryServerInfo, handler grpc.UnaryHandler) (interface{}, error) {
	start := time.Now()
	resp, err := handler(ctx, req)
	duration := time.Since(start)

	s.logger.Debug("gRPC unary call",
		zap.String("method", info.FullMethod),
		zap.Duration("duration", duration),
		zap.Error(err))

	return resp, err
}

// streamInterceptor provides stream RPC interception
func (s *GRPCServer) streamInterceptor(srv interface{}, stream grpc.ServerStream, info *grpc.StreamServerInfo, handler grpc.StreamHandler) error {
	start := time.Now()
	err := handler(srv, stream)
	duration := time.Since(start)

	s.logger.Debug("gRPC stream call",
		zap.String("method", info.FullMethod),
		zap.Duration("duration", duration),
		zap.Error(err))

	return err
}

// GetPeers implements the GetPeers gRPC method
func (s *GRPCServer) GetPeers(ctx context.Context, req *pb.GetPeersRequest) (*pb.GetPeersResponse, error) {
	peers, err := s.broker.GetPeers(ctx)
	if err != nil {
		s.logger.Error("Failed to get peers", zap.Error(err))
		return nil, fmt.Errorf("failed to get peers: %w", err)
	}

	var peerProtos []*pb.Peer
	for _, peer := range peers {
		peerProtos = append(peerProtos, &pb.Peer{
			Id:       peer.ID,
			Address:  peer.Address,
			LastSeen: peer.LastSeen.Unix(),
		})
	}

	return &pb.GetPeersResponse{Peers: peerProtos}, nil
}

// SendMessage implements the SendMessage gRPC method
func (s *GRPCServer) SendMessage(ctx context.Context, req *pb.SendMessageRequest) (*pb.SendMessageResponse, error) {
	message := &Message{
		ID:        req.Message.Id,
		Type:      MessageType(req.Message.Type),
		From:      req.Message.From,
		To:        req.Message.To,
		Payload:   req.Message.Payload,
		Timestamp: time.Unix(req.Message.Timestamp, 0),
	}

	err := s.broker.SendMessage(ctx, message)
	if err != nil {
		s.logger.Error("Failed to send message", zap.Error(err))
		return nil, fmt.Errorf("failed to send message: %w", err)
	}

	return &pb.SendMessageResponse{Success: true}, nil
}

// CreatePoll implements the CreatePoll gRPC method
func (s *GRPCServer) CreatePoll(ctx context.Context, req *pb.CreatePollRequest) (*pb.CreatePollResponse, error) {
	poll := &Poll{
		ID:          req.Poll.Id,
		Title:       req.Poll.Title,
		Description: req.Poll.Description,
		Options:     req.Poll.Options,
		CreatedBy:   req.Poll.CreatedBy,
		CreatedAt:   time.Unix(req.Poll.CreatedAt, 0),
	}

	err := s.broker.CreatePoll(ctx, poll)
	if err != nil {
		s.logger.Error("Failed to create poll", zap.Error(err))
		return nil, fmt.Errorf("failed to create poll: %w", err)
	}

	return &pb.CreatePollResponse{PollId: poll.ID}, nil
}

// VotePoll implements the VotePoll gRPC method
func (s *GRPCServer) VotePoll(ctx context.Context, req *pb.VotePollRequest) (*pb.VotePollResponse, error) {
	vote := &Vote{
		PollID:   req.Vote.PollId,
		UserID:   req.Vote.UserId,
		Option:   req.Vote.Option,
		VotedAt:  time.Unix(req.Vote.VotedAt, 0),
	}

	err := s.broker.VotePoll(ctx, vote)
	if err != nil {
		s.logger.Error("Failed to vote poll", zap.Error(err))
		return nil, fmt.Errorf("failed to vote poll: %w", err)
	}

	return &pb.VotePollResponse{Success: true}, nil
}

// GetStats implements the GetStats gRPC method
func (s *GRPCServer) GetStats(ctx context.Context, req *pb.GetStatsRequest) (*pb.GetStatsResponse, error) {
	stats, err := s.broker.GetStats(ctx)
	if err != nil {
		s.logger.Error("Failed to get stats", zap.Error(err))
		return nil, fmt.Errorf("failed to get stats: %w", err)
	}

	return &pb.GetStatsResponse{Stats: stats}, nil
}

// StreamMessages implements the StreamMessages gRPC method
func (s *GRPCServer) StreamMessages(req *pb.StreamMessagesRequest, stream pb.MeshService_StreamMessagesServer) error {
	messageChan, err := s.broker.SubscribeMessages(stream.Context())
	if err != nil {
		s.logger.Error("Failed to subscribe to messages", zap.Error(err))
		return fmt.Errorf("failed to subscribe to messages: %w", err)
	}

	for {
		select {
		case <-stream.Context().Done():
			return nil
		case message := <-messageChan:
			protoMsg := &pb.Message{
				Id:        message.ID,
				Type:      string(message.Type),
				From:      message.From,
				To:        message.To,
				Payload:   fmt.Sprintf("%v", message.Payload),
				Timestamp: message.Timestamp.Unix(),
			}

			if err := stream.Send(protoMsg); err != nil {
				s.logger.Error("Failed to send message in stream", zap.Error(err))
				return err
			}
		}
	}
}

// StreamPolls implements the StreamPolls gRPC method
func (s *GRPCServer) StreamPolls(req *pb.StreamPollsRequest, stream pb.MeshService_StreamPollsServer) error {
	pollChan, err := s.broker.SubscribePolls(stream.Context())
	if err != nil {
		s.logger.Error("Failed to subscribe to polls", zap.Error(err))
		return fmt.Errorf("failed to subscribe to polls: %w", err)
	}

	for {
		select {
		case <-stream.Context().Done():
			return nil
		case poll := <-pollChan:
			protoPoll := &pb.Poll{
				Id:          poll.ID,
				Title:       poll.Title,
				Description: poll.Description,
				Options:     poll.Options,
				CreatedBy:   poll.CreatedBy,
				CreatedAt:   poll.CreatedAt.Unix(),
			}

			if err := stream.Send(protoPoll); err != nil {
				s.logger.Error("Failed to send poll in stream", zap.Error(err))
				return err
			}
		}
	}
}
