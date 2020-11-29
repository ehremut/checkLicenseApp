package pipeline

import (
	"fmt"
	"os"
	"soundHelper/internal/recorgnition/pipeline/model"
	"soundHelper/internal/recorgnition/pkg/dsp"
)

var dbFile string

func (r *Recognition) Read(file *os.File) (string, *os.File, error) {
	res, file, err := r.Process(file)
	if err != nil {
		return "", file, err
	}

	keys := make([]model.EncodedKey, 0, len(res.Fingerprint))
	sample := map[model.EncodedKey]model.TableValue{}
	matches := map[uint32]map[model.EncodedKey]model.TableValue{}

	for k, v := range res.Fingerprint {
		keys = append(keys, k)
		sample[k] = v
	}

	m, err := r.DB.Get(keys)
	for key, values := range m {
		for _, val := range values {
			if _, ok := matches[val.SongID]; !ok {
				matches[val.SongID] = map[model.EncodedKey]model.TableValue{}
			}

			matches[val.SongID][key] = val
		}
	}

	scores := map[uint32]float64{}
	for songID, points := range matches {
		scores[songID] = dsp.MatchScore(sample, points)
	}

	var song string
	var max float64
	fmt.Println("Matches:")
	for id, score := range scores {
		name, err := r.DB.GetSong(id)
		if err != nil {
			return "", file, err
		}

		fmt.Printf("\t- %s, score: %f\n", name, score)
		if score > max {
			max = score
			song = name
		}
	}

	if max < 5000 {
		song = ""
	}

	return song, file, nil
}
