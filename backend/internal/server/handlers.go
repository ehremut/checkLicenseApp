package server

import (
	"context"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"path/filepath"
	"soundHelper/internal/db"
	"strings"
	"time"

	"soundHelper/internal/auth"
	"soundHelper/internal/tools"
)


// TODO: change response code
func (s *Server) login(w http.ResponseWriter, r *http.Request) {
	ctx := context.Background()
	body, closeFunc, err := tools.ReadRequestBodyJson(r, &LoginRequest{})
	if err != nil {
		log.Printf("Can`t read json body: %s", err)
		w.WriteHeader(500)
		w.Write(ToByteLoginResponse("", err.Error()))
		return
	}

	jsonReq := body.(*LoginRequest)
	defer closeFunc()

	password, err := s.database.GetUserPassword(ctx, jsonReq.Login)
	if err != nil {
		log.Printf("Error to check user auth data %s\n", err)
		w.WriteHeader(500)
		w.Write(ToByteLoginResponse("", "Internal error"))
		return
	}

	ok := auth.ComparePasswords(password, jsonReq.Password)
	if !ok {
		log.Printf("Incorrect password %s\n", err)
		w.WriteHeader(500)
		w.Write(ToByteLoginResponse("", "Incorrect password"))
		return
	}

	token, err := auth.CreateNewToken(jsonReq.Login)
	if err != nil {
		log.Printf("Error to create user token %s\n", err)
		w.WriteHeader(500)
		w.Write(ToByteLoginResponse("", err.Error()))
		return
	}

	jsonResp := ToByteLoginResponse(token, "")
	w.Write(jsonResp)
}

func (s *Server) checkToken(w http.ResponseWriter, r *http.Request) {
	token := r.Header.Get("x-access-token")

	username, code, ok := auth.ParseToken(token)
	if !ok {
		w.WriteHeader(code)
	}
	w.Write([]byte(username))
}

func (s *Server) recognitionLink(w http.ResponseWriter, r *http.Request) {
	body, closeFunc, err := tools.ReadRequestBodyJson(r, &SoundLinkRequest{})
	if err != nil {
		log.Printf("Can`t read json body: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer closeFunc()

	jsonReq := body.(*SoundLinkRequest)

	fileData, err := tools.DownloadFile(jsonReq.URL)
	if err != nil {
		log.Printf("Can`t download file: %s", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	filename := fmt.Sprintf("%s.mp3", time.Now().String())
	file, err := tools.CreateSoundFile(filename, fileData)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	resp, err := s.findSound(file)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Write(resp)
}

func (s *Server) recognition(w http.ResponseWriter, r *http.Request) {
	data, closeFunc, err := tools.ReadRequestBodyJson(r, &SoundRequest{})
	if err != nil {
		w.WriteHeader(500)
	}
	defer closeFunc()

	sound := data.(*SoundRequest)

	decodeSound, err := base64.StdEncoding.DecodeString(sound.Sound)
	if err != nil {
		fmt.Println("decode error:", err)
		return
	}

	file, err := tools.CreateSoundFile(sound.Filename, decodeSound)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer tools.CloseFile(file)

	resp, err := s.findSound(file)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Write(resp)
}

func (s *Server) load(w http.ResponseWriter, r *http.Request) {
	file, err := os.Open("SODA LUV@bigass.mp3")
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	defer file.Close()

	file, err = s.ourPredictor.Load(file)
	if err != nil {
		log.Printf("Error to load %s\n", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	filename := file.Name()
	file.Close()
	if err := os.Remove(filename); err != nil {
		log.Printf("Error to delete file: %s\n", err)
	}
}

func (s *Server) addFavorite(w http.ResponseWriter, r *http.Request) {
	var req FavoriteRequest
	data, closeFunc, err := tools.ReadRequestBodyJson(r, &req)
	if err != nil {
		w.WriteHeader(500)
	}
	defer closeFunc()

	favorite := data.(*FavoriteRequest)

	if err := s.database.AddFavorites("user", favorite.Filename); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
	}

}

func (s *Server) deleteFavorite(w http.ResponseWriter, r *http.Request) {
	var req FavoriteRequest
	data, closeFunc, err := tools.ReadRequestBodyJson(r, &req)
	if err != nil {
		w.WriteHeader(500)
	}
	defer closeFunc()

	favorite := data.(*FavoriteRequest)

	if err := s.database.DeleteFavorites("user", favorite.Filename); err != nil {
		w.WriteHeader(http.StatusInternalServerError)
	}

}

func (s *Server) getSongList(w http.ResponseWriter, r *http.Request) {
	var files []string

	root := "wav/"
	err := filepath.Walk(root, func(path string, info os.FileInfo, err error) error {
		if filepath.Ext(path) == ".mp3" {
			files = append(files, path)
		}
		return nil
	})
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
	}

	var sounds []Sound
	for _, file := range files {
		file = strings.Replace(file, "_-_", "-", -1)
		file = strings.Replace(file, "_", " ", -1)
		attr := strings.Split(file, "-")
		sounds = append(sounds, Sound{
			Artist:   attr[0],
			Title:    attr[1],
			Album:    "",
			Link:     "http://192.168.31.44:8080/wav/" + file,
			Image:    "https://r7.pngwing.com/path/759/56/31/kuwait-airways-apple-music-dotkiller-poke-score-application-software-music-tune-57d598162fa7e9b6acdd46a4d969502a.png",
			Filename: file,
			Licence:  0,
		})
	}

	jsonResp, err := json.Marshal(sounds)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
	}

	w.Write(jsonResp)
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("x-access-token")
		if token != "" {
			login, _, ok := auth.ParseToken(token)
			if !ok {
				w.WriteHeader(http.StatusUnauthorized)
				return
			}

			ctx := context.WithValue(context.Background(), "login", login)
			r.WithContext(ctx)
		}

		log.Println(r.RequestURI)
		r.WithContext(context.Background())
		next.ServeHTTP(w, r)
	})
}

func (s *Server) findSound(file *os.File) ([]byte, error) {
	song, fileWAV, err := s.ourPredictor.Read(file)
	if err != nil {
		return nil, err
	}
	defer tools.CloseFile(fileWAV)

	if song != "" {
		songReq := CreateSound(song)
		go db.SaveQuery(songReq.Artist, songReq.Title, songReq.Album, "", OpenLicence)
		resp, _ := CreateByteSoundRequest(songReq.Artist, songReq.Title, songReq.Album, songReq.Link, OpenLicence)
		return resp, err
	}

	result, err := s.predictor.Recognition(file)
	if err != nil {
		return nil, err
	}
	if result != nil {
		go db.SaveQuery(result.Artist, result.Title, result.Title, result.AppleMusic.URL, CloseLicence)
		resp, _ := CreateByteSoundRequest(result.Artist, result.Title, result.Album, result.AppleMusic.URL, CloseLicence)
		return resp, nil
	}

	resp, _ := CreateByteSoundRequest("Unknown", "Unknown", "", "", UnknownLicence)

	return resp, nil
}

func ToByteLoginResponse(token, loginErr string) []byte {
	response := LoginResponse{
		Token: token,
		Err:   loginErr,
	}

	jsonResp, err := json.Marshal(response)
	if err != nil {
		return []byte{}
	}

	return jsonResp
}