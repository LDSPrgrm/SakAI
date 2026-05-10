package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
)

func main() {
	// Register
	regBody := []byte(`{"email":"testgo5@example.com","password":"Password123!","name":"Test Go","phone":"+1234567895","role":"driver"}`)
	res, err := http.Post("http://localhost:8080/api/auth/register", "application/json", bytes.NewReader(regBody))
	if err != nil {
		panic(err)
	}
	defer res.Body.Close()
	body, _ := io.ReadAll(res.Body)
	
	var resData map[string]interface{}
	json.Unmarshal(body, &resData)
	tokenObj, ok := resData["access_token"]
	if !ok || tokenObj == nil {
		panic(fmt.Sprintf("Failed to get token, response: %s", string(body)))
	}
	token := tokenObj.(string)

	// Set Status
	req, _ := http.NewRequest(http.MethodPut, "http://localhost:8080/api/driver/status", bytes.NewReader([]byte(`{"status":"online"}`)))
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Authorization", "Bearer "+token)

	res2, _ := http.DefaultClient.Do(req)
	body2, _ := io.ReadAll(res2.Body)
	fmt.Println("PUT response:", string(body2))
	res2.Body.Close()

	// Get Status
	req3, _ := http.NewRequest(http.MethodGet, "http://localhost:8080/api/driver/status", nil)
	req3.Header.Set("Authorization", "Bearer "+token)

	res3, _ := http.DefaultClient.Do(req3)
	defer res3.Body.Close()
	body3, _ := io.ReadAll(res3.Body)
	fmt.Println("GET response:", string(body3))
}
