package recognition

import (
	"os"

	"github.com/AudDMusic/audd-go"
	log "github.com/sirupsen/logrus"
)

type Client struct {
	Audd *audd.Client
}

func NewClient() *Client {
	return &Client{
		Audd: audd.NewClient("0eceb242aa9855c79ccdc3435acc1986"),
	}
}

func (c *Client) Recognition(file *os.File) (*audd.RecognitionResult, error) {
	result, err := c.Audd.Recognize(file, "apple_music", nil)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	if result.Title == "" || result.Album == "" || result.Artist == "" {
		return nil, nil
	}
	var appleURL string
	if result.AppleMusic != nil {
		appleURL = result.AppleMusic.URL
	}
	log.Printf("%s - %s. Album: %s\nLink: %s",
		result.Artist, result.Title, result.Album, appleURL)

	return &result, nil
}
