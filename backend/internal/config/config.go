package config

import (
	"github.com/spf13/viper"
)

type ConfigStruct struct {
	Server struct {
		Host string
		Port int
	}
	Database struct{
		Host string
		Port int
	}
}

var Config ConfigStruct

func LoadConfig(path string) {
	v := viper.New()
	v.SetConfigName("config")
	v.SetConfigType("yaml")

	v.AddConfigPath(path)
	if err := v.ReadInConfig(); err != nil {
		panic(err)
	}

	if err := v.Unmarshal(&Config); err != nil {
		panic(err)
	}
}
