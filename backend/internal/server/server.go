package server

import (
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/mux"

	"soundHelper/internal/db"
	"soundHelper/internal/recognition"
	"soundHelper/internal/recorgnition/pipeline/pipeline"
)

type Server struct {
	host         string
	port         int
	predictor    *recognition.Client
	ourPredictor *pipeline.Recognition
	database     *db.Database
	Router       *mux.Router
}

func NewServer(host string, port int, database *db.Database, recog *recognition.Client, ourRecog *pipeline.Recognition) *Server {
	r := mux.NewRouter()
	r.Use(loggingMiddleware)

	srv := &Server{
		host:         host,
		port:         port,
		Router:       r,
		ourPredictor: ourRecog,
		database:     database,
		predictor:    recog,
	}

	r.HandleFunc("/load", srv.load)
	r.HandleFunc("/login", srv.login)
	r.HandleFunc("/add-favorites", srv.addFavorite)
	r.HandleFunc("/delete-favorites", srv.deleteFavorite)
	r.HandleFunc("/check", srv.checkToken)
	r.HandleFunc("/recognition", srv.recognition)
	r.HandleFunc("/recognition-link", srv.recognitionLink)
	r.HandleFunc("/get-song-list", srv.getSongList)

	r.PathPrefix("/wav/").Handler(http.StripPrefix("/wav/", http.FileServer(http.Dir("wav"))))


	return srv
}

func (s *Server) Run() {
	address := fmt.Sprintf("%s:%v", s.host, s.port)
	srv := &http.Server{
		Handler: s.Router,
		Addr:    address,
	}

	log.Printf("Server run on http://%s\n", address)
	log.Fatal(srv.ListenAndServe())
}
