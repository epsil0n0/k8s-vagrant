package http

import (
	"context"
	"fmt"
	http1 "github.com/go-kit/kit/transport/http"
	"net/http"
	endpoint "version_api/pkg/endpoint"
)

// makeVersionHandler creates the handler logic
func makeVersionHandler(m *http.ServeMux, endpoints endpoint.Endpoints, options []http1.ServerOption) {
	m.Handle("/version", http1.NewServer(endpoints.VersionEndpoint, decodeVersionRequest, encodeVersionResponse, options...))
}

// decodeVersionRequest is a transport/http.DecodeRequestFunc that decodes a
// JSON-encoded request from the HTTP request body.
func decodeVersionRequest(_ context.Context, r *http.Request) (interface{}, error) {
	req := endpoint.VersionRequest{}

	return req, nil
}

// encodeVersionResponse is a transport/http.EncodeResponseFunc that encodes
// the response as JSON to the response writer
func encodeVersionResponse(ctx context.Context, w http.ResponseWriter, response interface{}) (err error) {
	//w.Header().Set("Content-Type", "application/json; charset=utf-8")
	//err = json.NewEncoder(w).Encode(response)
	fmt.Fprintf(w,"v1")
	return
}
