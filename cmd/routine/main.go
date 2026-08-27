// Command routine is the compiled core: a single binary exposing the
// ported subcommands. It is built from the repository checkout with the
// stdlib-only toolchain (Law 5) and never gains a third-party import.
package main

import (
	"fmt"
	"os"
)

// commit carries the build-time provenance Law 5 requires: overridden
// via `-ldflags "-X main.commit=$(git describe --always --dirty)"`. A
// binary built without that flag reports "unknown" rather than lying
// about which commit it came from.
var commit = "unknown"

const usage = "usage: routine <subcommand>\n" +
	"  version   print the build-time commit provenance\n"

func main() {
	os.Exit(run(os.Args[1:]))
}

func run(args []string) int {
	if len(args) == 0 {
		fmt.Fprint(os.Stderr, usage)
		return 2
	}

	switch args[0] {
	case "version":
		fmt.Println(commit)
		return 0
	default:
		fmt.Fprint(os.Stderr, usage)
		return 2
	}
}
