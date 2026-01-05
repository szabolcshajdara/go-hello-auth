package goauth

import (
	"fmt"
	"net/http"

	"github.com/GoogleCloudPlatform/functions-framework-go/functions"
)

func init() {
	functions.HTTP("HelloAuth", helloAuth)
}

func helloAuth(w http.ResponseWriter, r *http.Request) {
	// 1. Set CORS headers
	w.Header().Set("Access-Control-Allow-Origin", "https://storage.googleapis.com") // Or "*"
	w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type, Authorization")

	// 2. Handle Preflight
	if r.Method == http.MethodOptions {
		w.WriteHeader(http.StatusNoContent)
		return
	}

	// 3. Logic
	fmt.Fprint(w, "Hello, World!")
}
