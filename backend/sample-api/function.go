package function

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
)

func Trigger(w http.ResponseWriter, r *http.Request) {
	data, err := ioutil.ReadAll(r.Body)
	if err != nil {
		log.Printf("ioutil.ReadAll: %v", err)
		http.Error(w, "Error reading request", http.StatusBadRequest)
		return
	}
	log.Print("works")
	if _, err := fmt.Fprintf(w, "Echo: %v", string(data)); err != nil {
		log.Printf("error: %v", err)
	}
}
