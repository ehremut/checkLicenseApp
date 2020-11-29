package pipeline

import (
	log "github.com/sirupsen/logrus"
	"os"
)

func (r *Recognition) Load(file *os.File) (*os.File, error) {
	_, file, err := r.ProcessAndStore(file)
	if err != nil {
		return nil, err
	}

	log.Infof("Processed file at %s\n", file.Name())
	return file, nil
}
