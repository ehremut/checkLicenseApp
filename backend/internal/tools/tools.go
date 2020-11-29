package tools

import (
	"encoding/json"
	"errors"
	"fmt"
	log "github.com/sirupsen/logrus"
	"io/ioutil"
	"net/http"
	"os"
	"path/filepath"
)

func ReadRequestBodyJson(r *http.Request, jsonReq interface{}) (interface{}, func() error, error) {
	err := json.NewDecoder(r.Body).Decode(jsonReq)
	if err != nil {
		return nil, nil, err
	}

	return jsonReq, r.Body.Close, nil
}

func CreateSoundFile(filename string, data []byte) (*os.File, error) {
	filename = filepath.Base(filename)
	filename = "tmp/" + "_" + filename
	file, err := os.Create(filename)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	file.Write(data)
	file.Close()

	file, err = os.Open(filename)
	if err != nil {
		log.Println(err)
		return nil, err
	}

	return file, nil
}

func CloseFile (file *os.File) {
	filename := file.Name()
	if err := os.Remove(filename); err != nil {
		log.Printf("Error to delete file: %s\n", err)
	}
}

func DownloadFile(url string) ([]byte, error) {
	resp, err := http.Get(url)
	if err != nil {
		log.Printf("Error to get file %s", resp)
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, errors.New(fmt.Sprintf("Error to download file %d", resp.StatusCode))
	}
	bodyBytes, err := ioutil.ReadAll(resp.Body)
	if err != nil {
		log.Printf("Error to read body %s\n", err)
	}

	return bodyBytes, nil
}

func GetImage(url string) (string, error) {
	resp, err := http.Get("http://192.168.31.55:8085/get_cover?url=" + url)
	if err != nil {
		log.Println("Can`t get image")
		return "", err
	}
	if resp.StatusCode == http.StatusInternalServerError {
		return "", nil
	}

	var response struct{
		URL string
	}

	err = json.NewDecoder(resp.Body).Decode(&response)
	if err != nil {
		return "", err
	}

	return response.URL, nil
}
