package dsp

import (
	"gonum.org/v1/gonum/dsp/fourier"
)

// FFT is a fast fourier transform using gonum/fourier
// TODO remove adding duplicate frequencies (it's ~33% slower with them)
func FFT(in []float64) []float64 {
	fft := fourier.NewFFT(len(in))
	coefs := fft.Coefficients(nil, in)
	C := len(coefs)

	res := make([]float64, len(in))

	for i, c := range coefs {
		res[i] = real(c)
	}

	// Add duplicate frequencies
	for i := 0; i < len(res)-C; i++ {
		res[i+C] = res[i+1]
	}

	return res
}

// Int to complex
func itoc(i int) complex128 {
	return complex(float64(i), 0)
}
