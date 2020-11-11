package function

import (
	"cloud.google.com/go/firestore"
	"cloud.google.com/go/functions/metadata"
	"context"
	"encoding/json"
	"fmt"
	"github.com/go-chi/chi"
	"log"
	"net/http"
	"os"
)

var s = newServer()
var mux = configureMux()

func configureMux() http.Handler {
	mux := Handler(s).(*chi.Mux)
	return mux.With(withEventID)
}

//noinspection GoUnusedExportedFunction
func Trigger(w http.ResponseWriter, r *http.Request) {
	mux.ServeHTTP(w, r)
}

func withEventID(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		ctx = context.WithValue(ctx, "eventID", "1")
		next.ServeHTTP(w, r.WithContext(ctx))
	})
}

type server struct {
	client *firestore.Client
}

func newServer() ServerInterface {
	ctx := context.Background()
	client, err := firestore.NewClient(ctx, os.Getenv("GCP_PROJECT"))
	if err != nil {
		panic(err)
	}
	return &server{
		client: client,
	}
}

func (s *server) GetItems(w http.ResponseWriter, r *http.Request) {
	eventID := r.Context().Value("eventID").(string)
	c := s.client.Collection("todomvc/item")
	it := c.Select().Documents(r.Context())
	defer it.Stop()
	items, err := it.GetAll()
	if err != nil {
		s.sendError(w, http.StatusInternalServerError, ErrorResponse{
			Message:   err.Error(),
			RequestId: eventID,
		})
		return
	}
	response := ItemsListResponse{
		Items:     make([]Item, len(items)),
		RequestId: eventID,
	}
	for i := range items {
		item, err := s.mapToItem(items[i])
		if err != nil {
			s.sendError(w, http.StatusInternalServerError, ErrorResponse{
				Message:   err.Error(),
				RequestId: eventID,
			})
			return
		}
		response.Items[i] = item
	}
	s.sendResponse(w, response)
}

func (s *server) mapToItem(doc *firestore.DocumentSnapshot) (Item, error) {
	var item Item
	err := doc.DataTo(&item)
	return item, err
}

func (s *server) DeleteItem(w http.ResponseWriter, r *http.Request) {
	panic("implement me")
}

func (s *server) GetItem(w http.ResponseWriter, r *http.Request) {
	m, err := metadata.FromContext(r.Context())
	if err != nil {
		s.sendError(w, http.StatusInternalServerError, ErrorResponse{
			Message:   err.Error(),
			RequestId: "undefined",
		})
		return
	}
	itemID := chi.URLParam(r, "id")
	c := s.client.Collection("todomvc/item")
	snapshot, err := c.Doc(itemID).Get(r.Context())
	if err != nil {
		s.sendError(w, http.StatusInternalServerError, ErrorResponse{
			Message:   err.Error(),
			RequestId: m.EventID,
		})
		return
	}
	item, err := s.mapToItem(snapshot)
	if err != nil {
		s.sendError(w, http.StatusInternalServerError, ErrorResponse{
			Message:   err.Error(),
			RequestId: m.EventID,
		})
		return
	}
	response := ItemResponse{
		Item:      item,
		RequestId: m.EventID,
	}
	s.sendResponse(w, response)
}

func (s *server) SaveItem(w http.ResponseWriter, r *http.Request) {
	panic("implement me")
}

func (s *server) sendError(w http.ResponseWriter, statusCode int, response ErrorResponse) {
	w.Header().Set("Content-Type", "text/json; charset=utf-8")
	w.Header().Set("X-Content-Type-Options", "nosniff")
	w.WriteHeader(statusCode)
	b, err := json.Marshal(response)
	if err != nil {
		log.Printf("error: %+v", err)
		_, _ = fmt.Fprintln(w, err.Error())
	} else {
		log.Printf("error: %s", b)
		_, _ = fmt.Fprintf(w, "%s", b)
	}
}

func (s *server) sendResponse(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "text/json; charset=utf-8")
	w.WriteHeader(http.StatusOK)
	b, err := json.Marshal(data)
	if err != nil {
		log.Printf("error: %+v", err)
		_, _ = fmt.Fprintln(w, err.Error())
	} else {
		_, _ = fmt.Fprintf(w, "%s", b)
	}
}
