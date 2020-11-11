package function

import (
	"github.com/stretchr/testify/require"
	"net/http"
	"testing"
)

func Test_GetItems(t *testing.T) {
	require.HTTPSuccess(t, handler, "GET", "/api/items-endpoint", nil)

}

func handler(writer http.ResponseWriter, request *http.Request) {
	mux.ServeHTTP(writer, request)
}
