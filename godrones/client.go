package main

import (
	"os"
	"fmt"
	"net"
)

func handleErr(err error) {
	if err != nil {
		fmt.Println(err)
		os.Exit(1)
	}
}


func main() {
	address, err := net.ResolveTCPAddr("tcp", "127.0.0.1:8091")
	handleErr(err)

	connection, err := net.DialTCP("tcp", nil, address)
	handleErr(err)

	var input string 

	for { 
		fmt.Scanln(&input)
		_, err := connection.Write([]byte(input))
		handleErr(err)
	}
	
}
