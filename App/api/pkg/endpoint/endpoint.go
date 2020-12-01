package endpoint

import (
	"context"
	endpoint "github.com/go-kit/kit/endpoint"
	service "version_api/pkg/service"
)

// VersionRequest collects the request parameters for the Version method.
type VersionRequest struct{}

// VersionResponse collects the response parameters for the Version method.
type VersionResponse struct {
	S0 string `json:"version"`
}

// MakeVersionEndpoint returns an endpoint that invokes Version on the service.
func MakeVersionEndpoint(s service.VersionApiService) endpoint.Endpoint {
	return func(ctx context.Context, request interface{}) (interface{}, error) {
		s0 := s.Version(ctx)
		return VersionResponse{S0: s0}, nil
	}
}

// Version implements Service. Primarily useful in a client.
func (e Endpoints) Version(ctx context.Context) (s0 string) {
	request := VersionRequest{}
	response, err := e.VersionEndpoint(ctx, request)
	if err != nil {
		return
	}
	return response.(VersionResponse).S0
}
