package server

import (
	"encoding/json"
	"errors"
	"fmt"
	log "github.com/sirupsen/logrus"
	"net/http"
	"soundHelper/internal/tools"
	"strings"
)

const (
	OpenLicence    = 0
	CloseLicence   = 1
	UnknownLicence = 2
)

type LoginRequest struct {
	Login    string
	Password string
}

type LoginResponse struct {
	// add user info
	Name  string
	Email string
	Token string
	Err   string
}

type SoundRequest struct {
	Filename string
	Sound    string
}

type Sound struct {
	Artist   string `json:"artist"`
	Title    string `json:"title"`
	Album    string `json:"albul"`
	Link     string `json:"link"`
	Image    string `json:"image"`
	Filename string `json:"filename"`
	Licence  int    `json:"licence"`
}

type SoundResponse struct {
	Find    Sound
	Similar []Sound
}

type SoundLinkRequest struct {
	URL string
}

type FavoriteRequest struct {
	Filename string
}

func CreateByteSoundRequest(artist, title, album, link string, licence int) ([]byte, error) {
	image, _ := tools.GetImage(link)
	if image == "" {
		image = "https://r7.pngwing.com/path/759/56/31/kuwait-airways-apple-music-dotkiller-poke-score-application-software-music-tune-57d598162fa7e9b6acdd46a4d969502a.png"
	}
	similar, err := GetSimilar(link)
	if err != nil {
		log.Println("Not found similar")
	}
	req := SoundResponse{
		Find: Sound{
			Artist:  artist,
			Title:   title,
			Album:   album,
			Licence: licence,
			Link:    link,
			Image:   image,
		},
		Similar: similar,
	}

	return json.Marshal(req)
}

func CreateSound(song string) *Sound {
	var artist, title string
	attr := strings.Split(song, "@")
	if len(attr) == 2 {
		artist = attr[0]
		title = attr[1]
	}

	return &Sound{
		Artist:  artist,
		Title:   title,
		Licence: OpenLicence,
	}
}

func GetSimilar(url string) ([]Sound, error) {
	resp, err := http.Get("http://192.168.31.55:8084/recommendation")
	if err != nil {
		log.Println("Can`t get similar")
		return nil, err
	}
	if resp.StatusCode == http.StatusInternalServerError {
		return nil, errors.New(fmt.Sprintf("Bad status code %s\n", err))
	}

	songs := []Sound{}

	err = json.NewDecoder(resp.Body).Decode(&songs)
	if err != nil {
		return nil, err
	}

	for i, val := range songs {
		songs[i].Filename = val.Filename[:len(val.Filename)-3] + ".wav"
		songs[i].Link = "http://192.168.31.44:8080/wav/" + val.Filename
	}

	return songs, nil
}
