package function

import (
	"net/http"
)

func Trigger(w http.ResponseWriter, r *http.Request) {
	Handler(&handler{}).ServeHTTP(w, r)
}

type handler struct{}

func (h *handler) GetItems(w http.ResponseWriter, r *http.Request) {
	panic("implement me")
}

func (h *handler) DeleteItem(w http.ResponseWriter, r *http.Request) {
	panic("implement me")
}

func (h *handler) GetItem(w http.ResponseWriter, r *http.Request) {
	panic("implement me")
}

func (h *handler) SaveItem(w http.ResponseWriter, r *http.Request) {
	panic("implement me")
}
