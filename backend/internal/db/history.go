package db

import (
	"log"
)

func SaveQuery(artist, title, album, link string, licence int) {
	log.Printf("Save result in history: %s - %s; %s, %d", artist, title, album, licence)
}
