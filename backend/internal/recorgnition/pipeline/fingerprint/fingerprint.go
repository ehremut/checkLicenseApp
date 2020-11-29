package fingerprint

import "soundHelper/internal/recorgnition/pipeline/model"

type Fingerprinter interface {
	Fingerprint(uint32, []model.ConstellationPoint) map[model.EncodedKey]model.TableValue
}
