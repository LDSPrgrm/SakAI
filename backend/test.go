package main

import (
	"encoding/json"
	"fmt"
	"time"
)

type S struct {
	U time.Time `json:"updated_at"`
}

func main() {
	b, _ := json.Marshal(S{})
	fmt.Println(string(b))
}
