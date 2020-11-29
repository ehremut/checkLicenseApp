package auth

import (
	"math"
	"net/http"

	"github.com/dgrijalva/jwt-go"
)

var jwtKey = []byte("supersecrettokenkey")

func CreateNewToken(username string) (string, error) {
	claims := &Claims{
		Username: username,
		StandardClaims: jwt.StandardClaims{
			// In JWT, the expiry time is expressed as unix milliseconds
			ExpiresAt: math.MaxInt64,
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	tokenString, err := token.SignedString(jwtKey)
	if err != nil {
		return "", err
	}

	return tokenString, nil
}

func ParseToken(token string) (string, int, bool) {
	claims := &Claims{}

	tkn, err := jwt.ParseWithClaims(token, claims, func(token *jwt.Token) (interface{}, error) {
		return jwtKey, nil
	})
	if err != nil {
		if err == jwt.ErrSignatureInvalid {
			return "", http.StatusUnauthorized, false
		}
		return "", http.StatusBadRequest, false
	}
	if !tkn.Valid {
		return "", http.StatusUnauthorized, false
	}

	return claims.Username, 200, true
}
