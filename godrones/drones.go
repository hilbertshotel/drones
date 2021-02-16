package main

import (
	"os"
	"fmt"
	"sync"
	"time"
	"strings"
	"path/filepath"
)

var horde sync.WaitGroup


///// DRONE /////
func isDirectory(file string) bool {
	info, err := os.Stat(file)
    if err != nil { return false }
    return info.IsDir()
}	


func search(file string, pattern string, path string) {
	fullPath := filepath.Join(path, file)
	switch isDirectory(fullPath) {
	case true: spawnDrone(pattern, fullPath)
	default:
		if strings.Contains(file, pattern) {
			fmt.Println(fullPath)
		}
	}
}


func drone(pattern string, path string) {
	defer horde.Done()

	dir, err := os.Open(path)
	defer dir.Close()

	if err == nil {
		list, _ := dir.Readdirnames(-1)
		for _, file := range list {
			search(file, pattern, path)
		}
	}
}


func spawnDrone(pattern string, path string) {
	horde.Add(1)
	go drone(pattern, path)
}


///// MAIN /////
func dispatchDrones(pattern string) {
	start := time.Now()
	spawnDrone(pattern, "/")
	fmt.Println("\nsearching for `\x1B[34m" + pattern + "\x1B[0m` pattern")
	fmt.Println("==================================================")
	
	horde.Wait()
	duration := time.Since(start)
	fmt.Println("==================================================")
	fmt.Printf("total search duration: \x1B[32m%s\x1B[0m\n\n", duration)
}


func main() {
	args := os.Args
	switch len(args) {
		case 1: fmt.Println("info")
		case 2: dispatchDrones(args[1])
		default: fmt.Println("error: too many arguments")
	}
}
