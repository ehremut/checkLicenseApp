package main

import (
	"soundHelper/internal/config"
	"soundHelper/internal/db"
	"soundHelper/internal/recognition"
	"soundHelper/internal/recorgnition/pipeline/pipeline"
	"soundHelper/internal/server"
)

func main() {
	config.LoadConfig("internal/config")
	conf := config.Config

	database := db.NewDatabase(conf.Database.Host, conf.Database.Port)
	recog := recognition.NewClient()
	ourRecog, err := pipeline.NewRecognitionClient("sound.db")
	if err != nil {
		panic(err)
	}

	appServer := server.NewServer(conf.Server.Host, conf.Server.Port, database, recog, ourRecog)
	appServer.Run()
}
