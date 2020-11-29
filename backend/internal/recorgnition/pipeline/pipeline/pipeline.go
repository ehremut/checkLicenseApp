package pipeline

import (
	"os"
	"os/exec"
	"path/filepath"

	"github.com/pkg/errors"
	log "github.com/sirupsen/logrus"

	"soundHelper/internal/recorgnition/pipeline/db"
	"soundHelper/internal/recorgnition/pipeline/fingerprint"
	"soundHelper/internal/recorgnition/pipeline/model"
	"soundHelper/internal/recorgnition/pkg/dsp"
)

// Pipeline is a struct that allows to operate on audio files
type Recognition struct {
	s   *dsp.Spectrogrammer
	DB  db.Database
	fpr fingerprint.Fingerprinter
}

// NewRecognitionClient creates a new default pipeline using a Bolt DB, the default fingerprinter and the default spectrogrammer
func NewRecognitionClient(dbFile string) (*Recognition, error) {
	db, err := db.NewBoltDB(dbFile)
	if err != nil {
		return nil, errors.Wrapf(err, "error connection to database at: %s", dbFile)
	}
	s := dsp.NewSpectrogrammer(model.DownsampleRatio, model.MaxFreq, model.SampleSize, true)
	fpr := fingerprint.NewDefaultFingerprinter()

	return &Recognition{
		s:   s,
		DB:  db,
		fpr: fpr,
	}, nil
}

// Close closes the underlying database
func (r *Recognition) Close() {
	r.DB.Close()
}

// Result represents the output of a pipeline
type Result struct {
	Path         string
	CMap         []model.ConstellationPoint
	SongID       uint32
	SamplingRate float64
	Spectrogram  [][]float64
	Fingerprint  map[model.EncodedKey]model.TableValue
}

// ProcessAndStore process the given audio file and store it in the database
// the computed results are returned
func (r *Recognition) ProcessAndStore(file *os.File) (*Result, *os.File, error) {
	partial, file, err := r.read(file)
	if err != nil {
		return nil, file, err
	}

	filename := filepath.Base(file.Name())
	id, err := r.DB.SetSong(model.SongNameFromPath(filename))
	if err != nil {
		return nil, file, errors.Wrap(err, "error storing song name in database")
	}

	songFpr := r.fpr.Fingerprint(id, partial.cMap)
	if err := r.DB.Set(songFpr); err != nil {
		return nil, file, errors.Wrap(err, "error storing song fingerprint in database")
	}

	log.Infof("Sucessfully loaded %s into the database", filename)
	return &Result{
		Path:         file.Name(),
		CMap:         partial.cMap,
		SongID:       id,
		SamplingRate: partial.samplingRate,
		Spectrogram:  partial.spectrogram,
		Fingerprint:  songFpr,
	}, file, nil
}

func (r *Recognition) Process(file *os.File) (*Result, *os.File, error) {
	partial, file, err := r.read(file)
	if err != nil {
		return nil, file, err
	}

	var id uint32
	songFpr := r.fpr.Fingerprint(id, partial.cMap)

	log.Infof("Successfully loaded %s into the database", file.Name())
	return &Result{
		Path:         file.Name(),
		CMap:         partial.cMap,
		SongID:       id,
		SamplingRate: partial.samplingRate,
		Spectrogram:  partial.spectrogram,
		Fingerprint:  songFpr,
	}, file, nil
}

type partialResult struct {
	cMap         []model.ConstellationPoint
	samplingRate float64
	spectrogram  [][]float64
}

func (r *Recognition) read(file *os.File) (*partialResult, *os.File, error) {
	if extension := filepath.Ext(file.Name()); extension != ".wav" {
		fileWAV, err := transformToWAV(file.Name())
		if err != nil {
			return nil, nil, err
		}
		file = fileWAV
	}

	spec, spr, err := r.s.Spectrogram(file)
	if err != nil {
		return nil, nil, errors.Wrap(err, "error generating spectrogram")
	}

	cMap := r.s.ConstellationMap(spec, spr)

	return &partialResult{
		cMap:         cMap,
		samplingRate: spr,
		spectrogram:  spec,
	}, file, nil
}

func transformToWAV(filename string) (*os.File, error) {
	extension := filepath.Ext(filename)
	base := filepath.Base(filename)
	name := base[0:len(base)-len(extension)] + ".wav"
	path := "internal/recorgnition/assets/wav/" + name

	if err := runCommand(filename, path); err != nil {
		return nil, err
	}

	file, err := os.Open(path)
	if err != nil {
		return nil, err
	}

	return file, nil
}

func runCommand(filename, path string) error {
	cmd := exec.Command("ffmpeg", "-y", "-i", filename, path)

	//cmd.Stderr = os.Stderr
	//cmd.Stdout = os.Stdout

	if err := cmd.Run(); err != nil {
		log.Printf("cmd.Run() failed with %s\n", err)
		return err
	}

	return nil
}