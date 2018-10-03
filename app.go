package main

import (
	"bufio"
	"fmt"
	"github.com/anmitsu/go-shlex"
	"net"
	"os"
	"os/exec"
)

const (
	CONN_HOST = "0.0.0.0"
	CONN_PORT = "9999"
	CONN_TYPE = "tcp"
)

// Handles incoming requests.
func handleRequest(conn net.Conn) {
	// Read the command
	const posix_shlex = true
	defer conn.Close()
	clientReader := bufio.NewReader(conn)
	clientWriter := bufio.NewWriter(conn)
	commandLine, err := clientReader.ReadString('\n')

	fmt.Println("[DEBUG] CMD line: ", commandLine)

	if err != nil {
		fmt.Println("Error reading:", err.Error())
		return
	}

	cmdArgs, err := shlex.Split(commandLine, posix_shlex)
	fmt.Println("[DEBUG] CMD args: ", cmdArgs)

	cmd := exec.Cmd{Path: cmdArgs[0],
		Args:   cmdArgs,
		Stdin:  clientReader,
		Stdout: clientWriter,
		Stderr: clientWriter,
	}

	err = cmd.Run()
	if err != nil {
		message := fmt.Sprintf("Error running command:", err.Error())
		clientWriter.WriteString(message)
		clientWriter.Flush()
		fmt.Println(message)
	}
}

func main() {
	fmt.Println("I'm running as PID", os.Getpid(), "as user", os.Getuid())
	// Listen for incoming connections.
	l, err := net.Listen(CONN_TYPE, CONN_HOST+":"+CONN_PORT)
	if err != nil {
		fmt.Println("Error listening:", err.Error())
		os.Exit(1)
	}

	// Close the listener when the application closes.
	defer l.Close()
	fmt.Println("Listening on " + CONN_HOST + ":" + CONN_PORT)
	for {
		// Listen for an incoming connection.
		conn, err := l.Accept()
		if err != nil {
			fmt.Println("Error accepting: ", conn.RemoteAddr(), ", ", err.Error())
			break;
		}

		fmt.Println("Accepting: ", conn.RemoteAddr())
		// Handle connection
		handleRequest(conn)
	}
}
