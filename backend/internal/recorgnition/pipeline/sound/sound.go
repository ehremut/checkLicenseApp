package sound

// Reader interface allows you to read audio files
type Reader interface {
	Read([]float64) (int, error)
	SampleRate() float64
}
