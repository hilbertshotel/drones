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


func handleConnection(connection net.Conn) {
	defer connection.Close()
	
	buf := make([]byte, 1048)
	for {
		len, err := connection.Read(buf) // length
		if err != nil {
			fmt.Println("Someone has disconnected from the server")
			connection.Close()
			return
		}
		msg := string(buf[0:len])
		fmt.Println(msg)
	}
}


func main() {
	address, err := net.ResolveTCPAddr("tcp", "127.0.0.1:8091")
	handleErr(err)

	listener, err := net.ListenTCP("tcp", address)
	handleErr(err)
	fmt.Println("Now listening on 127.0.0.1:8091")

	for {
        connection, err := listener.Accept()
        if err != nil { continue }
		go handleConnection(connection)
    }
}
