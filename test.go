package main


import "fmt"

func main() {
    // This will cause a syntax error - missing closing brace
    fmt.Println("Hello, World!"
    
    // Another error - undefined variable
    fmt.Println(undefinedVar)
    
    // Type error
    var x int = "string"
}
