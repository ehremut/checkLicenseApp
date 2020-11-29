package auth

import (
	"fmt"
	"testing"
)

func TestHashAndSalt(t *testing.T) {
	pwd := []byte("admin")
	got, err := HashAndSalt(pwd)
	if err != nil {
		t.Errorf("HashAndSalt() error = %v", err)
		return
	}

	fmt.Println(got)
}
