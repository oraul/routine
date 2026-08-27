package main

import (
	"bufio"
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

// semverTag is the exact grammar bin/routine-release-notes enforces:
// ^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$
var semverTag = regexp.MustCompile(`^v(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)$`)

// mergeSubjectPrefix is the merge-title grammar the bash script's sed
// rewrites into a bullet: sed -E 's/^Merge pull request #[0-9]+: /- /'
var mergeSubjectPrefix = regexp.MustCompile(`^Merge pull request #[0-9]+: `)

// releaseNotesUsage is byte-identical to the bash script's own usage
// line: the port keeps the script's own name, not the binary's, since
// parity means reproducing this exact string, not a rewording of it.
const releaseNotesUsage = "usage: routine-release-notes vX.Y.Z [repo-dir]\n"

// defaultReleaseNotesRepo mirrors the bash default —
// repo="${2:-$(cd "$(dirname "$0")/.." && pwd)}" — using the running
// binary's own path in place of the bash script's $0.
func defaultReleaseNotesRepo() string {
	self := os.Args[0]
	dir := filepath.Join(filepath.Dir(self), "..")
	if abs, err := filepath.Abs(dir); err == nil {
		return abs
	}
	return dir
}

func gitDirValid(repo string) bool {
	cmd := exec.Command("git", "-C", repo, "rev-parse", "--git-dir")
	return cmd.Run() == nil
}

func releaseTagRefExists(repo, tag string) bool {
	cmd := exec.Command("git", "-C", repo, "rev-parse", "-q", "--verify", "refs/tags/"+tag)
	return cmd.Run() == nil
}

// previousReleaseTag mirrors:
//
//	prev="$(git -C "$repo" describe --tags --abbrev=0 --exclude "$tag" "$end" 2>/dev/null || true)"
//
// A failure (no prior tag at all) yields an empty string, exactly as
// the bash "|| true" absorbs the non-zero exit and leaves prev unset.
func previousReleaseTag(repo, tag, end string) string {
	cmd := exec.Command("git", "-C", repo, "describe", "--tags", "--abbrev=0", "--exclude", tag, end)
	out, err := cmd.Output()
	if err != nil {
		return ""
	}
	return strings.TrimRight(string(out), "\n")
}

// printMergeSubjects mirrors:
//
//	git -C "$repo" log --merges --first-parent --format='%s' "$range" \
//	  | sed -E 's/^Merge pull request #[0-9]+: /- /'
//
// A git log failure is never surfaced — the bash pipeline's exit status
// is sed's, which succeeds even over empty input, and the script always
// exits 0 at its final line regardless.
func printMergeSubjects(repo, rng string) {
	cmd := exec.Command("git", "-C", repo, "log", "--merges", "--first-parent", "--format=%s", rng)
	out, _ := cmd.Output()

	scanner := bufio.NewScanner(bytes.NewReader(out))
	for scanner.Scan() {
		fmt.Println(mergeSubjectPrefix.ReplaceAllString(scanner.Text(), "- "))
	}
}

func runReleaseNotes(args []string) int {
	tag := ""
	if len(args) > 0 {
		tag = args[0]
	}

	repo := defaultReleaseNotesRepo()
	if len(args) > 1 {
		repo = args[1]
	}

	if !semverTag.MatchString(tag) || !gitDirValid(repo) {
		fmt.Fprint(os.Stderr, releaseNotesUsage)
		return 2
	}

	// Range: previous tag → the release. While the tag does not exist
	// yet the release end is HEAD; the previous tag is the newest one
	// strictly before the end (the end's own tag excluded).
	end := "HEAD"
	if releaseTagRefExists(repo, tag) {
		end = tag
	}
	prev := previousReleaseTag(repo, tag, end)

	rng := end
	if prev != "" {
		rng = prev + ".." + end
	}

	fmt.Println("## Changes")
	fmt.Println()
	printMergeSubjects(repo, rng)

	return 0
}
