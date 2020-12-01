package service

import "context"

const version = "v1.0.0"

// VersionApiService describes the service.
type VersionApiService interface {
	Version(ctx context.Context) string
}

type basicVersionApiService struct{}

func (b *basicVersionApiService) Version(ctx context.Context) (s0 string) {
	return version
}

// NewBasicVersionApiService returns a naive, stateless implementation of VersionApiService.
func NewBasicVersionApiService() VersionApiService {
	return &basicVersionApiService{}
}

// New returns a VersionApiService with all of the expected middleware wired in.
func New(middleware []Middleware) VersionApiService {
	var svc VersionApiService = NewBasicVersionApiService()
	for _, m := range middleware {
		svc = m(svc)
	}
	return svc
}
