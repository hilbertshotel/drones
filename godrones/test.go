package main

import (
	"fmt"
	"os"
)

var path = "C:\\Users\\kolu"


func main() {
	dir, err := os.Open(path) // access denied on some folders
	if err != nil { fmt.Println(err) }
	defer dir.Close()
	list, _ := dir.Readdirnames(-1) // access denied on some folders
	fmt.Println(list)
}